# Ingress (입구, 인바운드)

- Service에 대한 클러스터 외부접근을 관리하는 API Object
- Ingress Controller가 실제 기능을 수행하는 주체이고, Ingress는 수행 규칙을 정의&선언하는 Object

- 사용 목적
  - 클러스터 외부에 http/https를 열어주기 위해 쓰임
  - *Service를 외부망에 배포*하기 위해 사용
    - e.g. 한 클러스터에 여러 Service를 운용중인 경우, 각 Service에 연동된 모든 nodePort를 사용자에게 알려주기는 힘듦
    - 따라서 외부접근시 *http/https(80/443)와 같은 일반포트를 공용*으로 쓰게하고, *사용된 URL에 따라 각기 다른 Service로 라우팅*되도록 설정할 필요있음

## Ingress Controller

- Ingress는 다른 Object와 달리 별도 Controller 설치 필요
- Ingress Controller가 외부 트래픽을 클러스터 내 Service로 라우팅하는 Proxy 역할
- 실사용시 클러스터(namespace 'ingress-nginx') 내 개별 Pod 및 Service(LoadBalancer)로서 워커 노드 측에서 실행된다.
- Nginx, Traefik, and Istio 등 여러가지 있음
- 설치방법은 K8s 배포판이나 Ingress Controller 종류에 따라 다르다. 대부분 Yaml이 제공된다.
- Controller 종류에 따라 내부 구현 방식이 다양하다.

## Ingress 설정 순서

### 1. ingress controller 설치

  ```sh
  # 일반적인 nginx ingress controller 배포 (Yaml 메니페스트로 배포)
  kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.0.0/deploy/static/provider/cloud/deploy.yaml

  # 실행 확인
  kubectl get all -n ingress-nginx
  ```

  ```sh
  # minikube 한정 ingress 활성화
  minikube addons enable ingress
  minikube service ingress-nginx-controller -n ingress-nginx --url # (minikube에서 docker 사용시) nginx 포트 개방
  ```

### 2. (설치한 ingress controller의 설정과 외부 트래픽 처리규칙을 담은)ingress 설정파일 apply

  ```sh
  kubectl apply -f {ingress파일명.yml}

  # 인그레스 정보 확인
  kubectl get ingress
  ```

#### 2.1. k9s 툴에서 특정 Pod에 대해 `Shift+F`를 쓰면 ingress 설정 메니페스트 없이 로컬호스트에서 포트포워딩을 즉시 수행가능하다.

### 3. 접속할 클라이언트에서 hosts 파일 수정

- 윈도우(`C:\Windows\System32\drivers\etc\hosts`)
- 리눅스(`/etc/hosts`)

```sh
# IP대신 도메인 네임을 사용할 경우 다음과 같은 내용을 추가
# X.X.X.X는 실제 사용될 IP
X.X.X.X example1.mydomain.com
X.X.X.X example2.mydomain.com
```

## NodePort vs. LoadBalancer vs. Ingress (K8s App. 외부 네트워크 노출 3가지 방법 비교)

- 요약
  - 내부망에서 간단히 배포할거면 nodePort
  - 외부망 배포: LoadBalancer or Ingress
  - 클라우드 쓸거면: LoadBalancer
  - 80/443포트(http/https)로 노출: ingress
  - http/https가 아니면: nodePort or LoadBalancer

- NodePort vs. LoadBalancer
  - 만약 클라우드가 아닌 가상환경 등 소규모 네트워크에서 LoadBalancer 타입을 쓴다면 NodePort 타입과 별 차이가 없다.
  - LoadBalancer
    - 클라우드를 활용하여 서비스를 외부 노출
    - 로드 밸런싱(공인IP<=>각 노드들 사이 트래픽 분산)
  - NodePort
    - 단순 외부 네트워크와 연결
    - 외부망 "인터넷" 노출 시엔 port가 드러나므로 부적절

