#!/usr/bin/env bash

# Tell build process to exit if there are any errors.
set -euo pipefail

if [[ $(gnome-shell --version) =~ "46" ]]; then
    echo "Attention: VRR is supported out of the box on GNOME 46, no need to install it separately. Use the following command to enable VRR on GNOME 46:"
    echo "gsettings set org.gnome.mutter experimental-features \"['variable-refresh-rate']\""
    exit 1
fi

REPO_URL="https://copr.fedorainfracloud.org/coprs/ublue-os/staging/repo/fedora-${OS_VERSION}/ublue-os-staging-fedora-${OS_VERSION}.repo"

echo "Downloading repo file ${REPO_URL}"
curl -fLs --create-dirs "${REPO_URL}" -o "/etc/yum.repos.d/ublue-os-staging.repo"
echo "Downloaded repo file ${REPO_URL}"

rpm-ostree override replace --experimental --from repo=copr:copr.fedorainfracloud.org:ublue-os:staging mutter mutter-common gnome-control-center gnome-control-center-filesystem xorg-x11-server-Xwayland

rm -f /etc/yum.repos.d/ublue-os-staging.repo
