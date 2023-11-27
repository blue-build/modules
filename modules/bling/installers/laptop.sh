#!/usr/bin/env bash

# Tell build process to exit if there are any errors.
set -oue pipefail

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
cp -r "$BLING_DIRECTORY"/files/laptop/usr/etc/tlp.d/* /usr/etc/tlp.d/
cp -r "$BLING_DIRECTORY"/files/laptop/usr/share/ublue-os/just/bling/* /usr/share/ublue-os/just/bling/
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_ublue-os_staging.repo

