# 

```
# 클러스터 내 curl이 포함된 Pod 실행
kubectl run curltest --image=curlimages/curl -i --tty -- sh

# 실행 후 컨테이너 내부 콘솔로 전환됨
# 이 때 Crtl+D로 Exit해도 여전히 Pod는 실행중임
# 항상 켜놓고 K9s 같은걸로 접속해서 클러스터 내부 통신 테스트 용도로 쓰면될 듯

# 접속
kubectl exec -it curltest -- sh

# pod 삭제
kubectl delete pod curltest
```