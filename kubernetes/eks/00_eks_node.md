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
apiVersion: karpenter.k8s.aws/v1beta1
kind: EC2NodeClass
metadata:
  # 서비스와 용도에 맞는 이름
  name: eks-platform-common
spec:
  amiFamily: AL2 # Amazon Linux 2
  role: "KarpenterNodeRole-${EKS_CLUSTER}"       # replace with your cluster name

  subnetSelectorTerms:
    - tags:
        karpenter.sh/discovery: "${EKS_CLUSTER}" # replace with your cluster name
  
  # 신규 생성 Node에서 사용될 보안그룹(보안그룹의 tag로 지정가능)
  securityGroupSelectorTerms:
    - tags:
        karpenter.sh/discovery: "${EKS_CLUSTER}" # replace with your cluster name
  tags:
    # EC2 인스턴스에 등록할 태그
    Service: MY-PLATFORM-SERVICE
    Owner: my@gmail.com

---
apiVersion: karpenter.sh/v1beta1
kind: NodePool
metadata:
  # 서비스와 용도에 맞는 이름
  name: eks-platform-common
spec:
  template:
    metadata:
      labels:
        # 향후 신규 앱 배포시 Node Selector로 이 Label을 지정하면, NodePool사양대로 Node가 할당된다.
        my.app.com/name: eks-platform-common
    spec:
      # 노드 사양 설정 (아래 값은 공식문서에 있는 무난한 설정)
      requirements:
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
      # 노드 클래스 참조
      nodeClassRef:
        name: eks-platform-common
  limits:
    cpu: 240       # 8코어 x 30 대
    memory: 480Gi  # 16GiB x 30 대
  disruption:
    consolidationPolicy: WhenUnderutilized
    # 보안을 위해, 특정시간 지나면 노드삭제
    # expireAfter: 720h # 30 * 24h = 720h
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

이런 맥락에서 다음 EC2NodeClass의 `spec.securityGroupSelectorTerms`는 Karpenter Node가 기본으로 가질 보안그룹을 정의하는 것이다.

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
