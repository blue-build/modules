#!/usr/bin/env bash

# Tell build process to exit if there are any errors.
set -oue pipefail

BIN_DIR=/usr/bin

wget -O /tmp/docker-compose 'https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64' 
install -c -m 0755 /tmp/docker-compose ${BIN_DIR}

wget -O /tmp/kind "https://github.com/kubernetes-sigs/kind/releases/latest/download/kind-linux-amd64"
install -c -m 0755 /tmp/kind ${BIN_DIR}

wget -O /tmp/kubectx "https://raw.githubusercontent.com/ahmetb/kubectx/master/kubectx"
install -c -m 0755 /tmp/kubectx ${BIN_DIR}

wget -O /usr/bin/kubens "https://raw.githubusercontent.com/ahmetb/kubectx/master/kubens"
install -c -m 0755 /tmp/kubens ${BIN_DIR} 
