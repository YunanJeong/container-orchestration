# Context 관리

minikube와 K3s가 한 호스트에 설치되었다면, 이를 구분해서 관리할 필요가 있다.

- kubectl은 로컬호스트에 설정된 K8s Context에 의해 특정 클러스터 하나만을 가리킨다.
- 따라서 minikube와 K3s, 혹은 여러 원격 클러스터를 구분해서 관리하려면 Context를 변경해야 한다.
- 참고
  - `minikube kubectl`과 `k3s kubectl`과 같이 각 subcommand를 사용한다고 해서 Context가 구분되지는 않는다.
  - 동일한 kubectl일 뿐이고, 호스트에 현재 등록된 Context에 의해 K8s 작업환경이 결정된다.

## K8s Context

- 클러스터, 사용자 권한 및 네임스페이스와 같이 K8s 작업 환경을 조합을 총칭
- **kubectl로 관리하는 대상 클러스터**, 사용자 권한 등을 의미

## 환경변수 KUBECONFIG

- kubectl 명령어가 사용하는 설정파일경로를 지정

- kubectl은 KUBECONFIG에 등록된 파일로 클러스터 연결, 사용자 인증, 작업 네임스페이스를 인식

## Context 변경방법 1 (KUBECONFIG 변수 수정 후 반영)

```sh
# minikube와 K3s가 함께 있을 때 Context 변경 예시

# General KUBECONFIG (minikube로 전환)
export KUBECONFIG=~/.kube/config  # .bashrc 등록 추천
minikube update-context

# K3s로 전환
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml # .bashrc 등록 추천
chmod 644 /etc/rancher/k3s/k3s.yaml
```

## Context 변경방법 2 (kubectl config 커맨드)

- 관리해야 할 원격 클러스터가 많다면, 매번 KUBECONFIG 수정은 번거로울 수 있다.
- `kube config`를 쓰면 대상 클러스터 전환 가능
- 단, 현재 세션에서 임시로 Context를 바꾸는 것이므로, 매번 개발자가 현재 Context를 꼼꼼히 체크해야 한다.
- helm, skaffold 등 서드파티앱을 지속적으로 사용한다면 KUBECONFIG를 .bashrc에 등록하는 것이 더 확실한 방법이다.

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
