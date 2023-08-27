#!/bin/sh
set -euo pipefail
FILES_ROOT="/tmp/ublue-os/files"

wget -O /tmp/devpod "https://github.com/loft-sh/devpod/releases/latest/download/devpod-linux-amd64"
install -c -m 0755 /tmp/devpod "$FILES_ROOT/usr/bin"

wget -O /tmp/devpod.rpm https://github.com/loft-sh/devpod/releases/latest/download/DevPod_linux_x86_64.rpm 
mv /tmp/devpod.rpm /tmp/ublue-os/rpms

wget -O /tmp/intelmono.zip 'https://github.com/intel/intel-one-mono/releases/latest/download/ttf.zip'
unzip /tmp/intelmono.zip -d "/tmp/intelmono"
mv /tmp/intelmono/ttf "$FILES_ROOT/usr/share/fonts/intel-one-mono"
