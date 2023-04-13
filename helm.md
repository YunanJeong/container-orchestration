# Helm Charts

# 시작하기

## 설치
- [공홈설치방법](https://helm.sh/docs/intro/install/)
- apt 설치
```
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
sudo apt-get install apt-transport-https --yes
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install helm
```
## 사전준비
- K8s 클러스터
- helm에 연결대상 클러스터의 정보를 등록
    - 이는 배포판마다 설정 방법이 조금씩 다름
    - k3s
    ```
    # 환경변수 사용
    export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
    ```

