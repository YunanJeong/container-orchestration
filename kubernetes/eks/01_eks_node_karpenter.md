# EKS 초기설정 관련 기록

## Karpenter

EKS에서 노드 프로비저닝을 자동화하는 오픈소스 도구

- EKS노드는 EC2인스턴스로 구현된다.
- `클라우드 기반 쿠버네티스에서 원칙상 실제 물리 리소스를 고려하지 않아도 되지만, 현실적으로 다음과 같은 노드 관리 요구사항이 있음`
  - EKS에서 한 인스턴스(노드)의 사양은 어느 수준으로 해야할까?
    - 오토스케일링 시 한 인스턴스의 사양은 어떻게 제어할까?
    - 4core짜리 1개가 필요할수도, 2core짜리 2개가 필요할 수도 있다.
  - 비용 효율화를 할 수 있을까?
  - 특정 앱(Pod)이, 노드 몇 개를 오롯이 점유하게 할 수는 없을까?
  - EKS 내 용도 별로 노드 그룹(Node Group)을 분류할 수 있나?
- Karpenter가 없어도 EKS 운영가능하나, 인스턴스 관리 효율성, 편의성을 위해 사용
- Karpenter 설치 후, EC2NodeClass와 NodePool이라는 리소스로 노드 분류를 정의 가능. 이후 앱 배포시 Node Selector로 특정 NodePool을 지정하면 그에 맞게 노드가 할당됨

### EC2NodeClass와 NodePool 예시

```yaml
apiVersion: karpenter.k8s.aws/v1   ### CHANGED: v1beta1 → v1
kind: EC2NodeClass
metadata:
  # 서비스와 용도에 맞는 이름
  name: eks-platform-common
spec:
  amiFamily: AL2023 # AL2023 or bottlerocket 권장  # AL2는 Deprecated 
  ### CHANGED: amiSelectorTerms가 v1에서 필수 필드가 됨
  amiSelectorTerms:
    - alias: al2023@v20250807 # Amazon EKS optimized AMI alias 사용
  role: "KarpenterNodeRole-B" # replace with your cluster name

  # NodeClass에 의한 신규 Node 생성시, 여기 기술된 tag를 가지고있는 기존 서브넷이 신규Node에 등록된다.
  subnetSelectorTerms:
    - tags:
        karpenter.sh/discovery: "A" # 기존 클러스터 A와 동일한 서브넷을 씁니다.
  
  # NodeClass에 의한 신규 Node 생성시, 여기 기술된 tag를 가지고있는 기존 보안그룹이 신규Node에 등록된다.
  securityGroupSelectorTerms:
    - tags:
        karpenter.sh/discovery: "B" # 클러스터 B 내부통신을 위한 전체 공통 보안 그룹을 가리킵니다.

  # NodeClass에 의한 신규 AWS 리소스 생성시, 첨부할 태그 설정 (EC2,EBS 등등)
  tags:
    Service: ALL-COMMON-RNDAI
    Owner: yunanjeong.github.com
    Description: platform-node-controlled-by-karpenter
    Name: platform-nodepool-resource
    # Name도 써줘야 나중에 관리하기 편합니다.
    # => K8s 리소스 삭제시 연동된 AWS 리소스도 삭제되는 것이 정석이지만, 설정에 따라 삭제되지 않고 미사용 AWS리소스가 지저분하게 남는 경우가 종종 있습니다.

---
apiVersion: karpenter.sh/v1   ### CHANGED: v1beta1 → v1
kind: NodePool
metadata:
  # 서비스와 용도에 맞는 이름
  name: eks-platform-common
spec:
  template:
    metadata:
      labels:
        # 용도별 노드 라벨 # 헬름차트의 nodeSelector에서 이 라벨을 가리키면 노드가 자동 생성 및 스케일링됨.
        app.myservice.com/name: eks-platform-common
    spec:
      requirements:
        # - key: topology.kubernetes.io/zone
        #   operator: In
        #   values: ["ap-northeast-2d"]  # EBS PV 사용시 AZ 맞추기
        - key: kubernetes.io/arch
          operator: In
          values: ["amd64"]
        - key: kubernetes.io/os
          operator: In
          values: ["linux"]
        - key: karpenter.sh/capacity-type
          operator: In
          # values: ["spot", "on-demand"]
          values: ["on-demand"]
        - key: karpenter.k8s.aws/instance-category
          operator: In
          values: ["c", "m", "r"]
        - key: karpenter.k8s.aws/instance-generation
          operator: Gt
          values: ["2"]
      nodeClassRef:
        ### CHANGED: v1에서 group과 kind가 필수가 됨
        group: karpenter.k8s.aws  # apiVersion 대신 group 사용
        kind: EC2NodeClass        # kind 필드 명시적으로 추가
        name: eks-platform-common
      
      ### CHANGED: expireAfter가 spec.disruption에서 spec.template.spec으로 이동
      expireAfter: 720h # 1m  # 720h  # Never  # 미할당시 default 720h

  limits:
    cpu: 240  # 8 코어 x 30 대
    memory: 480Gi  # 16GiB x 30 대
  disruption:
    # 다른 노드와의 통합정책 (비용절감 목적)
    ## WhenUnderutilized: 저활용 상황시 노드 삭제(cpu, ram, pod 수로 판단=>커스텀 불가https://github.com/kubernetes-sigs/karpenter/issues/735)
    ## WhenEmpty: 미사용 상황시 노드 삭제(daemonset에 의한 pod 1개만 있어도 empty가 아님)
    ### CHANGED: WhenUnderutilized → WhenEmptyOrUnderutilized로 이름 변경
    consolidationPolicy: WhenEmptyOrUnderutilized  # 기존: WhenUnderutilized
    
    ### CHANGED: consolidateAfter가 v1에서 필수 필드가 됨[1][31]
    # 노드가 비었을 때 지정 대기 시간 후 통합 작업 시작(노드 삭제)
    ## consolidationPolicy가 WhenEmpty일 때만 사용가능한 속성
    ## Never: 통합(consolidation) 비활성화
    consolidateAfter: 0s  # v1에서 필수, 0s로 설정하면 기존 v1beta1과 동일한 동작

    # NodePool 업데이트시 현재 대상 노드에도 즉시 적용되는 것 같음. 노드 재부팅 불필요
    # 꺼지면 안되는 앱=> 앱 자체에서 retry나 HA구성을 잘 해놓던가 아니면 WhenEmpty에 consolidateAfter와 expireAfter를 Never로 설정해야 함
```

