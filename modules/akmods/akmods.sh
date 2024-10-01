#!/usr/bin/env bash
set -euo pipefail

enable_multimedia_repo() {
  sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/_copr_ublue-os-akmods.repo
  sed -i "0,/enabled/ s@enabled=0@enabled=1@g" /etc/yum.repos.d/negativo17-fedora-multimedia.repo
}
readonly -f enable_multimedia_repo

disable_multimedia_repo() {
  sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/negativo17-fedora-multimedia.repo
}
readonly -f disable_multimedia_repo

set_higher_priority_akmods_repo() {
  echo "priority=90" >> /etc/yum.repos.d/_copr_ublue-os-akmods.repo
}
readonly -f set_higher_priority_akmods_repo

get_yaml_array INSTALL '.install[]' "$1"

INSTALL_PATH=("${INSTALL[@]/#/\/tmp/rpms/kmods/*}")
readonly INSTALL_PATH=("${INSTALL_PATH[@]/%/*.rpm}")
readonly INSTALL_STR=$(echo "${INSTALL_PATH[*]}" | tr -d '\n')

if [[ ${#INSTALL[@]} -gt 0 ]]; then
  echo "Installing akmods"
  echo "Installing: $(echo "${INSTALL[*]}" | tr -d '\n')"
  set_higher_priority_akmods_repo
  enable_multimedia_repo
  rpm-ostree install ${INSTALL_STR}
  disable_multimedia_repo
fi    
