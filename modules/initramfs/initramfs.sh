#!/usr/bin/env bash

set -euo pipefail

if ! command -v rpm-ostree &> /dev/null || ! command -v bootc &> /dev/null; then
  echo "This module is only compatible with Fedora Atomic images"
  exit 1
fi  

if [[ "${OS_VERSION}" -le 40 ]]; then
  echo "This module is only compatible with Fedora 41+ images."
  exit 1
fi

# If images already installed cliwrap, use it. Only used in transition period, so it should be removed when base images like Ublue remove cliwrap
if [[ -f "/usr/libexec/rpm-ostree/wrapped/dracut" ]]; then
  DRACUT="/usr/libexec/rpm-ostree/wrapped/dracut"
else
  DRACUT="/usr/bin/dracut"
fi

# NOTE!
# This won't work when Fedora starts to utilize UKIs (Unified Kernel Images).
# UKIs will contain kernel + initramfs + bootloader.
# Refactor the module to support UKIs once they are starting to be used, if possible.
# That won't be soon, so this module should work for good period of time

KERNEL_MODULES_PATH="/usr/lib/modules"
readarray -t QUALIFIED_KERNEL < <(find "${KERNEL_MODULES_PATH}" -mindepth 1 -maxdepth 1 -type d -printf "%f\n")

if [[ "${#QUALIFIED_KERNEL[@]}" -gt 1 ]]; then
  echo "NOTE: There are several versions of kernel's initramfs."
  echo "      There is a possibility that you have multiple kernels installed in the image."
  echo "      It is most ideal to have only 1 kernel, to make initramfs regeneration faster."
fi

for qual_kernel in "${QUALIFIED_KERNEL[@]}"; do
  INITRAMFS_IMAGE="${KERNEL_MODULES_PATH}/${qual_kernel}/initramfs.img"
  echo "Starting initramfs regeneration for kernel version: ${qual_kernel}"
  "${DRACUT}" --no-hostonly --kver "${qual_kernel}" --reproducible -v --add ostree -f "${INITRAMFS_IMAGE}"
  chmod 0600 "${INITRAMFS_IMAGE}"
done
