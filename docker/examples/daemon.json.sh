# 
# /etc/docker/daemon.json  # Registry and Logging settings  
# 

# 로그 설정 없을시 disk full
# k3s와 함께 사용시 로그max-size는 반드시 10m 고정(로그파일로테이션 오류확률 감소)
URL_DOCKER=${URL_DOCKER:-"docker.wai"}  # If not set, default used
cat <<EOF > /tmp/daemon.json
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "100"
  },
  "insecure-registries": ["${URL_DOCKER}"],
  "registry-mirrors": ["http://${URL_DOCKER}"]
}
EOF

sudo mkdir -p /etc/docker
sudo mv /tmp/daemon.json /etc/docker/daemon.json

sudo systemctl restart docker