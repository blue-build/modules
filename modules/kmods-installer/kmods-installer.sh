#!/usr/bin/env bash
set -oue pipefail

get_yaml_array INSTALL '.install[]' "$1"

INSTALL_PATH=("${INSTALL[@]/#/\/tmp/rpms/kmods/*}")
INSTALL_PATH=("${INSTALL_PATH[@]/%/*.rpm}")
INSTALL_STR=$(echo "${INSTALL_PATH[*]}" | tr -d '\n')

if [[ ${#INSTALL[@]} -gt 0 ]]; then
    echo "Installing kmods"
    echo "Installing: $(echo "${INSTALL[*]}" | tr -d '\n')"

    rpm-ostree install kernel-devel-matched $INSTALL_STR
fi
