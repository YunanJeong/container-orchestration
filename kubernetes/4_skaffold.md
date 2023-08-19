# Skaffold

컨테이너 기반 및 K8s 앱의 지속적 배포 & 지속적 개발을 촉진하는 CLI 툴 (구글 제공)

## 설치

```sh
# For Linux x86_64 (amd64)
curl -Lo skaffold https://storage.googleapis.com/skaffold/releases/latest/skaffold-linux-amd64 && \
sudo install skaffold /usr/local/bin/
```

## 쓰는 이유

- 로컬에서 빠른 K8s 개발
  - 일반적으로 컨테이너 내부를 사소하게라도 수정하면, 다음 과정을 거쳐야 하는데, skaffold는 이를 자동화한다.(지속적 배포, CD)
    1. 소스코드 or DockerFile 수정
    2. 이미지 build
    3. 이미지 push
    4.  K8s앱 실행
- skaffold로 최종 배포도 가능하지만 **개발 중 사용만으로도 효율적**
  - 배포는 kubectl, helm 등과의 연동을 공식지원하며, GoogleCloud, Gitops 등으로도 가능
- `skaffold.yaml`
  - 설정 파일 딱 한 개만 필요하고 나머지는 cli커맨드로 제어
- 가벼움(client-side only)
  - K8s 클러스터측에 설치해야하는 에이전트가 없음
- 클러스터 실행시 환경변수 전달에 용이 (AWS_KEY 등 전달시 편함)

## 참고자료

### 예제

```sh
git clone https://github.com/GoogleContainerTools/skaffold
```

- 위 저장소의 examples 디렉토리에 유형 별 배포 예시가 제공됨
- docker, helm, kustomize, 클라우드 등 **배포방법에 따라 디렉토리 구성 및 skaffold.yaml 설정을 알 수 있어서 좋음**
- react, ruby, nodejs 등 K8s앱 유형 별 예시도 있음

### 문서

