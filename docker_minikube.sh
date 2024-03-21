#!/bin/bash

# Install Docker
sudo apt update && apt -y install docker.io

# Install kubectl
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl &&   chmod +x ./kubectl && sudo mv ./kubectl /usr/local/bin/kubectl

# Install minikube
curl -Lo minikube https://github.com/kubernetes/minikube/releases/download/v1.24.0/minikube-linux-amd64 && chmod +x minikube && sudo mv minikube /usr/local/bin/

# Install conntrack
apt install conntrack

# Install CRI-Dockerd
git clone https://github.com/Mirantis/cri-dockerd.git
wget https://storage.googleapis.com/golang/getgo/installer_linux
chmod +x ./installer_linux
./installer_linux
wget https://go.dev/dl/go1.21.2.linux-amd64.tar.gz
tar -C /usr/local -xzf go1.21.2.linux-amd64.tar.gz
sudo nano /root/.bashrc
# Set the Go environment variables in your shell profile (e.g., ~/.bashrc or ~/.profile):
            export GOROOT=/usr/local/go
            export GOPATH=$HOME/go
            export PATH=$PATH:$GOROOT/bin:$GOPATH/bin
source ~/.bash_profile
cd cri-dockerd
mkdir bin
go build -o bin/cri-dockerd
mkdir -p /usr/local/bin
install -o root -g root -m 0755 bin/cri-dockerd /usr/local/bin/cri-dockerd
cp -a packaging/systemd/* /etc/systemd/system
sed -i -e 's,/usr/bin/cri-dockerd,/usr/local/bin/cri-dockerd,' /etc/systemd/system/cri-docker.service
systemctl daemon-reload
systemctl enable cri-docker.service
systemctl enable --now cri-docker.socket

# Install crictl
wget https://github.com/kubernetes-sigs/cri-tools/releases/download/v1.24.0/crictl-v1.24.0-linux-amd64.tar.gz
sudo tar zxvf crictl-v1.24.0-linux-amd64.tar.gz -C /usr/local/bin
rm -f crictl-v1.24.0-linux-amd64.tar.gz

# Start minikube
minikube start --vm-driver=none

# Check minikube status
minikube status