- LoadBalancer vs. Ingress
  - 둘 다 외부노출용
  - Ingress
    - 앱 수준에서 라우팅(L7, Application Layer)
    - url 주소로 트래픽 구분
    - 주로 http/https 처리에 사용
    - http/https가 아닌데 외부 인터넷에 노출시키려면 NodePort or LoadBalancer사용
  - LoadBalancer
    - 네트워크 수준에서 라우팅 (L4, Transport Layer)
    - IP와 Port로 트래픽 구분
    - 간혹 IP 사용 및 네트워크 수준이라고 해서 Network Layer라고 하는 글들이 있는데 잘못된 표현
    - K8s의 LoadBalancer는 Transport Layer(L4)에서 동작한다고 표현하는 것이 맞다.
    - [오라클 피셜](https://docs.oracle.com/en-us/iaas/Content/ContEng/Tasks/contengcreatingloadbalancer.htm)
    - 클라우드 사용시 활용

### (의문점)Ingress에다가 NodePort 또는 LoadBalancer를 반드시 함께 사용해야한다는 블로그 자료들이 많던데, 막상 실행해보니 ClusterIP Service도 Ingress로 외부노출이 가능하다. 팩트가 무엇인가?

#### 답변

- `Ingress는 ClusterIP를 포함해서 어떤 타입의 Service에도 붙일 수 있고, 외부망 배포가 가능하다.`
- 가장 많이 사용되는 Nginx Ingress Controller는 ClusterIP Service를 외부 노출 가능
  - e.g. [Cluster IP 서비스로 Ingress](https://github.com/kubernetes/kubernetes/issues/26508)
- 일부 클라우드 공급자의 Ingress Controller를 사용하는 경우, ClusterIP를 지원하지 않는 경우가 있을 수 있다.
  - e.g. [GKE](https://stackoverflow.com/questions/58314207/why-cant-i-attach-a-service-type-clusterip-to-ingress-on-gke)
- Ingress Controller마다 구현방식이 다양하기 때문에 이 부분 설명은 케바케가 될 수 있음
- 그러나 `K8s 공식 Ingress 사양에서는 따로 특정 타입의 Service를 요구하지 않는다.`

#### - 사람들이 오해하는 이유 1

#### 공식적으로 Ingress와 함께 언급되는 LoadBalancer에 대한 오해

- 이는 Ingress-Managed LoadBalancer를 의미
- App(L7) 단위의 트래픽을 분산시켜주는 프록시 서버
- [공홈](https://kubernetes.io/ko/docs/concepts/services-networking/ingress/)의 설명에서는 Service(LoadBalancer 타입)과는 분명히 구분하고 있다.

#### - 사람들이 오해하는 이유 2

#### NodePort, LoadBalancer 용어에 대한 오해

- Ingress 사용시, 어쨌든 외부에서 클러스터에 접근하려면 가장먼저 Node의 Port를 통해야하고, 클라우드 사용시 외부 LoadBalancer를 사용할 수 있어야 한다.
- 이런 기능들을 구현한 Ingress Controller 내부 컴포넌트가 있을 것이다.
- 그렇다고 이것이 K8s 관리자가 배포하려는 App Service를 NodePort or LoadBalancer 타입으로 만들어한다는 말은 아니다.

#### - 가장 널리 쓰이는 Nginx Ingress Controller의 사례

- Nginx Ingress Controller 구성시 자동으로 별도 namespace에 'LoadBalancer 타입의 Service'가 생성된다.
- 이는 Nginx에서 Controller 자체 기능구현을 위해 다음과 같이 K8s의 Service(LoadBalancer)기능을 활용하는 것이다.
  - App 외부노출 기능을 구현하기 위해 NodePort or LoadBalancer 타입의 Service 설정
  - K8s 관리자로 하여금 ingress 설정만으로 클라우드 공급자의 LoadBalancer를 활용할 수 있도록 하기 위해 LoadBalancer 타입의 Service 설정
- 이를 두고 각종 설명글, 그림에서는 'LoadBalancer 타입의 Service를 활용해야만 한다'라고 표현하고 있으나 이는 Ingress Controller 내부구조에 한정된 것이지,
- K8s 관리자가 배포하고자 하는 App Service를 LoadBalancer 타입으로 설정해야하는 것은 아니다. App Service는 ClusterIP 타입이어도 상관없다!!
- 작업 환경이나 Ingress Controller 종류에 따라 더 세밀한 네트워크 제어를 위해, K8s 관리자가 직접적으로 LoadBalancer 타입의 Service를 추가하여 Controller의 일부기능을 구현할 수는 있으나, 그 Service가 백엔드 App Service를 의미하는 것은 아니다.

- 2020년 블로그들[[1]](https://5equal0.tistory.com/entry/Kubernetes-Nginx-Ingress-Controller)[[2]](https://zgundam.tistory.com/178)을 보면 nginx controller인데도 App Service를 클라우드, 베어메탈 환경을 구분해서 LoadBalancer, NodePort타입으로 생성해줘야 된다고 하는데, 현재는 그냥 ClusterIP로만 생성해도 잘만 된다... nginx ingress controller가 패치된 것일 수도 있겠다.

- 다시 한번 말하자면 `Ingress는 ClusterIP를 포함해서 어떤 타입의 Service에도 붙일 수 있다.`
- 일반적인 Controller나 Nginx Controller를 쓰고 있다면, `일부러 배포하고자 하는 App Service를 NodePort나 LoadBalancer 타입으로 만들 필요는 없다.`
