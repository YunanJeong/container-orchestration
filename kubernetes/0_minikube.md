# minikube
## Installation
- 문서: [minikube 시작하기(공식)](https://minikube.sigs.k8s.io/docs/start/)
- 2코어, 2GB 메모리 필요
- VM or Container Runtime 필요
    - 도커 사용시 [도커를 non-root 권한으로 사용](https://docs.docker.com/engine/install/linux-postinstall/#manage-docker-as-a-non-root-user) 필요
    ```sh
    # 다운로드 및 설치
    curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube_latest_amd64.deb
    sudo dpkg -i minikube_latest_amd64.deb
    ```
## 참고 (minikube의 네트워크 구성, docker 기준 설명)
- minikube는 Localhost에서만 가능
- minikube는 단일 노드 클러스터만 지원(했었다.)
    - 노드 1개로 구성된 K8s 클러스터를 시뮬레이션
    - minikube 실행시 전체 k8s 시스템이 단 1개의 Container로 실행
    ```sh
    # minikube 실행
    minikube start

    # minikube 종료
    minikube stop

    # 클러스터 삭제(초기화)
    minikube delete
    ```
- [minikube의 멀티노드 클러스터(1.10.1 버전 이상)](https://minikube.sigs.k8s.io/docs/tutorials/multi_node/)
    - 다수 노드로 구성된 K8s 클러스터를 **1개의 머신에서** 시뮬레이션
    - **다수 머신은 minikube로 안된다!!(오해 ㄴㄴ!!)**
    - 공식 kubectl을 localhost에 설치해서 각 노드를 제어해야 함
    - ControlPlane과 Worker 노드들이 개별 Container로 구현됨
        - `docker ps` 및 `kubectl get nodes`로 확인가능
        - 개별 Pod(Container)는 노드Container 내부에서 실행됨
    ```sh
    # minikube Multi-node Cluster 실행
    minikube start --nodes {node개수} -p {Cluster 이름 지정}
    # minikube Multi-node Cluster 종료
    minikube stop -p {Cluster 이름 지정}
    ```
## Command
- `minikube kubectl -- `
    -  minikube의 서브커맨드로 일반적인 kubectl의 명령어를 실행 가능
    - `alias kubectl="minikube kubectl --"`를 `~/.bashrc`에 등록하여 편하게 쓰자
    - 단일 노드 전용
- `minikube ip`
    - minikube가 실행된 VM or Container의 IP를 반환
    - K8s 클러스터의 단일노드 ip를 의미
    - 멀티노드
        - default: Control Plane이 포함된 노드 IP를 반환
        - `--node={대상노드NAME}`: 대상 노드 IP 반환 
- `minikube service {service name}`
- `minikube service --all`
    - K8s에서 service마다 ip가 할당되는데, 이는 K8s 클러스터 환경 내 private ip이다.
    - minikube 사용시 localhost는 클러스터 외부이므로, 클러스터 내부 서비스에 접근하기 위한 tunnel을 생성해주는 명령어
    - minikube+도커 채택시 자주 사용됨
       - 가상 클러스터를 생성하기 위한 도구가 도커라면, 도커 브릿지 네트워크를 건너가기 위해 필요한 경우가 많다.
- `minikube dashboard`
    - k8s 대시보드 실행. 접속은 브라우저에서
    - 대시보드 자체는 minikube 전용이 아니라, 일반적인 k8s의 모니터링 대시보드
- `minikube addons`
    - minikube로 각종 K8s 애드온 활성화 용도 (dashboard, ingress controller 등)
    - 이 기능말고, kubectl로 K8s 자체기능으로 추가해도 된다.