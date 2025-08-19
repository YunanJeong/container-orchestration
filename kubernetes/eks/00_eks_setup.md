# eks 구축

## 운영 기본 체크리스트

- 사용자/팀 권한: Access Entries로 역할·정책·네임스페이스 범위 지정 ①②
- 워크로드 IAM 권한부여방식(둘 중 택1하여 설정)
  - Pod Identity
    - 애드온으로 Agent 필요
    - 노드 역할에 AssumeRoleForPodIdentity 권한필요 (AmazonEKSWorkerNodePolicy 등에 포함됨)
    - AWS 최신 방식
  - IRSA
    - AWS 외 쿠버네티스 표준에 맞음 => AWS에서 지속 지원 예정
    - OIDC Provider 설치절차 필요
    - 전반적으로 더 번거로운 방식
- 스토리지: aws-ebs-csi-driver(EKS Add-on으로 설치, 권한 필요. 하단 참조)
- 노드 관리 자동화(Karpenter 및 AutoMode 활성화 여부 선택)
- 외부노출: AWS Load Balancer Controller(Helm으로 설치)
- 모니터링: metrics-server(EKS Add-on으로 설치)
- 애드온 호환성/버전 확인: `describe-addon-versions` API로 확인

## IAM User 및 IAM Role의 권한 Policy를 고르는 방법

- 채택한 리소스 구성 및 옵션에 따라 요구되는 권한정책이 다를 수 있음
- 콘솔에서 리소스 생성시 IAM Role 선택메뉴에서 `"권장 역할 생성"`기능을 사용하는게 좋다. 자동으로 필요한 Policy가 이미 선택되어 있음
- cli 기반 작업을 하더라도 신규버전 구축시에는 위 과정을 통해 권장 역할을 확인하는 것이 좋음. `레거시 자료를 참고할 경우 미묘하게 요구되는 Policy가 다를 수 있음`

## 기본 추가기능(Add-on)

- `eksctl create addon` 또는 AWS콘솔에서 설치가능
- 클러스터 관리를 위해 자주 쓰이는 앱을 즉시 설치/제어할 수 있도록 AWS에서 지원하는 것이며, 애드온 설치시 실제론 클러스터 내부에서 deployment, daemonset 등으로 배포되는 것을 확인가능
- 꼭 애드온으로 설치하지 않아도 된다.
- daemonset으로 배포되는 애드온의 경우, 설치 후 pod가 안뜰수도 있는데 기본 노드에 taint가 아무앱이나 설치되지 않도록 NoSchedule로 걸려있고, 애드온 daemonset엔 toleration이 없어서 그렇다. EKS의 기본철학이 최초 기본노드는 아무거나 설치되지 않도록 막고, 실제 앱은 별도 워커노드를 하나 더 생성한다는 기조이기 때문. 필요에 따라 적절히 바꿔주자.
- 필수급 애드온
  - Amazon VPC CNI(aws-node)
    - Pod identity or IRSA로 IAM Role 연동 필요
    - Role에 필요한 정책: AmazonEKS_CNI_Policy, AmazonEKSClusterPolicy
  - Amazon EBS CSI Driver
    - Pod identity or IRSA로 IAM Role 연동 필요
    - Role에 필요한 정책: AmazonEBSCSIDriverPolicy
  - kube-proxy
  - metrics-server(지표서버)
  - CoreDNS
- 기타 애드온
  - Node Monitoring Agent
    - 별도 추가설정없이 설치만해도 CloudWatch에서 모니터링 가능
    - 비용발생
    - 미설치시 Cloudwatch에서 EKS 리소스항목은 표기되지만, 값이 존재하지 않음
  - node-exporter(애드온으로 설치 비권장)
    - prometheus 미포함
    - ServiceMonitor활용을 위해선 kube-prometheus-stack 헬름차트로 별도 설치하는게 나음
  - kube-state-metrics(애드온으로 설치 비권장)
    - node-exporter와 동일한 이유로 kube-prometheus-stack으로 설치 권장
  - fluent-bit (필요시 설치)

## 접근제어 (액세스)

- AWS콘솔의 클러스터 설정에서 '액세스' 메뉴
- 인증모드 선택
  - EKS API(Access Entry): AWS콘솔에서 중앙집중식 관리가능
  - ConfigMap: deprecated.
  - 동시 사용 가능. 둘 중에 하나만 등록되면 접근가능.
- 클러스터에 IAM User를 등록하여 접근권한을 부여하는 방식
- EKS API가 좀 더 편리하므로 EKS API 기준으로 기술
<!-- - aws-auth라는 ConfigMap이 있는데 AWS 상의 IAM User와 쿠버네티스 User를 매핑하는 역할, 여기에 IAM User를 등록. 각 User 별 권한은 AWS콘솔에서 설정 -->
- EKS API 방식의 경우 각 IAM User(EKS 실 사용자)에 다음 최소 권한만 똑같이 할당해놓으면 된다. 이후 세부 권한은 해당 EKS의 콘솔 메뉴에서 중앙제어하면 됨

```yaml
# EKS API로 관리시 IAM User에 등록해놓을 최소 권한
{
  "Effect": "Allow",
  "Action": [
    "eks:DescribeCluster",
    "eks:ListClusters",
    "eks:AccessKubernetesApi"
  ],
  "Resource": "*"
}
```

<!-- ## 쿠버네티스 RBAC 설정

- EKS 인증모드를 EKS API로 해도 실제 쿠버네티스 RBAC은 그대로 적용되기 때문에, 특정 유저에게 RBAC 권한을 부여해야 함 -->

## 노드 관리 자동화 (Karpenter 및 AutoMode 활성화 여부 선택)

Karpenter (Provisioner 정책으로 인스턴스·용량타입 제한)

### Auto Mode 활성화시

- **전반적으로 자동화 Up, 비용 Up, 자유도 Down**
- 인스턴스 비용 12% 비쌈
- DevOps 전문가가 없거나, K8s에 대한 지식이 거의 없다면 써도 좋음
- **karpenter가 v1 정식 출시부터 Auto Mode EKS의 controlplane 영역에 기본 내장됨**
  - aws managed 영역이라 pod는 안보이지만, nodepool, nodeclass CRD를 `kubectl get crd`에서 확인가능
- 이미 Karpenter 구성을 쓰는 조직이라면 아직 좀 애매한듯
- 상황에 따라 요구되는 nodepool이 자동 생성/삭제/관리되며, 커스텀 생성한 nodepool은 삭제되지 않음
- 사용가능한 AMI 고정(BottleRocket)
  - 클러스터 필수 애드온은 해당 AMI 내 systemd 서비스로 구현됨
- K8s, EKS, Karpenter, 필수 애드온의 버전 호환성 자동관리
  - 21일마다 노드 재시작 강제 업데이트
  - 노드 고정 필요시, nodegroup 혼합 사용 가능
  - nodegroup 인스턴스쪽에는 종전과 같이 필수 애드온이 K8s 리소스로 배포됨

### Auto Mode 비활성화시, Helm Chart로 Karpenter 수동설치

