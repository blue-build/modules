#!/usr/bin/env bash
set -euo pipefail

function ENABLE_MULTIMEDIA_REPO {
  sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/_copr_ublue-os-akmods.repo && sed -i "0,/enabled/ s@enabled=0@enabled=1@g" /etc/yum.repos.d/negativo17-fedora-multimedia.repo;
}

function DISABLE_MULTIMEDIA_REPO {
  sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/negativo17-fedora-multimedia.repo;
}

get_yaml_array INSTALL '.install[]' "$1"

INSTALL_PATH=("${INSTALL[@]/#/\/tmp/rpms/kmods/*}")
INSTALL_PATH=("${INSTALL_PATH[@]/%/*.rpm}")
INSTALL_STR=$(echo "${INSTALL_PATH[*]}" | tr -d '\n')

if [[ ${#INSTALL[@]} -gt 0 ]]; then
  echo "Installing akmods"
  echo "Installing: $(echo "${INSTALL[*]}" | tr -d '\n')"
  if [[ "$BASE_IMAGE" =~ "surface" ]]; then
    ENABLE_MULTIMEDIA_REPO
    rpm-ostree install kernel-surface-devel-matched $INSTALL_STR
    DISABLE_MULTIMEDIA_REPO
  else
    ENABLE_MULTIMEDIA_REPO
    rpm-ostree install kernel-devel-matched $INSTALL_STR
    DISABLE_MULTIMEDIA_REPO
  fi  
fi    
