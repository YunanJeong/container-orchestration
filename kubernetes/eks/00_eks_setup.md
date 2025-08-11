# eks 구축

## 운영 기본 체크리스트

- 사용자/팀 권한: Access Entries로 역할·정책·네임스페이스 범위 지정 ①②
- 워크로드 IAM: Pod Identity 선호(Agent 필요, 노드 역할에 AssumeRoleForPodIdentity 허용)
- 스토리지: aws-ebs-csi-driver(EKS Add-on)
- 노드 자동화: Karpenter (Provisioner 정책으로 인스턴스·용량타입 제한)
  - v1 정식 출시부터 Auto Mode 활성화시 karpenter가 기본탑재된다. (pod는 안보임)
  - nodepool, nodeclass CRD를 `kubectl get crd`에서 확인가능
- 외부노출: AWS Load Balancer Controller(Helm)
- 모니터링: metrics-server(EKS 커뮤니티 Add-on)
- 애드온 호환성/버전 확인: `describe-addon-versions` API로 확인

## 접근제어 (액세스)

- AWS콘솔의 클러스터 설정에서 '액세스' 메뉴
- 인증모드 선택
  - EKS API(Access Entry): AWS콘솔에서 중앙집중식 관리가능
  - ConfigMap: deprecated. 
  - 동시 사용 가능. 둘 중에 하나만 등록되면 접근가능.
- 클러스터에 IAM User를 등록하여 접근권한을 부여하는 방식
- EKS API가 좀 더 편리하므로 EKS API 기준으로 기술

- aws-auth라는 ConfigMap이 있는데 AWS 상의 IAM User와 쿠버네티스 User를 매핑하는 역할, 여기에 IAM User를 등록. 각 User 별 권한은 AWS콘솔에서 설정

## 쿠버네티스 RBAC 설정

- EKS 인증모드를 EKS API로 해도 실제 쿠버네티스 RBAC은 그대로 적용되기 때문에, 특정 유저에게 RBAC 권한을 부여해야 함
- 