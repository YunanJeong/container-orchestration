# Docker

## 도커 설치 유형 및 라이센스 정리

[설치유형 및 라이센스](https://github.com/YunanJeong/container-orchestration/blob/main/docker/docker_license_history.md)

## 최신 Docker Engine (docker-ce) 및 CLI 설치

- docker-ce는 현재 공식명칭은 아니지만, 패키지명으로 남아있으며 여전히 Docker Engine을 관례적으로 가리키는 말이다.
- **Apache 2.0 License**  (출처: [[1]](https://docs.docker.com/engine/#licensing) [[2]](https://github.com/moby/moby/blob/master/LICENSE))
  - 사람들이 많이쓰는, 회사에서도 사용가능한 버전
- [Ubuntu에서 설치방법(공식)](https://docs.docker.com/engine/install/ubuntu/)
  - 레포지토리 등록 후 apt install
  - 또는, deb패키지파일을 다운받아서 설치

```shell
# Delete Legacy
for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt-get remove $pkg; done

# Install
# https://docs.docker.com/engine/install/ubuntu/
sudo apt-get update -y
sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update -y

sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Non-root settings
# https://docs.docker.com/engine/install/linux-postinstall/#manage-docker-as-a-non-root-user
sudo groupadd docker
sudo usermod -aG docker $USER
# sudo is required case by case
newgrp docker
```

- [WSL에서 설치시 참고(init vs. systemd)](https://github.com/YunanJeong/linux-tips/blob/main/wsl/wsl_servicedaemon.md)
  - Docker Engine은 백그라운드로 항상 실행되는 프로세스로, 현재 작동 유무 체크를 위해 서비스 관리자가 필요
- [도커를 non-root 권한으로 사용하기](https://docs.docker.com/engine/install/linux-postinstall/#manage-docker-as-a-non-root-user)
  - 종종 필요하다.

## Docker 클린 삭제

```sh

# 도커 런타임 툴 삭제
for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt-get remove $pkg; done
sudo apt-get purge -y docker-engine docker docker.io docker-ce
sudo apt-get autoremove -y --purge docker-engine docker docker.io docker-ce

# 이미지, 컨테이너 및 기타 설정 제거
sudo rm -rf /var/lib/docker /etc/docker ~/.docker
sudo rm /etc/apparmor.d/docker
sudo groupdel docker
sudo rm -rf /var/run/docker.sock
```
