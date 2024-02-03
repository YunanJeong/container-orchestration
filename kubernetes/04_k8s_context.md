# Context 관리

## Abstract

minikube와 K3s가 한 호스트에 설치되었다면, 이를 구분해서 관리할 필요가 있다.

- kubectl은 로컬호스트에 설정된 K8s Context에 의해 특정 클러스터 하나만을 가리킨다.
- 따라서 minikube와 K3s, 혹은 여러 원격 클러스터를 구분해서 관리하려면 Context를 변경해야 한다.
- 참고
  - `minikube kubectl`과 `k3s kubectl`과 같이 각 subcommand를 사용한다고 해서 Context가 구분되지는 않는다.
  - 동일한 kubectl일 뿐이고, 호스트에서 현재 지정된 Context에 의해 K8s 작업환경이 결정된다.

## K8s Context

- 클러스터, 사용자 권한 및 네임스페이스와 같이 K8s 작업 환경의 조합을 총칭
- **kubectl로 관리하는 대상 클러스터**, 사용자 권한 등을 의미

## `~/.kube/config`

- 컨텍스트 파일
- 클러스터 정보(Context)가 담긴 파일
- yaml 형식이고 여러 클러스터에 대한 정보가 함께 있을 수 있음
- 현재 지정된 컨텍스트(current-context)도 쓰여있고, CLI로 Context 전환시 이 값이 수정됨

## 환경변수 `KUBECONFIG`

- kubectl 명령어가 사용할 컨텍스트 파일경로 지정
- kubectl은 KUBECONFIG에 등록된 파일로 클러스터 연결, 사용자 인증, 작업 네임스페이스를 인식
- KUBECONFIG 값이 없으면
  - 대부분 K8s배포판들은 default로 `~/.kube/config`를 참조
  - **K3s만 예외로 default가 /etc/rancher/k3s/k3s.yaml**

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
