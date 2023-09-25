#!/usr/bin/env bash

# Tell build process to exit if there are any errors.
set -oue pipefail

wget "https://copr.fedorainfracloud.org/coprs/ublue-os/staging/repo/fedora-$(rpm -E %fedora)/ublue-os-staging-fedora-$(rpm -E %fedora).repo" \
    -O "/etc/yum.repos.d/_copr_ublue-os_staging.repo"

if rpm -qa | grep power-profiles-daemon ; then
    rpm-ostree remove power-profiles-daemon --install=fprintd --install=tlp --install=tlp-rdw
else
    rpm-ostree install fprintd tlp tlp-rdw
fi
systemctl enable tlp
systemctl enable fprintd
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_ublue-os_staging.repo

