wget "https://copr.fedorainfracloud.org/coprs/ublue-os/staging/repo/fedora-$(rpm -E %fedora)/ublue-os-staging-fedora-$(rpm -E %fedora).repo" \
    -O "/etc/yum.repos.d/_copr_ublue-os_staging.repo"
rpm-ostree remove power-profiles-daemon --install fprintd tlp tlp-rdw
systemctl enable tlp
systemctl enable fprintd
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/_copr_ublue-os_staging.repo

