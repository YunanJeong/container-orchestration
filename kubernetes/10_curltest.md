# curl Pod 띄우기

- 작업하다보면 클러스터 내부에서 curl 테스트를 해볼 일이 종종 있는데, 배포되는 이미지에 포함되지 않은 경우가 많다.

```sh
# 클러스터 내 curl이 포함된 Pod 실행
kubectl run curltest --image=curlimages/curl -i --tty -- sh
# nodeSelector 및 namespace 지정 예시
kubectl run curltest -n platform \
--overrides='{"spec": { "nodeSelector": {"myapp.com/name":"eks-platform-common"}}}' \
--image=curlimages/curl -i --tty -- sh

# 실행 후 컨테이너 내부 콘솔로 전환됨
# 이 때 Crtl+D로 Exit해도 여전히 Pod는 실행중임
# 항상 켜놓고 K9s 같은걸로 접속해서 클러스터 내부 통신 테스트 용도로 쓰면될 듯

# 접속
kubectl exec -it curltest -- sh

# pod 삭제
kubectl delete pod curltest
```