[공식 문서](https://skaffold.dev/docs/)

## 용어

- Pipeline
  - Skaffold에서 앱 개발 및 배포 과정을 단계별로 정의하는 개념
- Artifact
  - **skaffold.yaml에 기술하는 관리대상 이미지**
  - 넓은 의미로, 빌드된 앱의 결과물, 또는 빌드 및 배포 과정 전후에 필요한 모든 파일들을 의미 (소스코드, 디펜던시, 생성된 파일, 패키지, 컨테이너 이미지 등)
- [Profile](https://skaffold.dev/docs/environment/profiles/)
  - 다양한 컨텍스트로 스캐폴드 환경을 구성할 수 있게 해준다.
  - 여기서 컨텍스트란, build, test, deployment 등 개발 및 배포 단계에 따라 구분된 환경을 의미

## 커맨드 및 Practice

- K8s 클러스터가 1개 이상 켜져 있어야 함
- `skaffold build`, `skaffold dev`만 잘 써도 개발시 매우 편리
- Pipeline 모든 단계를 한 번에 수행하는 명령어(End-to-end Pipelines)와 각 단계만 실행하는 명령어(Pipeline building Blocks)들이 있다.

### skaffold init

- 하위 디렉토리들을 조회하여 그에 맞는 새로운 `skaffold.yaml`파일 생성
- `skaffold.yaml`을 편집하거나 cli 명령어 옵션으로 skaffold 동작을 제어할 수 있다.

### skaffold build

- skaffold.yaml의 build.artifacts에 기술된 이미지를 빌드

  ```yaml
  # skaffold.yaml 작성 예
  build:
    artifacts:
      - image: myapp           # 생성할 이미지 이름 지정
        context: images/myapp  # Docker Context 파일경로
  ```

  ```sh
  # 이미지 빌드 실행 예
  skaffold build --default-repo="docker.io/yunanj" --tag 1.0.0

  # 축약형 옵션
  skaffold build -d "docker.io/yunanj" -t 1.0.0
  ```

- skaffold는 기본적으로 local registry에서 이미지 빌드 후 항상 remote registry(default-repo)에 push한다.
  - default skaffold는 remote regsitry없이 실행불가
  - remote registry, tag 미지정시 에러 발생
  - remote registry로 docker.io, private registry 등을 활용가능

- **(필수)이는 로컬 개발 작업시 매우 비효율적이므로 다음과 같이 skaffold.yaml을 수정하여 해당 기능을 꺼주도록 한다.**

  ```yaml
  # skaffold.yaml
  build:
    local:
      push: false              # 로컬(도커 데몬)에서만 빌드
    artifacts:
      - image: myapp           # 생성할 이미지 이름 지정
        context: images/myapp  # Docker Context
  ```

- 이후엔 remote registry 의존성 없이 skaffold 실행 가능
  - cli에서 `-d`, `-t` 옵션없이 간편하게 실행
  - 다시 remote registry에 push가 필요할 땐 skaffold.yaml를 수정하지말고 cli에서 `--push` 옵션을 사용하면 된다.

  ```sh
  # skaffold.yaml 수정 후 remote registry 없이 빌드 가능
  skaffold build

  # remote regsitry에 push
  skaffold dev -d docker.io/yunanj -t 1.0.0 --push
  ```

- 로컬(도커 데몬)에 저장된 이미지 확인

  ```sh
  # K3s (컨테이너 런타임으로 docker 사용시)
  docker image ls

  # Minikube
  minikube ssh
  docker image ls
  ```

- 참고
  - remote registry 대용으로 빠르게 로컬에 설치가능한 private registry가 있다.

  ```sh
  # helm으로 로컬 프라이빗 레지스트리 빠른설치
  helm repo add twuni https://helm.twun.io
  helm repo update
  helm install registry twuni/docker-registry --set ingress.enabled=true

  # 다음처럼 이용
  skaffold dev -p dev -d localhost:5000/myproj
  ```

### skaffold dev

개발모드 실행

`skaffold build`와 `skaffold deploy` 과정이 포함되는 End-to-end pipeline 커맨드

- 실행시 터미널 세션을 점유하고, 대기상태가 된다.
  - 이 때 에디터에서 Dockerfile 및 기타 파일을 수정하면 즉시 반영
  - 컨테이너 내부 코드도 수정시 즉시 반영
  - **개발모드의 수정사항은 즉시 반영되므로, Production 환경에서는 사용하지 않도록 한다.**

- build 과정이 포함되므로, build 옵션을 쓸 수 있다.
  - build되지 않으면 개발모드 실행이 되지 않음
  - 이에따라 개발 중 꾸준히 빌드가능 상태를 유지한다는 이점이 있다.

```sh
# 개발모드
skaffold dev

# remote registry에 실시간 수정되는 이미지를 push 하면서 개발
skaffold dev -d "docker.io/yunanj" -t 1.0.0 --push
```

### 기타 Pipeline Building Blocks

```sh
# 빌드
skaffold build

# 사전 빌드된 artifact(이미지)로 K8s앱을 실행
skaffold deploy --images {IMAGE}:{TAG}

# skaffold로 배포설치(run)된 리소스(클러스터, 컨테이너 등) 삭제
skaffold delete

# 기타
skaffold test
skaffold apply
skaffold verify
```

### 기타 End-to-end Pipelines

- `skaffold dev`

- `skaffold run`
  - 파이프라인 전체 실행
  - skaffold 프로젝트를 타인에게 배포할 때 skaffold run 명령어 하나만으로 실행가능하도록 해준다.
  - 실행결과를 kubectl, k9s 등으로 확인해보자.
  - `skaffold delete`로 설치된 앱(K8s 오브젝트)을 삭제가능

- `skaffold debug`
  - 디버그 모드 실행. 사전 디버깅 지점 설정 또는 설정 파일 필요.

### 참고

- DockerFile에 apt설치 구문을 추가했는데 skaffold build, dev에서 반영되지 않는 경우, 특정 dependency를 처리하지 못해, 설치가 취소된 것일 수 있다. FROM 이미지 교체하거나 별도 대응 필요
