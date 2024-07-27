#!/usr/bin/env bash

# Tell build process to exit if there are any errors.
set -euo pipefail

if [[ $(gnome-shell --version) =~ "46" ]]; then
    echo "Attention: VRR is supported out of the box on GNOME 46, no need to install it separately. Use the following command to enable VRR on GNOME 46:"
    echo "gsettings set org.gnome.mutter experimental-features \"['variable-refresh-rate']\""
    exit 1
fi

wget -O "/etc/yum.repos.d/ublue-os-staging.repo" "https://copr.fedorainfracloud.org/coprs/ublue-os/staging/repo/fedora-${OS_VERSION}/ublue-os-staging-fedora-${OS_VERSION}.repo"

rpm-ostree override replace --experimental --from repo=copr:copr.fedorainfracloud.org:ublue-os:staging mutter mutter-common gnome-control-center gnome-control-center-filesystem xorg-x11-server-Xwayland

rm -f /etc/yum.repos.d/ublue-os-staging.repo