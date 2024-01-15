#!/usr/bin/env bash

# Tell build process to exit if there are any errors.
set -euo pipefail

wget -O "/etc/yum.repos.d/_copr_kylegospo-gnome-vrr.repo" "https://copr.fedorainfracloud.org/coprs/kylegospo/gnome-vrr/repo/fedora-${OS_VERSION}/kylegospo-gnome-vrr-fedora-${OS_VERSION}.repo"

rpm-ostree override replace --experimental --from repo=copr:copr.fedorainfracloud.org:kylegospo:gnome-vrr mutter mutter-common gnome-control-center gnome-control-center-filesystem xorg-x11-server-Xwayland

rm -f /etc/yum.repos.d/_copr_kylegospo-gnome-vrr.repo
