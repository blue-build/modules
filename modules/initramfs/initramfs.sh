#!/usr/bin/env bash

set -euo pipefail

if ! command -v rpm-ostree &> /dev/null || ! command -v bootc &> /dev/null; then
  echo "This module is only compatible with Fedora Atomic images"
  exit 1
fi  

if [[ "${OS_VERSION}" -le 40 ]]; then
  echo "This module is only compatible with Fedora 41+ images."
  echo "While it is possible to make this module work with some older Fedora versions, by installing now-depreciated cliwrap,"
  echo "It is an unsupported functionality, which we don't want to enable."
  echo "If you wish to make this work, you would need to install cliwrap manually:"
  echo "rpm-ostree cliwrap install-to-root /"
  echo "And modify dracut's command to cliwrapped one in module's script:"
  echo "/usr/libexec/rpm-ostree/wrapped/dracut"
  exit 1
fi

# NOTE!
# This won't work when Fedora starts to utilize UKIs (Unified Kernel Images).
# UKIs will contain kernel + initramfs + bootloader.
# Refactor the module to support UKIs once they are starting to be used, if possible.
# That won't be soon, so this module should work for good period of time

KERNEL_MODULES_PATH="/usr/lib/modules"
readarray -t QUALIFIED_KERNEL < <(find "${KERNEL_MODULES_PATH}" -mindepth 1 -maxdepth 1 -type d -printf "%f\n")
INITRAMFS_IMAGE="${KERNEL_MODULES_PATH}/${QUALIFIED_KERNEL[*]}/initramfs.img"

if [[ "${#QUALIFIED_KERNEL[@]}" -gt 1 ]]; then
  echo "ERROR: There are several versions of kernel's initramfs."
  echo "       Cannot determine which one to regenerate."
  echo "       There is a possibility that you have multiple kernels installed in the image."
  echo "       Please only include 1 kernel in the image to solve this issue."
  exit 1
fi

echo "Initramfs regeneration is performing for kernel version: ${QUALIFIED_KERNEL[*]}"

dracut --no-hostonly --kver "${QUALIFIED_KERNEL[*]}" --reproducible -v --add ostree -f "${INITRAMFS_IMAGE}"
chmod 0600 "${INITRAMFS_IMAGE}"
