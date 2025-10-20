# AWS ECR(Elastic Container Registry)

- AWS 제공 이미지 저장소(레지스트리) 서비스
- EKS 사용시 ECR 사용하는 것이 가장 안정적이고 편함
- NodeInstanceRole에 `AmazonEC2ContainerRegistryReadOnly` 정책 필요
  - 일반적으로 노드의 기본권한 설정할 때 포함되는 경우가 많아서 크게 신경쓰지 않아도 됨
- 프록시 저장소 기능도 사용가능(default: 비활성화)
- 자주 쓰는 커스텀 이미지는 별도 push 해두면 됨

