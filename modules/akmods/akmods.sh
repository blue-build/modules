#!/usr/bin/env bash
set -euo pipefail

ENABLE_MULTIMEDIA_REPO() {
    sed -i 's@enabled=0@enabled=1@g' /etc/yum.repos.d/_copr_ublue-os-akmods.repo
    sed -i "0,/enabled/ s@enabled=0@enabled=1@g" /etc/yum.repos.d/negativo17-fedora-multimedia.repo
}

DISABLE_MULTIMEDIA_REPO() {
    sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/negativo17-fedora-multimedia.repo
}

SET_HIGHER_PRIORITY_AKMODS_REPO() {
    echo "priority=90" >> /etc/yum.repos.d/_copr_ublue-os-akmods.repo
}

INSTALL_AKMODS() {
    rpm-ostree install kernel-devel-matched "${INSTALL_STR}"
}

INSTALL_SURFACE_AKMODS() {
    rpm-ostree install kernel-surface-devel-matched "${INSTALL_STR}"
}

# Credits: Universal Blue "-nvidia" repo, install.sh & post-install.sh
# https://github.com/ublue-os/nvidia
INSTALL_NVIDIA_DRIVER() {
    # install.sh
    if [[ "${OS_VERSION}" -le "38" ]]; then
        sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/fedora-{cisco-openh264,modular,updates-modular}.repo
    else
        sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/fedora-cisco-openh264.repo
    fi
    rpm-ostree install \
    /tmp/rpms/ublue-os/ublue-os-nvidia-addons-*.rpm
    source /tmp/rpms/kmods/nvidia-vars."${NVIDIA_VERSION}"
    if [[ "${OS_VARIANT}" == "kinoite" ]]; then
      VARIANT_PKGS="supergfxctl-plasmoid"
    elif [[ "${OS_VARIANT}" == "silverblue" ]]; then
      VARIANT_PKGS="gnome-shell-extension-supergfxctl-gex"
    else
      VARIANT_PKGS=""
    fi
    rpm-ostree install \
    xorg-x11-drv-"${NVIDIA_PACKAGE_NAME}"-{,cuda-,devel-,kmodsrc-,power-}"${NVIDIA_FULL_VERSION}" \
    xorg-x11-drv-"${NVIDIA_PACKAGE_NAME}"-libs.i686 \
    nvidia-container-toolkit nvidia-vaapi-driver supergfxctl "${VARIANT_PKGS}" \
    /tmp/rpms/kmods/kmod-"${NVIDIA_PACKAGE_NAME}"-"${KERNEL_VERSION}"-"${NVIDIA_AKMOD_VERSION}".fc"${RELEASE}".rpm
    
    # post-install.sh
    sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/{eyecantcu-supergfxctl,nvidia-container-toolkit}.repo
    systemctl enable ublue-nvctk-cdi.service
    semodule --verbose --install /usr/share/selinux/packages/nvidia-container.pp
    if [[ "${OS_VARIANT}" == "sway-atomic" ]] || [[ "${OS_VARIANT}" == "sericea" ]]; then
      mv /etc/sway/environment{,.orig}
      install -Dm644 /usr/share/ublue-os/etc/sway/environment /etc/sway/environment
    fi
}

OS_VARIANT=$(grep -Po 'VARIANT_ID=\K\w+' /usr/lib/os-release)
NVIDIA_VERSION=$(echo "$1" | yq -I=0 ".nvidia-version")
NVIDIA=$(rpm -qa --queryformat '%{NAME}\n' | grep "nvidia")
SURFACE=$(rpm -qa --queryformat '%{NAME}\n' | awk '$0 == "kernel-surface"')

get_yaml_array INSTALL '.install[]' "$1"
INSTALL_PATH=("${INSTALL[@]/#/\/tmp/rpms/kmods/*}")
INSTALL_PATH=("${INSTALL_PATH[@]/%/*.rpm}")
INSTALL_STR=$(echo "${INSTALL_PATH[*]}" | tr -d '\n')

# Errors out if unsupported Nvidia driver version is specified in recipe.
# Needs to be updated whenever new Nvidia driver releases for check to work properly
if [[ -n "${NVIDIA_VERSION}" ]]; then
  if [[ ! "${NVIDIA_VERSION}" == "550" ]] && [[ ! "${NVIDIA_VERSION}" == "470" ]]; then
    echo "You provided unsupported Nvidia akmod version in nvidia-version recipe entry, only v550 & v470 are supported."
    exit 1
  fi
fi  

if [[ ${#INSTALL[@]} -gt 0 ]]; then
  echo "Installing akmods"
  echo "Installing: $(echo "${INSTALL[*]}" | tr -d '\n')"
  if [[ -n "${SURFACE}" ]] && [[ -z "${NVIDIA}" ]] && [[ -n "${NVIDIA_VERSION}" ]]; then
    SET_HIGHER_PRIORITY_AKMODS_REPO
    ENABLE_MULTIMEDIA_REPO
    INSTALL_SURFACE_AKMODS
    DISABLE_MULTIMEDIA_REPO
    INSTALL_NVIDIA_DRIVER
  elif [[ -z "${SURFACE}" ]] && [[ -z "${NVIDIA}" ]] && [[ -n "${NVIDIA_VERSION}" ]]; then
    SET_HIGHER_PRIORITY_AKMODS_REPO
    ENABLE_MULTIMEDIA_REPO
    INSTALL_AKMODS
    DISABLE_MULTIMEDIA_REPO    
    INSTALL_NVIDIA_DRIVER
  elif [[ -n "${SURFACE}" ]] && [[ -z "${NVIDIA_VERSION}" ]]; then
    SET_HIGHER_PRIORITY_AKMODS_REPO
    ENABLE_MULTIMEDIA_REPO
    INSTALL_SURFACE_AKMODS
    DISABLE_MULTIMEDIA_REPO
  elif [[ -z "${SURFACE}" ]] && [[ -z "${NVIDIA_VERSION}" ]]; then
    SET_HIGHER_PRIORITY_AKMODS_REPO
    ENABLE_MULTIMEDIA_REPO
    INSTALL_AKMODS
    DISABLE_MULTIMEDIA_REPO
  fi  
fi    
