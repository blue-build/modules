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
    rpm-ostree override remove ublue-os-update-services
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
pip install --prefix=/usr topgrade
rpm-ostree install ublue-update
