#!/usr/bin/env bash

# Tell build process to exit if there are any errors.
set -euo pipefail

# Check if rpmfusion is installed before running
if [[ "$(rpm -q rpmfusion-free-release)" == "rpmfusion-free-release"* && "$(rpm -q rpmfusion-nonfree-release)" == "rpmfusion-nonfree-release"* ]]; then

    echo "uninstalling rpmfusion..."
    rpm-ostree uninstall rpmfusion-free-release rpmfusion-nonfree-release

fi 

# check if negativo17 repo is installed
if [[ -f /etc/yum.repos.d/negativo17-fedora-multimedia.repo ]]; then

    echo "negativo17 repo is already installed"
    echo "making sure negativo17 repo is enabled"
    sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/negativo17-fedora-multimedia.repo

else

    echo "installing negativo17 repo..."
    curl -Lo /etc/yum.repos.d/negativo17-fedora-multimedia.repo https://negativo17.org/repos/fedora-multimedia.repo

    echo "setting negativo17 repo priority to 90..."
    sed -i '0,/enabled=1/{s/enabled=1/enabled=1\npriority=90/}' /etc/yum.repos.d/negativo17-fedora-multimedia.repo

fi