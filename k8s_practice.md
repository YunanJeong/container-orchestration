# minikube
## requirement
- 2코어, 2GB 메모리 필요
- [도커를 non-root 권한으로 사용하기](https://docs.docker.com/engine/install/linux-postinstall/#manage-docker-as-a-non-root-user)

## Installation
[minikube 시작하기(공식)](https://minikube.sigs.k8s.io/docs/start/)
```
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube_latest_amd64.deb
sudo dpkg -i minikube_latest_amd64.deb
```
## 참고 Guide
[쿠버네티스 안내서(기초 학습 및 실습용으로 훌륭)](https://subicura.com/k8s)

## Command
### minikube
- `minikube kubectl -- `
    -  minikube의 서브커맨드로 일반적인 kubectl의 명령어를 실행 가능
    - `alias kubectl="minikube kubectl --"`를 `~/.bashrc`에 등록하여 편하게 쓰자
- `minikube ip`
    - 현재 작업중인 host 내에서 minikube가 점유한 private ip
- `minikube service {service_name}`
    - k8s에서 service마다 ip가 할당되는데, minikube 등을 사용 중이라면 **minikube 내부에서 private ip**가 할당된 것이므로, localhost에서 바로 접근이 안될 수 있다.
    - 이 때 이 명령어를 이용하면 한단계 더 포트포워딩하여 localhost에서 접속가능한 포트가 제공된다.
- `minikube dashboard`
    - k8s 대시보드 실행. 접속은 브라우저에서
    - 대시보드 자체는 minikube 전용이 아니라, 일반적인 k8s의 모니터링 대시보드

### kubectl
- [kubectl 명령어 참고자료](https://subicura.com/k8s/guide/kubectl.html#kubectl-%E1%84%86%E1%85%A7%E1%86%BC%E1%84%85%E1%85%A7%E1%86%BC%E1%84%8B%E1%85%A5)
- kubectl get
    - kubectl get all
    - kubectl get pods (pod, po)
        - kubectl get pods -A
    - kubectl get services (service)
    - kubectl get deployments (deployment, deploy)
- kubectl apply -f {k8s설정파일명.yml or URL}
- kubectl delete -f {k8s설정파일명.yml or URL}