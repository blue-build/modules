#!/usr/bin/env bash
set -oue pipefail

BASED_IMAGE=$(echo "${BASE_IMAGE}")

get_yaml_array INSTALL '.install[]' "$1"

INSTALL_PATH=("${INSTALL[@]/#/\/tmp/rpms/kmods/*}")
INSTALL_PATH=("${INSTALL_PATH[@]/%/*.rpm}")
INSTALL_STR=$(echo "${INSTALL_PATH[*]}" | tr -d '\n')

if [[ ${#INSTALL[@]} -gt 0 ]]; then
  echo "Installing akmods"
  echo "Installing: $(echo "${INSTALL[*]}" | tr -d '\n')"
  if [[ "$BASED_IMAGE" =~ asus ]] || [[ "$BASED_IMAGE" =~ surface ]]; then
    rpm-ostree install kernel-tools $INSTALL_STR
    else
    rpm-ostree install kernel-devel-matched $INSTALL_STR
  fi  
fi
