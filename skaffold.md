# Skaffold
- 컨테이너 기반 및 Kubernetes 애플리케이션의 지속적인 개발을 촉진하는 CLI 툴
- K8s 앱의 지속적 배포를 위한 구글 자체 툴

## 쓰는 이유
- 로컬에서 빠른 K8s 개발
    - 일반적으로 컨테이너 내부를 사소하게라도 수정하면, 다음과 같은 과정을 거쳐야 하는데, skaffold는 이를 자동화해준다.(지속적 배포, CD)
        - 소스코드 or DockerFile 수정
        - 이미지 build
        - 이미지 push
        - K8s앱 실행
- skaffold로 최종 배포도 가능하지만 **개발 중 사용목적이 더 크다.**
    - 배포는 kubectl, helm 등과의 연동을 공식지원하며, GoogleCloud, Gitops 등으로도 가능하다.
- `skaffold.yaml`
    - 설정 파일 딱 한 개만 필요하고 나머지는 cli커맨드로 제어
- 가벼움(client-side only): K8s 클러스터측에 설치해야하는 에이전트가 없음
- 클러스터 실행시 환경변수 전달에 용이 (AWS_KEY 등 전달시 편함)

## 예제
```
git clone https://github.com/GoogleContainerTools/skaffold
```
- 위 저장소의 examples 디렉토리에 유형 별 배포 예시가 제공됨
- docker, helm, kustomize, 클라우드 등 **배포방법에 따라 디렉토리 구성 및 skaffold.yaml 설정을 알 수 있어서 좋음**
- 또, react, ruby, nodejs 등 K8s앱 유형 별 예시도 있음

## 문서
- https://skaffold.dev/docs/

## 설치
```
# For Linux x86_64 (amd64)
curl -Lo skaffold https://storage.googleapis.com/skaffold/releases/latest/skaffold-linux-amd64 && \
sudo install skaffold /usr/local/bin/
```
## 용어
- Pipeline
    - Skaffold에서 앱 개발 및 배포 과정을 단계별로 정의하는 개념
- Artifact
    - 사실상 `skaffold.yaml`에 기술된 편집 및 빌드할 대상 이미지를 가리킴
    - 빌드된 앱의 결과물, 또는 빌드 및 배포 과정 전후에 필요한 모든 파일들을 의미 (소스코드, 디펜던시, 생성된 파일, 패키지, 컨테이너 이미지 등)

---
# Practice
- K8s 클러스터가 1개 이상 켜져 있어야 함
- 주로 사용하는 커맨드 위주로 기술    
    - `skaffold dev`와 `skaffold build`만 잘 써도 개발시 매우 편리
    - 배포, 실행 등도 가능하나 라이브 환경에서는 helm으로 처리하는 것을 상정한다.

## 커맨드
- `skaffold init`
    - 하위 디렉토리들을 조회하여 그에 맞는 `skaffold.yaml`파일 생성
    - 새로 작업시작할 때만 사용, 이미 `skaffold.yaml`이 있으면 안해도 됨

### End-to-end Pipelines
파이프라인의 모든 단계를 한 번에 수행하는 명령어들

- `skaffold dev`
    - 개발모드로 실행
    - 터미널에서 실행시 세션을 점유하고, 대기상태가 된다.
        - 이 때 에디터에서 Dockerfile 및 기타 파일 등을 수정하면 즉시 반영
        - 컨테이너 내부용 코드도 즉시 반영
    - dev모드의 변경내역이 실제환경에 반영되면 안되므로, 로컬 레지스트리에서 컨테이너 이미지가 처리된다.
        - 따라서, minikube를 쓰는 것이 편하다.
        - K3s에서 개발모드를 쓰려면 로컬 도커 레지스트리나 개별 레지스트리를 가리키도록 추가 설정 필요
    - build 과정을 포함하고, build 옵션을 쓸 수 있다.
        - build되지 않으면 개발모드 실행이 되지 않는다.
        - 이에따라 개발작업 중 꾸준히 빌드가능한 상태를 유지할 수 있는 이점이 있다.

- `skaffold run`
    - 파이프라인 전체 실행
    - skaffold 프로젝트를 타인에게 배포할 때 skaffold run 명령어 하나만으로 실행가능하도록 해준다.
    - 실행결과를 kubectl, k9s 등으로 확인해보자.
    - `skaffold delete`로 설치된 앱(K8s 오브젝트)을 삭제가능

- skaffold debug
    - 디버그 모드 실행. 사전 디버깅 지점 설정 또는 설정 파일 필요.

### Pipeline Building Blocks
파이프라인의 특정 단계만 수행하는 명령어들
- `skaffold build`
    - `skaffold.init의 build.artifacts`에 기술한 이미지들을 빌드한다.
    - 아래 옵션은 build를 포함하는 다른 명령어 수행시에도 적용가능하다. 태그와 저장소를 주의하여 명시하자.
    - `--tag={x.x.x}`: 빌드할 때 태그 지정. 미지정시 랜덤
    - `--default-repo={registry IP addr}}`: 어느 저장소에 저장할 것인가 지정
    - `--push`: 대상 저장소가 원격이면 필요한 옵션
    - 예시
    ```
    # minikube 사용시 빌드
    skaffold build
    
    # 결과물은 minikube 내부 로컬 레지스트리에서 확인가능
    minikube ssh
    docker image ls
    ```
    ```
    # e.g. 로컬호스트의 도커 레지스트리에 결과물을 남기고 싶은 경우 (K3s사용시)
    skaffold build --tag=0.1.0 --default-repo=127.0.0.0/8
    ```
    ```
    # e.g. 원격 사설 레지스트리(docker.my)에 결과물을 남기고 싶은 경우(push)
    skaffold build --tag=0.1.0 --default-repo=docker.my/yunanj --push

    # e.g. 공식 레지스트리(docker.io)에 결과물을 남기고 싶은경우 (push)
    skaffold build --tag=0.1.0 --push
    ```

- `skaffold deploy --images {IMAGE}:{TAG}`
    - 사전 빌드된 artifact(이미지)로 K8s앱을 실행한다.

- `skaffold delete`
    - skaffold로 설치&배포된 모든 리소스를 삭제
    - Production 환경에서 쓰지 않도록 주의

- 이 외에 test, apply, verify 등이 있음


### 참고
- DockerFile에 apt설치 구문을 추가했는데 skaffold build, dev에서 반영되지 않는 경우
    - 특정 dependency를 처리하지 못해, 설치가 취소된 것일 수 있다. FROM 이미지 교체하거나 따로 대응 필요
