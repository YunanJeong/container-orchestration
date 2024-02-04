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
- yaml 형식이고 여러 클러스터 정보가 함께 기술될 수 있음
- 현재 지정된 컨텍스트(current-context)도 쓰여있고, CLI로 Context 전환시 이 값이 수정됨
- kubectl, helm, skaffold, k9s 등 대부분의 K8s Client는 `~/.kube/config` 파일내용을 참조하여 클러스터에 접근함
  - 단, K3s와 함께 설치된 kubectl은 `/etc/rancher/k3s/k3s.yaml`를 default로 참조

### 환경변수 KUBECONFIG

- Context 파일 경로를 Override하여 지정
- KUBECONFIG 값 지정시, K8s Client는 이 값을 우선하여 따른다.
- KUBECONFIG 값이 없으면, default설정을 따른다. (표준은 `~/.kube/config`)
- 단순할당이 아닌 `export`로 환경변수 할당해야 함

## Context 변경방법 1 (표준, 권장, kubectl config 커맨드)

- `kubectl config` 커맨드로 간편하게 `~/.kube/config` 내용을 변경할 수 있다.

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

## Context 변경방법 2 (KUBECONFIG 변수 수정 후 반영)

```sh
# minikube와 K3s가 함께 있을 때 Context 변경 예시

# General KUBECONFIG (minikube로 전환)
echo 'export KUBECONFIG=~/.kube/config' >> ~/.bashrc
source ~/.bashrc
minikube update-context

# K3s로 전환
echo 'export KUBECONFIG=/etc/rancher/k3s/k3s.yaml' >> ~/.bashrc
source ~/.bashrc
chmod 644 /etc/rancher/k3s/k3s.yaml
```

## K3s의 Context 예외

- k3s와 함께 설치되는 kubectl은 default 컨텍스트 파일경로로 `/etc/rancher/k3s/k3s.yaml`을 참조한다.



- 참고
  - `minikube kubectl`과 `k3s kubectl`과 같이 각 subcommand를 사용한다고 해서 Context가 구분되지는 않는다.
  - 동일한 kubectl일 뿐이고, 호스트에서 현재 지정된 Context에 의해 K8s 작업환경이 결정된다.


  ```sh
# 컨텍스트를 k3s로 변경
$ k config use-context k3s
Switched to context "k3s".
```

- 확인

```sh
# 확인
$ k config get-contexts
CURRENT   NAME       CLUSTER    AUTHINFO   NAMESPACE
          eks        eks        eks
*         k3s        k3s        k3s
          minikube   minikube   minikube   default
```