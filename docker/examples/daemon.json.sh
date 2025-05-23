# 
# /etc/docker/daemon.json  # Registry and Logging settings  
# 
URL_DOCKER=${URL_DOCKER:-"docker.wai"}  # If not set, default used
cat <<EOF > /tmp/daemon.json
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "200m",
    "max-file": "5"
  },
  "insecure-registries": ["${URL_DOCKER}"],
  "registry-mirrors": ["http://${URL_DOCKER}"]
}
EOF

sudo mkdir -p /etc/docker
sudo mv /tmp/daemon.json /etc/docker/daemon.json

sudo systemctl restart docker