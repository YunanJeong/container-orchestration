# 쿠버네티스에서 로깅

쿠버네티스 노드(로컬호스트)에 저장되는 로그는 기본적으로 K8s 앱 개발시 최근 로그를 터미널에서 쉽게 조회하는 정도의 목적임

장기보관이나 고도화된 운영로그 조회가 필요하다면 결국은 백엔드가 뭐라도 하나 있어야 함

## 앱 로그

```sh
# kubectl logs {POD_NAME}
kubectl logs podname-xxxxxxxxxxx-xxxx
```

- pod에 container가 여러 개면, -c옵션으로 특정 container 지정
- **여기서 보여주는 로그는 pod내에서 발생하는 stdout, stderr**다.
- 요즘 대부분 상용툴은 로거가 포함되어 있고, 파일로 로그가 저장된다.
- 해당 툴들의 이미지 배포판은 로거 출력 설정을 stdout, stderr로 설정되어 배포된다.

### 

컨테이너 단위 (`/var/log/container/`)
Pod 단위 (`/var/log/pod/`)

- 위 둘은 같은 내용이고, 디렉토리 분류만 다름
- Pod 쪽 파일이 컨테이너 쪽 경로 파일을 가리킴(symbolic link)
10메가 넘으면 로테이션


## 시스템 로그

100메가 넘으면 로테이션


## 쿠버네티스 로깅 관련 참고 자료

https://kubernetes.io/docs/concepts/cluster-administration/logging/#logging-at-the-node-level

https://unofficial-kubernetes.readthedocs.io/en/latest/concepts/cluster-administration/logging/



https://kubernetes.io/docs/concepts/cluster-administration/logging/#logging-at-the-node-level

https://stackoverflow.com/questions/71948846/kubernetes-pod-logs-retention

```sh

/var/log/container/
/var/log/pod/
```

### K8s 시스템로그