### Karpenter 셋업 후 보안그룹 설정(LoadBalancer 이슈방지)

#### 설정

EKS Node에 사용되는 기본 보안그룹`(이하 EKS보안그룹)`에 태그(`karpenter.sh/discovery: "${EKS_CLUSTER}"`)를 추가한다.

#### 의미

Karpenter로 Node생성시 "EKS보안그룹"과는 별개의 보안그룹이 사용되는데, EKS보안그룹도 Karpenter Node의 기본 보안그룹으로 사용하겠다는 의미이다.

#### 이유

Elasitc LoadBalancer(ELB) 배포시 ELB가 EKS Node에 접근하기 위한 보안규칙이 "EKS보안그룹"에 자동등록되는데, Karpenter Node는 EKS보안그룹을 기본 사용하지 않는다. 따라서, ELB가 Karpenter Node에 접근하지 못하고 프로비저닝에 실패한다. 이를 방지하기 위함.

#### 참고

EKS 클러스터 생성시 인스턴스, 보안그룹 등 여러 AWS 리소스가 함께 자동생성된다.

EKS의 리소스임을 식별하기 위해 다음 tag가 사용된다.

- 기본 EKS 리소스의 tag: `kubernetes.io/cluster/<cluster-name>: owned`
- Karpenter 리소스의 tag: `karpenter.sh/discovery: <cluster-name>`
- (관례적인 초기설정에 따른 key-value로, 사용자 설정에 따라 다른 tag값이 사용될 수 있음)

이 tag들은 "오토스케일링", "보안그룹 자동등록&수정" 등 Managed 기능이 수행될 때에도 대상 리소스 식별을 위해 사용된다.

EC2NodeClass의 `spec.securityGroupSelectorTerms` 섹션도 비슷한 맥락으로 사용된다.

- 앞서 LoadBalancer 이슈방지방법으로 EKS기본그룹에 karpenter 리소스의 태그를 붙이는 방법을 소개했으나,
- spec.securityGroupSelectorTerms에 EKS tag(`kubernetes.io/cluster/<cluster-name>: owned`)를 지정해도 동일한 효과를 얻을 수 있다. 관리하기 편한 방식으로 사용하면 된다.

```yaml
apiVersion: karpenter.k8s.aws/v1beta1
kind: EC2NodeClass
metadata:
  name: eks-platform-common
spec:
  (...)
  # 신규 생성 Node에서 사용될 보안그룹(보안그룹의 tag로 지정가능)
  securityGroupSelectorTerms:
    - tags:
        karpenter.sh/discovery: "${EKS_CLUSTER}" # replace with your cluster name
  (...)
```
