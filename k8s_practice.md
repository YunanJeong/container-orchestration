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
---
# kubectl
- [kubectl 명령어 참고자료](https://subicura.com/k8s/guide/kubectl.html#kubectl-%E1%84%86%E1%85%A7%E1%86%BC%E1%84%85%E1%85%A7%E1%86%BC%E1%84%8B%E1%85%A5)
- kubectl
    - apply
    - delete
    - get
    - describe
    - logs
    - exec
    - config 

1. kubectl apply -f {k8s설정파일명.yml or URL}
2. kubectl delete -f {k8s설정파일명.yml or URL}
3. kubectl get
    ```
    # 모든 Object 조회 (pod, service, deployment, job, replicaset)
    kubectl get all

    # Type 별 Object 조회, 복수단수, 줄임말 혼용가능
    kubectl get pods (pod, po)
    kubectl get pods -A
    kubectl get services (service)
    kubectl get deployments (deployment, deploy)
    kubectl get jobs (job)
    kubectl get replicasets (replicaset)
    ```
4. kubectl describe {TYPE}/{NAME} or {TYPE} {NAME}
    ```
    # TYPE은 pod, service 등 Object Type을 의미
    # Object 먼저 조회하여 Name을 확인하고 다음과 같이 사용
    kubectl describe pods/podname-xxxxxxxxxxx-xxxx`
    kubectl describe pods podname-xxxxxxxxxxx-xxxx`
    ```
5. kubectl logs {POD_NAME}
    - pod의 로그 조회
    - pod에 container가 여러 개면, -c옵션으로 특정 container 지정
    - **여기서 보여주는 로그는 pod내에서 발생하는 stdout, stderr**다.
    ```
    kubectl logs podname-xxxxxxxxxxx-xxxx
    ```
6. kubectl exec {POD_NAME} -- {COMMAND}
    ```
    # 1회성 커맨드
    kubectl exec podname-xxxxxxxxxxx-xxxx -- ls

    # 원격접속(-it 옵션, bash 커맨드 사용)
    kubectl exec -it podname-xxxxxxxxxxx-xxxx -- bash
    ```
7. kubectl config {subcommand}
    - k8s에서 context: 여러 개의 k8s cluster들을 다룰 때, kubectl이 어느 cluster에 연결되었는지, 어떻게 인증할지에 대한 정보
    ```
    # 현재 컨텍스트 조회
    kubectl config current-context
    ```
---
# Pod
- 빠른 Pod 실행
```
kubectl run echo --image ghcr.io/subicura/echo:v1
```
- docker run처럼 컨테이너를 일회성으로 띄운다.
- K8s에서는 Pod을 delete해도, 일반적으로 ReplicaSet에 의해 복구되지만, run기반 Pod는 즉시 delete된다.
- Pod은 보통 단독사용하지 않는다.
    - 그럴거면 그냥 docker run을 쓰지.
    - K8s에서는 일반적으로 Pod를 관리하기 위한 오브젝트를 함께 설정한다.

# ReplicaSet(복제셋)
- **지정된 수**의 **동일한 Pod들**이 **항상 실행**되도록 한다.
- 동일한 Pod이 여러 개 필요할 때는 Pod를 일일이 정의하기보다 ReplicaSet을 쓰는 것이 적합
- 지정된 수
    - yaml로 Pod 개수를 간편히 설정가능
    - 실행 중에도 apply 커맨드로 새로운 설정 반영가능(Scale Out), [ReplicaSet 동작과정](https://velog.io/@jee-9/Kubernetes-Replica-Set%EB%A0%88%ED%94%8C%EB%A6%AC%EC%B9%B4%EC%85%8B%EC%97%90-%EB%8C%80%ED%95%98%EC%97%AC#%EC%B0%B8%EA%B3%A0-%ED%8F%AC%EB%93%9C-%EA%B0%AF%EC%88%98-%EB%B0%94%EA%BE%B8%EB%8A%94-%EB%B0%A9%EB%B2%95)
- 동일한 Pod들
    - 동일한 Pod 여러 개를 관리하는 것이라서 ReplicaSet(복제본집합)이라고 부른다. (e.g. Cluster시스템의 Node들)
    - ReplicaSet 오브젝트 1개가 서로 다른 Pod들 여러 개를 관리하는 것은 아니다.
- 항상 실행
    - ReplicaSet을 등록해놓으면, 오류로 인한 종료or 단순 delete해도 pod이 재실행된다.
