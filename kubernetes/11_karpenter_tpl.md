# Karpenter

- karpenter CRD인 EC2NodeClass와 NodePool 샘플

## 일반적인 경우

```yaml
apiVersion: karpenter.k8s.aws/v1beta1
kind: EC2NodeClass
metadata:
  # 서비스와 용도에 맞는 이름
  name: eks-platform-common
spec:
  amiFamily: AL2 # Amazon Linux 2
  role: "KarpenterNodeRole-A" # replace with your cluster name

  subnetSelectorTerms:
    - tags:
        karpenter.sh/discovery: "A" # replace with your cluster name
  securityGroupSelectorTerms:
    # NodeClass에 의한 신규 Node 생성시, 여기 기술된 tag를 가지고있는 기존 보안그룹이 신규Node에 등록된다.
    - tags:
        karpenter.sh/discovery: "A" # replace with your cluster name
  tags:
    # EC2 인스턴스에 지정될 정산 및 정보 라벨
    Service: ${MY_SVC_NAME}
    Owner: ${MY_MAIL}

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
        # 용도별 노드 라벨 
        app.webzen.com/name: eks-platform-common
    spec:
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
      nodeClassRef:
        name: eks-platform-common
  limits:
    cpu: 240  # 8 코어 x 30 대
    memory: 480Gi  # 16GiB x 30 대
  disruption:
    # 다른 노드와의 통합정책 (비용절감 목적)
    ## WhenUnderutilized: 저활용 상황시 노드 삭제(cpu, ram, pod 수로 판단=>커스텀 불가=>https://github.com/kubernetes-sigs/karpenter/issues/735)
    ## WhenEmpty: 미사용 상황시 노드 삭제(daemonset에 의한 pod 1개만 있어도 empty가 아님)
    consolidationPolicy: WhenUnderutilized
    
    # 노드가 비었을 때 지정 대기 시간 후 통합 작업 시작(노드 삭제)
    ## consolidationPolicy가 WhenEmpty일 때만 사용가능한 속성
    ## Never: 통합(consolidation) 비활성화
    # consolidateAfter: 720h  

    # 노드 만료 시간설정 (보안 이슈 대비하여 만료정책이 기본적으로 있음)
    expireAfter: 720h # 1m  # 720h  # Never  # 미할당시 default 720h

    # NodePool 업데이트시 현재 대상 노드에도 즉시 적용되는 것 같음. 노드 재부팅 불필요
    # 꺼지면 안되는 앱=> 앱 자체에서 retry나 HA구성을 잘 해놓던가 아니면 WhenEmpty에 consolidateAfter와 expireAfter를 Never로 설정해야 함
```

## 꺼지면 안되는 노드

```yaml
apiVersion: karpenter.k8s.aws/v1beta1
kind: EC2NodeClass
metadata:
  # 서비스와 용도에 맞는 이름
  name: eks-monitor
spec:
  amiFamily: AL2 # Amazon Linux 2
  role: "KarpenterNodeRole-A" # replace with your cluster name

  subnetSelectorTerms:
    - tags:
        karpenter.sh/discovery: "A" # replace with your cluster name
  securityGroupSelectorTerms:
    # NodeClass에 의한 신규 Node 생성시, 여기 기술된 tag를 가지고있는 기존 보안그룹이 신규Node에 등록된다.
    - tags:
        karpenter.sh/discovery: "A" # replace with your cluster name
  tags:
    # EC2 인스턴스에 지정될 정산 및 정보 라벨
    Service: ${MY_SVC_NAME}
    Owner: ${MY_MAIL}

---
apiVersion: karpenter.sh/v1beta1
kind: NodePool
metadata:
  # 서비스와 용도에 맞는 이름
  name: eks-monitor
spec:
  template:
    metadata:
      labels:
        # 용도별 노드 라벨 
        app.webzen.com/name: eks-monitor
    spec:
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
      nodeClassRef:
        name: eks-platform-common
  limits:
    cpu: 24
    memory: 80Gi
  disruption:
    consolidationPolicy: WhenEmpty  # 단 하나의 daemonset 기반 pod가 남아있어도 노드 끄지않는다.
    consolidateAfter: Never  # WhenEmpty 조건 만족시 노드 종료 전 대기시간. Never는 노드를 끄지 않겠다는 의미
    expireAfter: Never # 기본 만료정책도 제거
    # Loki, Prometheus가 꺼지면 안됨 (ETL 헬스체크 로그누락 방지)


    # NodePool 업데이트시 현재 대상 노드에도 즉시 적용되는 것 같음. 노드 재부팅 불필요
    # 꺼지면 안되는 앱=> 앱 자체에서 retry나 HA구성을 잘 해놓던가 아니면 WhenEmpty에 consolidateAfter와 expireAfter를 Never로 설정해야 함
```