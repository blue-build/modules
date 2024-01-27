#!/usr/bin/env bash

# Tell build process to exit if there are any errors.
set -euo pipefail

MODULE_DIRECTORY="${MODULE_DIRECTORY:-"/tmp/modules"}"

wget "https://copr.fedorainfracloud.org/coprs/ublue-os/staging/repo/fedora-$(rpm -E %fedora)/ublue-os-staging-fedora-$(rpm -E %fedora).repo" \
    -O "/etc/yum.repos.d/_copr_ublue-os_staging.repo"
if rpm -qa | grep power-profiles-daemon ; then
    rpm-ostree override remove power-profiles-daemon --install=fprintd --install=tlp --install=tlp-rdw
else
    rpm-ostree install fprintd tlp tlp-rdw
fi
systemctl enable tlp
systemctl enable fprintd
mkdir -p /usr/etc/tlp.d
mkdir -p /usr/share/ublue-os/just/bling/
cp -r "$MODULE_DIRECTORY"/bling/50-laptop.conf /usr/etc/tlp.d/50-laptop.conf
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_ublue-os_staging.repo

