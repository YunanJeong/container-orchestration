# Context 관리

## Abstract

하나의 로컬호스트에서 여러 클러스터를 관리할 때, 각각의 구분이 필요하다.

- e.g. minikube, K3s 등 다양한 배포판이 설치된 경우
- e.g. 여러 원격 클러스터를 관리하는 경우

kubectl은 로컬호스트에 설정된 K8s Context에 따라 특정 클러스터만을 가리킨다. 따라서 작업할 클러스터 변경 시 Context를 수동으로 지정해줘야 한다.

## K8s Context

- 클러스터, 사용자 권한, 네임스페이스 등 K8s 작업 환경의 조합을 총칭
- **kubectl로 관리하는 대상 클러스터**, 사용자 권한 등을 의미

### ~/.kube/config

- Context 파일 표준 경로
- yaml 형식
- 여러 클러스터 정보 함께 기술 가능
- 현재 지정된 컨텍스트(current-context) 정보가 포함되어 있으며, CLI로 Context 전환시 이 값이 수정됨
- 대부분의 K8s Client는 `~/.kube/config` 파일내용을 참조하여 클러스터에 접근함 (kubectl, helm, skaffold, k9s 등)
  - 단, K3s와 함께 설치된 kubectl은 default로 `/etc/rancher/k3s/k3s.yaml`를 참조

### 환경변수 KUBECONFIG

- Context 파일 경로를 Override하여 지정
- KUBECONFIG 값 지정시, K8s Client는 이 값을 우선하여 따른다.
- KUBECONFIG 값이 없으면, default설정을 따른다. (표준은 `~/.kube/config`)
- 단순할당이 아닌 `export`로 환경변수 할당필요

## Context 변경방법 (kubectl config 커맨드)

- `kubectl config` 커맨드로 간편하게 Context를 전환가능
- `~/.kube/config` 내용을 조회 및 변경함

```sh
# 현재 컨텍스트 및 목록 확인 (변경 전)
$ kubectl config get-context

CURRENT   NAME       CLUSTER    AUTHINFO   NAMESPACE
*         eks        eks        eks
          k3s        k3s        k3s
          minikube   minikube   minikube   default
```

```sh
# 컨텍스트 변경
$ kubectl config use-context minikube

Switched to context "minikube".
```

```sh
# 현재 컨텍스트 및 목록 확인 (변경 후)
$ kubectl config get-context

CURRENT   NAME       CLUSTER    AUTHINFO   NAMESPACE
          eks        eks        eks
          k3s        k3s        k3s
*         minikube   minikube   minikube   default
```

## K3s의 Context 처리방법

- K3s용 kubectl은 Context 파일 default경로가 독자적이라, 추가 설정이 요구됨
- 다양하게 처리가능하나 아래 방법이 대체로 가장 편하다.

### K3s 단독 사용 시

```sh
# (helm 등)모든 K8s Client가 /etc/rancher/k3s/k3s.yaml을 참조하도록 설정
echo 'export KUBECONFIG=/etc/rancher/k3s/k3s.yaml' >> ~/.bashrc
source ~/.bashrc
sudo chmod 644 /etc/rancher/k3s/k3s.yaml
```

### 여러 컨텍스트와 함께 K3s 사용 시

```sh
#  ~/.kube/config에 k3s 정보(k3s.yaml)를 직접 추가한 후

# K3s용 kubectl이 ~/.kube/config를 참조하도록 설정
echo 'export KUBECONFIG=~/.kube/config' >> ~/.bashrc
source ~/.bashrc
```

- 이후 CLI로 Context 전환가능

```sh
# 컨텍스트를 k3s로 변경
$ kubectl config use-context k3s
Switched to context "k3s".
```

```sh
# 확인
$ kubectl config get-contexts
CURRENT   NAME       CLUSTER    AUTHINFO   NAMESPACE
          eks        eks        eks
*         k3s        k3s        k3s
          minikube   minikube   minikube   default
```

## 참고

- `minikube kubectl`과 `k3s kubectl`과 같이 각 subcommand를 사용한다고 해서 Context 구분이 보장되지 않음. Context 파일이 중요.
- `KUBECONFIG=/etc/rancher/k3s/k3s.yaml:~/.kube/config`과 같이 체인형식으로 써도 인식은되나, `kubectl config` 명령어 쓸 때 꼬일 수 있음. `비권장`.
- context 명령어가 길기 때문에 fzf, krew 등 서드파티 툴을 쓰는 것이 훨씬 편함
