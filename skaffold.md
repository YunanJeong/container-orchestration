# Skaffold
- 컨테이너 기반 및 Kubernetes 애플리케이션의 지속적인 개발을 촉진하는 CLI 툴
- K8s 앱의 지속적 배포를 위한 구글 자체 툴

## 쓰는 이유
- 빠른 로컬 K8s 개발
- 공유 및 배포 편의성 (지속적배포CD, GitOps 등)
    - 코드 수정(컨테이너 이미지 변경)시 이를 자동으로 빌드,push하고 K8s 앱 배포까지 자동화한다.
- skaffold.yaml: 설정 파일 딱 한 개
- 가벼움(client-side only): K8s 클러스터측에 설치해야하는 에이전트가 없음

## 문서
- https://skaffold.dev/docs/

## 설치
```
# For Linux x86_64 (amd64)
curl -Lo skaffold https://storage.googleapis.com/skaffold/releases/latest/skaffold-linux-amd64 && \
sudo install skaffold /usr/local/bin/
```
---
# memo
- K8s 클러스터가 1개 이상 켜져 있어야 함    

## 용어
- Pipeline: Skaffold에서 앱 개발 및 배포 과정을 단계별로 정의하는 개념
- Artifact: 빌드된 앱의 결과물, 또는 빌드 및 배포 과정 전후에 필요한 모든 파일들 (소스코드, 디펜던시, 생성된 파일, 패키지, 컨테이너 이미지 등)

## skaffold.yaml

## 커맨드
- skaffold init
    - 하위 디렉토리들을 조회하여 그에 맞는 skaffold.yaml파일 생성
    - 새로 작업시작할 때만 사용, 이미 skaffold.yaml이 있으면 안해도 됨

### End-to-end Pipelines
- 파이프라인의 모든 단계를 한 번에 수행하는 명령어들
- skaffold run
    - 파이프라인 전체 실행
    - skaffold 프로젝트를 타인에게 배포할 때 skaffold run 명령어 하나만으로 실행가능하도록 해준다.
    - 실행결과를 kubectl, k9s 등으로 확인해보자.
    - skaffold delete로 설치된 앱(K8s 오브젝트)을 삭제가능하나, Production 환경에서 쓰지 않도록 주의

- skaffold dev
    - 터미널에서 실행시 세션을 점유하고, 대기상태가 된다.
        - 이 때 에디터에서 Dockerfile 및 기타 파일 등을 수정하면 즉시 반영된다.
        - 컨테이너 내부용 코드도 즉시 반영된다.
    - dev모드의 변경내역이 실제환경에 반영되면 안되므로, 로컬 레지스트리에서 컨테이너 이미지가 처리된다.
        - 따라서, minikube를 쓰는 것이 편하다.
        - K3s에서 Skaffold dev모드를 쓰려면 별도 레포지토리 구축이 필요하다.

- skaffold debug
    - 디버그 모드 실행. 사전 디버깅 지점 설정 또는 설정 파일 필요.

### Pipeline Building Blocks
- 파이프라인의 특정 단계만 수행하는 명령어들
- build
- test
- deploy
- skaffold delete
    - skaffold로 설치&배포된 모든 리소스를 삭제
    - Production 환경에서 쓰지 않도록 주의
- apply
- verify

## 예제
```
git clone https://github.com/GoogleContainerTools/skaffold
```
- 위 저장소의 examples 디렉토리에 갖가지 유형별로 배포 예시가 있음
- docker, helm, kustomize, 클라우드 등 배포방법에 따라 파일 구성을 알 수 있어서 좋음
- 또, react, ruby, nodejs 등 K8s앱 유형 별 예시도 있음