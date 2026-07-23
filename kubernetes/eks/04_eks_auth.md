# EKS 접근제어 및 Pod 권한 (2026.07.)

권한설정시 헷갈리는 부분이 있으므로 간략한 맥락을 별도 정리

## 1. 클러스터 접근 제어

- 목적: 실제User 또는 일부 앱에서 사용하는 시스템User의 클러스터 접근권한 관리
- 기존: aws-auth ConfigMap (`deprecated` 예정)
- 신규: EKS API AccessEntry
- 콘솔 → 클러스터 → "액세스" 메뉴에서 관리
- 현재시점 신규 클러스터에서 대응방법
  - ConfigMap + AccessEntry 둘 다 가능하도록 설정해두면, 둘 중 하나만 허용돼도 권한부여 가능
  - 일부 서드파티앱에서 필요한 시스템User(system:node:{{EC2PrivateDNSName}})는 ConfigMap방식으로만 등록가능
  - 실제 User(yunan_all 등)는  aws-auth에 등록하지 않는 것을 추천

## 2. 워크로드(클러스터 내 파드·노드 등 실행 주체)에 AWS 권한 부여 (IRSA / Pod Identity / 노드 role)

목적: Pod(또는 노드)가 내부에서 AWS Credential(권한)을 사용

### 세 방식 비교

| 방식 | 권한이 붙는 대상 | 권한 경계 |
|------|-----------------|----------|
| **IRSA** | ServiceAccount(파드) | 파드별 |
| **Pod Identity** | ServiceAccount(파드) | 파드별 |
| **노드 role (PassRole)** | EC2 인스턴스(노드) | 노드별 (그 노드 위 모든 파드가 공유) |

- **IRSA ↔ Pod Identity = 서로 대체 관계** (둘 다 파드별, 방식만 다름).
- **노드 role = 다른 계층** (파드별이 아니라 노드별).

### IRSA (기존)

- 파드가 권한 받을 때 **AWS STS 서버와 외부 통신**해서 자격증명 교환.
  - STS = AWS의 자격증명 발급 서버(Security Token Service, `sts.amazonaws.com`).
  - OIDC = 서버가 아니라 신원 증명 **방식**(구글 로그인 같은 것). "STS에 OIDC 방식으로 신분 증명"이 정확.
- 필요: OIDC Provider(IAM에 등록하는 신뢰 설정, 서버 아님) + SA에 `role-arn` annotation.
- **약점: 이 외부 통신(파드→STS)에 의존** → 통신 지연·실패 시 권한 못 받는 경우 있음. 세팅도 번거로움.

### Pod Identity (신규, 권장)

- **IRSA의 외부 통신(STS/OIDC 왕복)을 없앤 것이 핵심.** 노드의 pod-identity-agent 애드온이 로컬에서 자격증명 중개 → 더 안정적.
- OIDC Provider 불필요, annotation 불필요.
- 구조: **IAM Role ── PodIdentityAssociation("이 namespace+SA = 이 role" 매핑) ── ServiceAccount ── Pod**
  - SA는 **순수 k8s 리소스**(AWS 정보 안 지님). 매핑은 밖에서 association이 함.
  - association은 콘솔(클러스터 → "액세스" 메뉴) 또는 리소스로 생성. **연결 열쇠 = (namespace + SA 이름) 일치.**
- 콘솔+Helm 설정: ①IAM role 생성(신뢰=`pods.eks.amazonaws.com`) → ②Access 탭에서 association(role↔namespace+SA) → ③Helm에서 그 SA 이름으로 배포.

### 노드 role (Karpenter와 PassRole)

- PassRole은 Karpenter 전용이 아니라 "role을 EC2 등에 장착할 때 필요한 AWS 공통 권한"이다. 관리형 노드그룹 등에선 EKS가 알아서 처리하지만, Karpenter는 노드를 만드는 주체가 사용자 컨트롤러라 그 컨트롤러 IAM에 PassRole을 직접 챙겨야 하는 사례.
- Karpenter 컨트롤러가 노드를 만들 때, EC2NodeClass에 지정된 노드 role을 그 노드에 장착(pass)한다.
  - 이때 컨트롤러 IAM 정책에 `iam:PassRole` 권한(대상 = 그 노드 role)이 있어야 장착 가능. 없으면 노드 생성 실패.
  - **컨트롤러가 pass할 수 있는 노드 role은, 컨트롤러 IAM의 PassRole 대상에 등록된 것만.** 그래서 새 노드 role을 쓰려면 그 role을 대상으로 하는 PassRole을 컨트롤러 IAM에 추가해야 함.
  - (설치 방식별) Terraform terraform-aws-modules 서브모듈은 기본 `KarpenterNode` role에 대한 PassRole을 자동 포함. eksctl/콘솔로 구성했다면 이 PassRole도 직접 넣어야 함.
  - 한 클러스터에서 노드마다 다른 권한이 필요할 수 있으므로, 용도별 노드 role마다 PassRole을 추가하는 식.
- 노드에 할당된 role은 해당 노드에서 실행되는 모든 pod에게 공유됨
  - pod가 IMDS를 통해 자격증명 획득
  - IMDS = EC2 내부 전용 주소(`169.254.169.254`)로 접속하면 그 인스턴스 정보·자격증명을 돌려주는 AWS 내장 기능.

### 용도별 권한 분리

- **원칙: 노드 단위 권한 부여보다 Pod Identity(파드별)가 가장 권장됨.** 파드마다 최소 권한을 정확히 줄 수 있고(최소권한), 같은 노드에 섞여도 권한이 안 섞임. 노드 role 방식은 그 노드 파드가 권한을 다 공유해 경계가 거침.
- **권한만 다르면 됨 → Pod Identity** (노드 안 쪼개고 파드별 association).
- **노드 자체를 격리해야 하면 → 노드 role 분리** (용도별 NodeClass+role + 컨트롤러 다중 PassRole + 파드 배치 제어). 전용 노드풀·컴플라이언스 격리 등 특수한 경우에만.
- ❌ 한 노드 role에 정책 다 몰기 = 그 노드 모든 파드가 전 권한 공유 → 분리 깨짐.

### 현재시점 신규 클러스터 대응

- 서드파티앱 문서가 IRSA 기준만 제공해도 **Pod Identity로 처리 가능.**
- IRSA방식도 deprecated되지않고 계속 사용가능해서 어떤 방식이든 문제 없음.
- 신규는 **Pod Identity 권장**(외부 통신 의존 없고 세팅 단순).