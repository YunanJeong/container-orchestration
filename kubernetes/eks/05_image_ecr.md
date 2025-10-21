# AWS ECR(Elastic Container Registry)

- AWS 제공 이미지 저장소(레지스트리) 서비스
- EKS 사용시 ECR 사용하는 것이 가장 안정적이고 편함
- NodeInstanceRole에 `AmazonEC2ContainerRegistryReadOnly` 정책 필요
  - 일반적으로 노드의 기본권한 설정할 때 포함되는 경우가 많아서 크게 신경쓰지 않아도 됨
- 프록시 저장소 기능도 사용가능(default: 비활성화)
- 자주 쓰는 커스텀 이미지는 별도 push 해두면 됨

## 로컬에 있는 이미지를 ECR에 push하기

- docker cli로 접근가능
- 저장소 주소는 AWS account id, region 기반의 DNS
- docker login할 때 `awscli로 발급받은 토큰` 필요
- awscli의 액세스키 권한엔 `AmazonEC2ContainerRegistryPowerUser` 정책 필요

```sh
ACCOUNT_ID=000000000000
REGION=ap-northeast-2

# 1. 이미지 pull
docker pull quay.io/prometheus/node-exporter:v1.8.2

# 2. ECR 로그인(AWS CLI로 임시토큰 발급받아 그대로 넘기기)
aws ecr get-login-password --region ${REGION} \
| docker login --username AWS --password-stdin ${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com

# 3. ECR 리포지토리 생성 (처음만 하면 됨, push할 때 자동생성안됨)
aws ecr create-repository --repository-name quay-prometheus/node-exporter

# 4. 태그 변경
docker tag quay.io/prometheus/node-exporter:v1.8.2 \
${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/quay-prometheus/node-exporter:v1.8.2

# 5. 푸시
docker push ${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/quay-prometheus/node-exporter:v1.8.2
```
