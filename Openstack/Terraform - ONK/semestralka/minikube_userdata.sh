#!/bin/bash

nameserver="nameserver 8.8.8.8"
hostname="${minikube_name}"

# PRIDANIE DNS SERVERA
sudo echo "$nameserver" >> /etc/resolv.conf

sudo apt update

# HOSTNAME RESOLUTION
sudo echo "127.0.0.1 $hostname" >> "/etc/hosts"

# MINIKUBE - https://minikube.sigs.k8s.io/docs/start/
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# DOCKER - https://docs.docker.com/engine/install/ubuntu/
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg
sudo install -y -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo usermod -aG docker ubuntu && newgrp docker #$USER bol namiesto ubuntu

# KUBECTL - https://www.cherryservers.com/blog/install-kubectl-ubuntu
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin

# PERMANENTNY ALIAS K=KUBECTL (script nema rad ~)
echo 'alias k=kubectl' | cat - /home/ubuntu/.bashrc > temp && mv temp /home/ubuntu/.bashrc
source /home/ubuntu/.bashrc

# SIGNAL ZE UZ SKONCIL SCRIPT
touch /tmp/user_data_minikube_complete
