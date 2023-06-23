# Skaffold
- 컨테이너 기반 및 Kubernetes 애플리케이션의 지속적인 개발을 촉진하는 CLI 툴
- K8s 앱의 지속적 배포를 위한 구글 자체 툴

## 쓰는 이유
- 빠른 로컬 K8s 개발
- 공유 및 배포 편의성 (지속적배포CD, GitOps 등)
- skaffold.yaml: 설정 파일 딱 한 개
- 가벼움(client-side only): K8s 클러스터측에 설치해야하는 에이전트가 없음

## 문서
- https://skaffold.dev/docs/

## 설치
```
# For Linux x86_64 (amd64)
curl -Lo skaffold https://storage.googleapis.com/skaffold/releases/latest/skaffold-linux-amd64 && \
sudo install skaffold /usr/local/bin/
```
