# EKS 접근제어 및 Pod 권한 (2025.09.)

권한설정시 헷갈리는 부분이 있으므로 간략한 맥락을 별도 정리

## 1. 클러스터 접근 제어

- 목적: 실제User 또는 일부 앱에서 사용하는 시스템User의 클러스터 접근권한 관리
- 기존: aws-auth ConfigMap (`deprecated` 예정)
- 신규: EKS API AccessEntry
- 콘솔 → 클러스터 → "액세스" 메뉴에서 관리
- 현재시점 신규 클러스터에서 대응방법
  - ConfigMap + AccessEntry 둘 다 가능하도록 설정해두면, 둘 중 하나만 허용돼도 권한부여 가능
  - 일부 서드파티앱에서 필요한 시스템User(system:node:{{EC2PrivateDNSName}})는 ConfigMap방식으로만 등록가능
  - 실제 User(yunan_all 등)는  aws-auth에 등록하지 않는 것을 추천드립니다.

## 2. Pod 권한 부여

- 목적: Pod 내부에서 AWS Credential 사용
- IRSA (기존)
  - OIDC Provider 필요
  - ServiceAccount ↔ IAM Role 연동
- Pod Identity (신규)
  - OIDC Provider 불필요, 애드온 Agent 필요
  - 콘솔 → 클러스터 → "액세스" 메뉴에서 관리
  - 또는 `PodIdentityAssociation`리소스로 Pod ↔ IAM Role 연결 (쿠버네티스 리소스처럼 생성할 수 있지만, aws에서만 보이는 리소스)
  - 관리 단순, 향후 표준 권장
- 현재시점 신규 클러스터에서 대응방법
  - 현재 서드파티앱 문서에서 IRSA 기준 가이드만 제공하는 경우가 많으나, Pod identity 설정으로 처리 가능합니다.
  - IRSA 방식도 향후 지속적으로 유지되므로 어떤 방식을 쓰든 문제는 없습니다.