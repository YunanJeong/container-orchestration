# Helm (헬름)
쿠버네티스 애플리케이션을 패키징하고 배포하기 위한 도구
# 시작하기
## 설치
- [공홈설치방법](https://helm.sh/docs/intro/install/)
- apt 설치
```
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
sudo apt-get install apt-transport-https --yes
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install helm
```
## 사전준비
- K8s 클러스터
- helm에 대상 클러스터 정보 등록
    - 배포판 및 환경마다 설정 방법이 조금씩 다름
    ```
    # Helm에 로컬 K3s 클러스터 정보 인식
    export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
    ```

## Helm Charts (헬름 차트, 차트)
- Helms에서의 패키지를 의미
- Helm으로 관리되는 K8s App.의 배포 단위
- '템플릿', '변수', '값', '구성파일' 등의 리소스로 구성됨
    - 템플릿: K8s Object를 생성하는 데 사용
    - 변수, 값: 템플릿에서 사용되는 파라미터들을 정의하고 설정
    - 구성파일: 템플릿과 변수를 결합하여 실제로 배포될 K8s 리소스 생성시 사용
- Release
    - Chart를 설치하여 생성된 인스턴스
    - Helm으로 클러스터를 배포하는 것을 "설치한다(install)"고 표현


## Helm (Chart) Repository
- Helm Chart를 저장 및 공유하는 공간
- Helm에선 개별 패키지를 Chart, Chart들이 모인 곳을 Repository라고 칭함(Hub, Registry는 덜 쓰이는 표현)
- 공식 외에도 사용자, 조직이 개별 생성하여 관리 가능
- [Helm Hub: Official Helm Repository](https://hub.helm.sh/)
- [bitnami에서 제공하는 Helm Repository](https://charts.bitnami.com/bitnami)

## 커맨드
### helm repo (저장소 관리)
- helm repo add {저장소 이름 지정} {Helm Repository URL}
    ```
    # 외부 저장소를 로컬 저장소로 추가
    helm repo add bitnami https://charts.bitnami.com/bitnami
    ```
- helm repo list
    ```
    # 추가한 로컬 저장소 목록 조회
    ```
- helm repo update
    ```
    # 로컬 저장소의 차트 버전을 최신화(인터넷 연결)
    ```

### helm search (Chart 검색)
- helm search repo
    ```
    # 로컬 저장소로부터 설치가능한 차트 조회
    ```
- helm search repo {로컬 저장소 이름}
    ```
    # 특정 로컬 저장소에서 설치가능한 차트 조회
    helm search repo bitnami
    ```
- helm search hub
    ```
    # Helm Hub(공식 헬름 저장소)에서 설치가능한 차트 조회
    ```

### Chart 설치/조회/삭제
- helm install {릴리즈 이름 지정} {차트 이름}
    ```
    # chart 설치 (release 생성, cluster를 구성)
    helm install my-release bitnami/kafka
    ```
- helm list
    ```
    # 설치되어 실행중인 release 목록 조회
    ```
- helm uninstall {릴리즈 이름}
    ```
    # 릴리즈 삭제
    helm uninstall my-release
    ```
