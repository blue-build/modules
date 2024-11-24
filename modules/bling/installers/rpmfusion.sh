#!/usr/bin/env bash

# Tell build process to exit if there are any errors.
set -euo pipefail

NEGATIVO_REPO_FILE="$(awk -F'=' '$1 == "name" && $2 == "negativo17 - Multimedia" {print FILENAME}' /etc/yum.repos.d/*)"

# Check if rpmfusion is already installed before running
if ! rpm -q rpmfusion-free-release &>/dev/null && ! rpm -q rpmfusion-nonfree-release &>/dev/null; then
  echo "Running RPMFusion repo install..."
  rpm-ostree install \
    "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-${OS_VERSION}.noarch.rpm" \
    "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${OS_VERSION}.noarch.rpm"
  # check if negativo17 repo is installed
  if [[ -n "${NEGATIVO_REPO_FILE}" ]]; then
    echo "Making sure that Negativo17 repo is disabled"
    sed -i 's@enabled=1@enabled=0@g' "${NEGATIVO_REPO_FILE}"
  fi
else
  echo "RPMFusion repo is already installed"
fi
