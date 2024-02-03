# Context 관리

## Abstract

하나의 로컬호스트에서 여러 클러스터를 관리할 때, 각각의 구분이 필요하다.

- e.g. minikube, K3s 등 다양한 배포판이 설치된 경우
- e.g. 여러 원격 클러스터를 관리하는 경우

kubectl은 로컬호스트에 설정된 K8s Context에 따라 특정 클러스터만을 가리킨다. 작업할 클러스터 정보(Context)를 수동으로 지정해줘야 한다.

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

## Context 변경방법 1 (KUBECONFIG 변수 수정 후 반영)

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

## Context 변경방법 2 (kubectl config 커맨드)

- 관리해야 할 원격 클러스터가 많다면, 매번 KUBECONFIG 수정은 번거로울 수 있다.
- `kubectl config`를 쓰면 대상 클러스터 전환 가능

```sh
# minikube와 K3s가 함께 있을 때 kube config로 Context 변경 예시

# 컨텍스트(클러스터) 목록 확인
$ kubectl config get-contexts
CURRENT   NAME       CLUSTER    AUTHINFO   NAMESPACE
          default    default    default
*         minikube   minikube   minikube   default
```

```sh
# 컨텍스트를 default로 변경
$ kubectl config use-context default
CURRENT   NAME       CLUSTER    AUTHINFO   NAMESPACE
*         default    default    default
          minikube   minikube   minikube   default
```

```sh
# 컨텍스트를 minikube로 변경
$ kubectl config use-context minikube
CURRENT   NAME       CLUSTER    AUTHINFO   NAMESPACE
          default    default    default
*         minikube   minikube   minikube   default
```

## K3s의 Context 예외

- 참고
  - `minikube kubectl`과 `k3s kubectl`과 같이 각 subcommand를 사용한다고 해서 Context가 구분되지는 않는다.
  - 동일한 kubectl일 뿐이고, 호스트에서 현재 지정된 Context에 의해 K8s 작업환경이 결정된다.