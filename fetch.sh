#!/bin/sh
set -euo pipefail
FILES_ROOT="/tmp/ublue-os/files"

wget -O /tmp/intelmono.zip 'https://github.com/intel/intel-one-mono/releases/latest/download/ttf.zip'
unzip /tmp/intelmono.zip -d "/tmp/intelmono"
mv /tmp/intelmono/ttf "$FILES_ROOT/usr/share/fonts/intel-one-mono"

# wget -O /tmp/ublue-os/rpms/devpod.rpm "https://github.com/loft-sh/devpod/releases/latest/download/DevPod_linux_x86_64.rpm"

# wget -O /tmp/devpod "https://github.com/loft-sh/devpod/releases/latest/download/devpod-linux-amd64"
# install -c -m 0755 /tmp/devpod "$FILES_ROOT/usr/bin"

wget -O /tmp/docker-compose 'https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64' 
install -c -m 0755 /tmp/docker-compose "$FILES_ROOT/usr/bin"

wget -O /tmp/kind "https://github.com/kubernetes-sigs/kind/releases/latest/download/kind-linux-amd64"
install -c -m 0755 /tmp/kind "$FILES_ROOT/usr/bin"

wget -O /tmp/kubectx "https://raw.githubusercontent.com/ahmetb/kubectx/master/kubectx"
install -c -m 0755 /tmp/kubectx "$FILES_ROOT/usr/bin"

wget -O /tmp/kubens "https://raw.githubusercontent.com/ahmetb/kubectx/master/kubens"
install -c -m 0755 /tmp/kubens "$FILES_ROOT/usr/bin"

export DIVE_VERSION=$(curl -sL "https://api.github.com/repos/wagoodman/dive/releases/latest" | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')
wget -O /tmp/ublue-os/rpms/dive.rpm "https://github.com/wagoodman/dive/releases/download/v${DIVE_VERSION}/dive_${DIVE_VERSION}_linux_amd64.rpm"

wget -O /tmp/kubectl "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
wget -O /tmp/kubectl.sha256 "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
cd /tmp
echo "$(cat /tmp/kubectl.sha256)  kubectl" | sha256sum --check
install -c -m 0755 /tmp/kubectl "$FILES_ROOT/usr/bin"
