#!/usr/bin/env bash

# Tell build process to exit if there are any errors.
set -euo pipefail

get_config_value() {
    sed -n '/^'"$1"'=/{s/'"$1"'=//;p}' "$2"
}

set_config_value() {
    CURRENT=$(get_config_value "$1" "$3")
    sed -i 's/'"$1"'='"$CURRENT"'/'"$1"'='"$2"'/g' "$3"
}

# Check if ublue-os-update-services rpm is installed, these services conflict with ublue-update
if rpm -q ublue-os-update-services > /dev/null; then
    if command -v dnf 1> /dev/null; then
      dnf remove ublue-os-update-services
    elif command -v rpm-ostree 1> /dev/null; then
      rpm-ostree override remove ublue-os-update-services
    fi
fi

# Change the conflicting update policy for rpm-ostreed
RPM_OSTREE_CONFIG="/etc/rpm-ostreed.conf"

if [[ -f "$RPM_OSTREE_CONFIG" ]]; then
    if [[ $(get_config_value "AutomaticUpdatePolicy" "$RPM_OSTREE_CONFIG") == "stage" ]]; then
        set_config_value "AutomaticUpdatePolicy" "none" "$RPM_OSTREE_CONFIG"
    fi
fi
systemctl disable rpm-ostreed-automatic.timer

# topgrade is REQUIRED by ublue-update to install
# we have to rely on 3rd party COPR repo for topgrade & on clunky skopeo + file workaround for ublue-update ghcr container,
# because Universal Blue removed them in their copr repo
if command -v dnf 1> /dev/null; then
  dnf copr enable lilay/topgrade
  dnf install topgrade skopeo
  mkdir -p /tmp/ublue-update
  skopeo copy docker://ghcr.io/ublue-os/ublue-update:latest oci:/tmp/ublue-update/ublue-update:latest
  GZIP="$(file /tmp/ublue-update/ublue-update/*/*/* | grep 'gzip compressed data' | cut -d: -f1)"
  tar -xzf "$GZIP" --strip-components=1 -C /tmp/ublue-update rpms/
  dnf install /tmp/ublue-update/ublue-update.noarch.rpm
elif command -v rpm-ostree 1> /dev/null; then
  topgrade_url="https://copr.fedorainfracloud.org/coprs/lilay/topgrade/repo/fedora-${OS_VERSION}/lilay-topgrade-fedora-${OS_VERSION}.repo"
  echo "Downloading topgrade repo ${topgrade_url}"
  curl -fLs --create-dirs "${topgrade_url}" -o "/etc/yum.repos.d/_copr_topgrade.repo"
  echo "Downloaded topgrade repo ${topgrade_url}"
  rpm-ostree install topgrade skopeo
  mkdir -p /tmp/ublue-update
  skopeo copy docker://ghcr.io/ublue-os/ublue-update:latest oci:/tmp/ublue-update/ublue-update:latest
  GZIP="$(file /tmp/ublue-update/ublue-update/*/*/* | grep 'gzip compressed data' | cut -d: -f1)"
  tar -xzf "$GZIP" --strip-components=1 -C /tmp/ublue-update rpms/
  rpm-ostree install /tmp/ublue-update/ublue-update.noarch.rpm
fi
# Fix files present in /usr/etc in RPM spec
if [[ -d /usr/etc/ublue-update ]]; then
  mv /usr/etc/ublue-update /etc/ublue-update
fi

rm -rf /tmp/ublue-update
