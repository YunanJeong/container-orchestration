# K3s controlplane
curl -sfL https://get.k3s.io | sh -s - --docker

# K3s settings (Context and etc.)
# # kubeconfig(context 파일)의 소유자, 소유그룹이 실제 작업 user와 일치하면서 `chmod 600`을 하면 warning, permission denied 없이 사용가능
# mkdir -p ~/.kube  # KUBECONFIG=$HOME/.kube/config
KUBECONFIG=/etc/rancher/k3s/k3s.yaml
sudo chmod 600 $KUBECONFIG  
sudo chown $USER:$USER $KUBECONFIG

echo 'export KUBECONFIG=/etc/rancher/k3s/k3s.yaml' >> ~/.bashrc
echo 'alias k="kubectl"' >> ~/.bashrc
source ~/.bashrc

# helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# k9s
sudo apt install -y jq
K9S_VERSION=$(curl -s https://api.github.com/repos/derailed/k9s/releases/latest | jq -r '.tag_name')
curl -sL https://github.com/derailed/k9s/releases/download/${K9S_VERSION}/k9s_Linux_amd64.tar.gz | sudo tar xfz - -C /usr/local/bin k9s