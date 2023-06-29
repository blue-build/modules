#!/bin/sh
set -euo pipefail
FILES_ROOT="/tmp/ublue-os/files"

git clone 'https://github.com/ryanoasis/nerd-fonts' /tmp/nerdfonts
mv /tmp/nerdfonts/patched-fonts/* "$FILES_ROOT/usr/share/fonts"

git clone 'https://github.com/dnkmmr69420/nix-installer-scripts' /tmp/nix-installer-scripts
mv /tmp/nix-installers-scripts/installer-scripts/silverblue-nix-installer.sh "$FILES_ROOT/usr/bin/ublue-nix-install"
mv /tmp/nix-installers-scripts/uninstaller-scripts/silverblue-nix-uninstaller.sh "$FILES_ROOT/usr/bin/ublue-nix-uninstall"

wget -O /tmp/devpod "https://github.com/loft-sh/devpod/releases/latest/download/devpod-linux-amd64"
install -c -m 0755 /tmp/devpod "$FILES_ROOT/usr/bin"

wget -O /tmp/devpod.rpm https://github.com/loft-sh/devpod/releases/latest/download/DevPod_linux_x86_64.rpm 
mv /tmp/devpod.rpm /tmp/ublue-os/rpms