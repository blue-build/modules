#!/usr/bin/env bash
set -euo pipefail

ENABLE_AKMODS_REPO() {
  sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/_copr_ublue-os-akmods.repo
}

INSTALL_RPM_FUSION() {
if ! rpm -q rpmfusion-free-release &>/dev/null && ! rpm -q rpmfusion-nonfree-release &>/dev/null; then
  rpm-ostree install \
      https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-${OS_VERSION}.noarch.rpm \
      https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${OS_VERSION}.noarch.rpm
  previously_not_installed_rpm_fusion=true
else
  previously_not_installed_rpm_fusion=false
fi
}

UNINSTALL_RPM_FUSION() {
if "${previously_not_installed_rpm_fusion}"; then
  rpm-ostree uninstall rpmfusion-free-release rpmfusion-nonfree-release
fi
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
# WL & V4L2Loopback akmods currently require RPMFusion repo, so we temporarily install then uninstall it

echo "Installing akmods"
echo "Installing: $(echo "${INSTALL[*]}" | tr -d '\n')"
ENABLE_AKMODS_REPO
INSTALL_RPM_FUSION
rpm-ostree install ${INSTALL_STR}
UNINSTALL_RPM_FUSION
