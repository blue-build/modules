#!/usr/bin/env bash

# Tell build process to exit if there are any errors.
set -euo pipefail

# Check if rpmfusion is already installed before running
if [[ "$(rpm -q rpmfusion-free-release)" != "rpmfusion-free-release"* && "$(rpm -q rpmfusion-nonfree-release)" != "rpmfusion-nonfree-release"* ]]; then

    echo "running rpmfusion install..."
    rpm-ostree install \
        "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-${OS_VERSION}.noarch.rpm" \
        "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${OS_VERSION}.noarch.rpm"

    # check if negativo17 repo is installed
    if [[ -f /etc/yum.repos.d/negativo17-fedora-multimedia.repo ]]; then
        echo "making sure negativo17 repo is disabled"
        sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/negativo17-fedora-multimedia.repo
    fi

else

    echo "rpmfusion is already installed"

fi