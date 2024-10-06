#!/usr/bin/env bash
set -euo pipefail

ENABLE_AKMODS_REPO() {
  sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/_copr_ublue-os-akmods.repo
}

SET_HIGHER_PRIORITY_AKMODS_REPO() {
  echo "priority=90" >> /etc/yum.repos.d/_copr_ublue-os-akmods.repo
}

INSTALL_RPM_FUSION() {
  rpm-ostree install \
      https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-${OS_VERSION}.noarch.rpm \
      https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${OS_VERSION}.noarch.rpm
}

UNINSTALL_RPM_FUSION() {
  rpm-ostree uninstall rpmfusion-free-release rpmfusion-nonfree-release
}

get_yaml_array INSTALL '.install[]' "$1"

if [[ ${#INSTALL[@]} -lt 1 ]]; then
  echo "ERROR: You didn't specify any akmod for installation!"
  exit 1
fi

INSTALL_PATH=("${INSTALL[@]/#/\/tmp/rpms/kmods/*}")
INSTALL_PATH=("${INSTALL_PATH[@]/%/*.rpm}")
INSTALL_STR=$(echo "${INSTALL_PATH[*]}" | tr -d '\n')

# Universal Blue switched from RPMFusion to negativo17 repos
# Determine if RPMFusion for akmod is needed or not (WL & V4L2Loopback akmods currently require RPMFusion)

rpm_fusion_dependent=false
for akmod in "${INSTALL[@]}"; do
    if [[ "${akmod}" =~ ^(wl|v4l2loopback)$ ]]; then
        rpm_fusion_dependent=true
    fi
done

echo "Installing akmods"
echo "Installing: $(echo "${INSTALL[*]}" | tr -d '\n')"
SET_HIGHER_PRIORITY_AKMODS_REPO
ENABLE_AKMODS_REPO
if "${rpm_fusion_dependent}"; then
  INSTALL_RPM_FUSION
  rpm-ostree install ${INSTALL_STR}
  UNINSTALL_RPM_FUSION
else
  rpm-ostree install ${INSTALL_STR}
fi
