# Helm (헬름)

쿠버네티스 애플리케이션을 패키징하고 배포하기 위한 도구

## 설치

- [공홈설치방법](https://helm.sh/docs/intro/install/)
- apt 설치

```sh
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
sudo apt-get install apt-transport-https --yes
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install helm
```

## 사전준비

- K8s 클러스터
- helm에 대상 클러스터 정보 등록
  - Minikube
    - minikube는 start시 helm과 자동 연동된다
  - K3s

    ```sh
    # Helm에 로컬 K3s 클러스터 정보 인식 (이는 default를 변경하는 것)
    # ~/.bashrc에 추가해두자
    export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
    ```

- Minikube와 K3s 둘 다 설치된 경우, 대상 클러스터(컨텍스트) 전환방법
  - 이 때 kubectl은 `.kube/config`에 있는 파일을 참조하는 것이기 때문에, minikube든 k3s든 어떤 kubectl을 써도 상관없다.

  ```sh
  # 컨텍스트(클러스터) 목록 확인
  kubectl config get-contexts
  # 컨텍스트를 default(K3s)로 변경
  kubectl config use-context default
  # 컨텍스트를 minikube로 변경
  kubectl config use-context minikube
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
- [bitnami에서 제공하는 Helm Repository](https://charts.bitnami.com/)

## 커맨드

### helm repo (저장소 관리)

```sh
# 외부 저장소를 로컬 저장소로 추가 예시
# helm repo add {저장소 이름alias 지정} {Helm Repository URL}
helm repo add bitnami https://charts.bitnami.com/bitnami

# 추가한 로컬 저장소 목록 조회
helm repo list

# 로컬 저장소의 차트 버전을 최신화(인터넷 연결 필요)
helm repo update
```

### helm search (Chart 검색)

```sh
# 로컬 저장소로부터 설치가능한 차트 조회
helm search repo

# 특정 로컬 저장소에서 설치가능한 차트 조회
# helm search repo {로컬 저장소 이름}
helm search repo bitnami

# Helm Hub(공식 헬름 저장소)에서 설치가능한 차트 조회
helm search hub
```

### Chart 설치/조회/삭제

```sh
# chart 설치 (release 생성, cluster를 구성)
# helm install {릴리즈 이름 지정} {차트 경로or 파일}
helm install my-release bitnami/kafka

# 차트에 커스텀 설정을 Override하여 설치 (f옵션)
helm install -f {value.yml} {릴리즈 이름 지정} {차트 경로or 파일}
helm install my-release bitnami/kafka -f myvalue.yml

# 설치되어 실행중인 release 목록 조회
helm list

# 릴리즈 삭제
# helm uninstall {릴리즈 이름}
helm uninstall my-release
```

### 커스텀 Chart 관리

- `helm create {차트이름}`
  - 커스텀 차트 만들기
  - 초기 작업을 위한 템플릿 및 디렉토리를 생성

- `helm dependency update`
  - chart.yaml 파일이 있는 곳에서 실행
  - 동일 경로에 Chart.lock과 charts/ 생성됨
    - `chart/`:  chart.yaml에 기술된 dependency chart 아카이브파일들이 다운로드되는 곳
    - `Chart.lock`: chart.yaml에 기술된 dependency 버전 범위 중 자동선택된 최종배포버전이 기술됨
- `helm package {차트 경로}`
  - '템플릿', '변수', '값', '구성파일' 등 리소스가 모여있는 디렉토리를 지정하여 사용
  - 배포가능한 하나의 차트파일(tar압축)로 생성함

- `helm template -f {value.yml} {릴리즈 이름 지정} {차트 경로or 파일}`
  - helm install 커맨드와 동일 형식으로 사용
  - 최종 배포시 적용되는 설정파일을 stdout으로 확인가능
  - 일종의 디버그 용도로 사용가능
- `helm show values {chart이름}`
  - 해당 차트의 default value를 확인
  - 이를 토대로 커스텀 value파일을 생성하면 된다.

## 컴퓨팅 리소스 관리

- 개별 Pod가 점유할 리소스를 관리할 필요가 있음
- 배포되는 대부분 helm chart들은 value.yaml 파일에서 다음 key로 컴퓨팅 리소스를 제어할 수 있도록 지원한다.
  - `resources.requests`: 최소 요구사항
  - `requests.limits`: 맥시멈 제한
  - `persistence`: 스토리지
    - pvc 스토리지 용량은 한번 지정하면 변경하기가 까다로우니 배포 직전까지 검토를 잘 하자
  - helm 툴에서 default로 지원하는 것은 아니고, helm chart 배포자가 template으로 구현한 것이다.
  - K8s 용어가 위 key들과 같아서 관례적으로 template을 만들 때 해당 이름들을 사용하는 것이다.
  - 따라서 차트마다 방법이 조금씩 다를 수 있으므로 artifact hub 또는 helm show values {chart이름} 명령어로 value파일 포맷을 확인하자.
  - 만약 해당 key가 보이지 않는다면, 참조하는 dependency차트를 찾아보면 있을 가능성이 높다. (template은 override하는 개념이므로)

- 적용 확인
  - resources는 `kubectl describe`했을 때 Containers 항목 아래에서 찾을 수 있음
  - persistence는 `kubectl get pvc`로 확인 가능
