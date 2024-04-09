#!/usr/bin/env bash

# Tell build process to exit if there are any errors.
set -euo pipefail

# Pull in repos
get_yaml_array REPOS '.repos[]' "$1"
if [[ ${#REPOS[@]} -gt 0 ]]; then
    echo "Adding repositories"
    for REPO in "${REPOS[@]}"; do
        REPO="${REPO//%OS_VERSION%/${OS_VERSION}}"
        wget "${REPO//[$'\t\r\n ']}" -P "/etc/yum.repos.d/"
    done
fi

get_yaml_array INSTALL '.install[]' "$1"
get_yaml_array REMOVE '.remove[]' "$1"

# The installation is done with some wordsplitting hacks
# because of errors when doing array destructuring at the installation step.
# This is different from other ublue projects and could be investigated further.
INSTALL_STR=$(echo "${INSTALL[*]}" | tr -d '\n')
REMOVE_STR=$(echo "${REMOVE[*]}" | tr -d '\n')

# Enable experimental optfix environment variable in rpm-ostree
mkdir -p /usr/etc/systemd/system/rpm-ostreed.service.d/
echo -e "[Service]\nEnvironment=RPMOSTREE_EXPERIMENTAL_FORCE_OPT_USRLOCAL_OVERLAY=1" > /usr/etc/systemd/system/rpm-ostreed.service.d/state-overlay.conf
systemctl daemon-reload
systemctl restart rpm-ostreed

# Install and remove RPM packages
if [[ ${#INSTALL[@]} -gt 0 && ${#REMOVE[@]} -gt 0 ]]; then
    echo "Installing & Removing RPMs"
    echo "Installing: ${INSTALL_STR[*]}"
    echo "Removing: ${REMOVE_STR[*]}"
    # Doing both actions in one command allows for replacing required packages with alternatives
    rpm-ostree override remove $REMOVE_STR $(printf -- "--install=%s " $INSTALL_STR)
elif [[ ${#INSTALL[@]} -gt 0 ]]; then
    echo "Installing RPMs"
    echo "Installing: ${INSTALL_STR[*]}"
    rpm-ostree install $INSTALL_STR
elif [[ ${#REMOVE[@]} -gt 0 ]]; then
    echo "Removing RPMs"
    echo "Removing: ${REMOVE_STR[*]}"
    rpm-ostree override remove $REMOVE_STR
fi
