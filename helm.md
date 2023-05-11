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
    - Helm으로 배포하는 것을 "설치한다(install)"고 표현


## Helm (Chart) Repository
- Helm Chart를 저장 및 공유하는 공간
- Helm에선 개별 패키지를 Chart, Chart들이 모인 곳을 Repository라고 칭함(Hub, Registry는 덜 쓰이는 표현)
- 공식 외에도 사용자, 조직이 개별 생성하여 관리 가능
- [Official Helm Repository](https://hub.helm.sh/)
- [bitnami에서 제공하는 Helm Repository](https://charts.bitnami.com/bitnami)
```
# 외부 저장소(bitnami) 가져오기 예시
helm repo add bitnami https://charts.bitnami.com/bitnami

# 외부 저장소(bitnami) 설치가능 Chart 목록 확인
helm search repo bitnami

# 로컬 저장소 업데이트
helm repo update

# chart 설치 (클러스터를 구성)
# e.g. helm install my-release bitnami/kafka
helm install {관리할 이름} {차트 이름}

# chart 삭제
# e.g. helm uninstall my-release
helm uninstall {관리할 이름}

# 실행 중인 차트 목록
helm list
```