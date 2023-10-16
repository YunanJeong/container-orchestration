## kubectl

- [kubectl 명령어 참고자료](https://subicura.com/k8s/guide/kubectl.html#kubectl-%E1%84%86%E1%85%A7%E1%86%BC%E1%84%85%E1%85%A7%E1%86%BC%E1%84%8B%E1%85%A5)
- kubectl
  - apply
  - delete
  - get
  - describe
  - logs
  - exec
  - config

### 1. kubectl apply -f {k8s설정파일명.yml or URL}

### 2. kubectl delete -f {k8s설정파일명.yml or URL}

### 3. kubectl get

```sh
# 모든 Object 조회 (pod, service, deployment, job, replicaset)
kubectl get all

# Type 별 Object 조회, 복수단수, 줄임말 혼용가능
kubectl get pods (pod, po)
kubectl get pods -A
kubectl get services (service, svc)
kubectl get deployments (deployment, deploy)
kubectl get jobs (job)
kubectl get replicasets (replicaset, rs)

# 여러 개 골라서 조회
kubectl get po,rs
```

### 4. kubectl describe {TYPE}/{NAME} or {TYPE} {NAME}

```sh
# TYPE은 pod, service 등 Object Type을 의미
# Object 먼저 조회하여 Name을 확인하고 다음과 같이 사용
kubectl describe pods/podname-xxxxxxxxxxx-xxxx`
kubectl describe pods podname-xxxxxxxxxxx-xxxx`
```

### 5. kubectl logs {POD_NAME}

- pod의 로그 조회
- pod에 container가 여러 개면, -c옵션으로 특정 container 지정
- **여기서 보여주는 로그는 pod내에서 발생하는 stdout, stderr**다.

```sh
kubectl logs podname-xxxxxxxxxxx-xxxx
```

### 6. kubectl exec {POD_NAME} -- {COMMAND}

  ```sh
  # 1회성 커맨드
  kubectl exec podname-xxxxxxxxxxx-xxxx -- ls

  # 원격접속(-it 옵션, bash 커맨드 사용)
  kubectl exec -it podname-xxxxxxxxxxx-xxxx -- bash
  ```

### 7. kubectl config {subcommand}

- k8s에서 context: 여러 개의 k8s cluster들을 다룰 때, kubectl이 어느 cluster에 연결되었는지, 어떻게 인증할지에 대한 정보

```sh
# 현재 컨텍스트 조회
kubectl config current-context
```

### 8. kubectl label {OBJ_TYPE} {OBJ_NAME} {LABEL_KEY}={LABEL_VALUE}

- Pod, Node 등에 레이블 설정
- 특정 오브젝트를 레이블을 등록시, 이후 해당 레이블로 오브젝트를 구분하여 제어할 수 있다.
- 이를테면 Node의 경우, `nodeSelector`, `nodeAffinity` 등 설정으로 앱을 어느 노드에 분배하여 실행할지 설정가능

```sh
# 등록 예
kubectl label nodes my-node-1 myapp/noderole=kafka

# 삭제 예 (Key로 삭제)
kubectl label nodes my-node-1 myapp/noderole-
```
