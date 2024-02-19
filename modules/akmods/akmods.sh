#!/usr/bin/env bash
set -euo pipefail

function ENABLE_MULTIMEDIA_REPO {
  sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/_copr_ublue-os-akmods.repo
  sed -i "0,/enabled/ s@enabled=0@enabled=1@g" /etc/yum.repos.d/negativo17-fedora-multimedia.repo
}

function DISABLE_MULTIMEDIA_REPO {
  sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/negativo17-fedora-multimedia.repo
}

function SET_HIGHER_PRIORITY_AKMODS_REPO {
  echo "priority=90" >> /etc/yum.repos.d/_copr_ublue-os-akmods.repo
}

get_yaml_array INSTALL '.install[]' "$1"
SURFACE=$(rpm -qa --queryformat '%{NAME}\n' | awk '$0 == "kernel-surface"')

INSTALL_PATH=("${INSTALL[@]/#/\/tmp/rpms/kmods/*}")
INSTALL_PATH=("${INSTALL_PATH[@]/%/*.rpm}")
INSTALL_STR=$(echo "${INSTALL_PATH[*]}" | tr -d '\n')

if [[ ${#INSTALL[@]} -gt 0 ]]; then
  echo "Installing akmods"
  echo "Installing: $(echo "${INSTALL[*]}" | tr -d '\n')"
  if [[ -n "$SURFACE" ]]; then
    SET_HIGHER_PRIORITY_AKMODS_REPO
    ENABLE_MULTIMEDIA_REPO
    rpm-ostree install kernel-surface-devel-matched $INSTALL_STR
    DISABLE_MULTIMEDIA_REPO
  else
    SET_HIGHER_PRIORITY_AKMODS_REPO
    ENABLE_MULTIMEDIA_REPO
    rpm-ostree install kernel-devel-matched $INSTALL_STR
    DISABLE_MULTIMEDIA_REPO
  fi  
fi    
