#!/usr/bin/env bash

# Tell build process to exit if there are any errors.
set -euo pipefail

NEGATIVO_REPO_FILE="$(awk -F'=' '$1 == "name" && $2 == "negativo17 - Multimedia" {print FILENAME}' /etc/yum.repos.d/*)"

# Check if rpmfusion is already installed before running
if ! rpm -q rpmfusion-free-release &>/dev/null || ! rpm -q rpmfusion-nonfree-release &>/dev/null || ! rpm -q rpmfusion-free-release-tainted &>/dev/null || ! rpm -q rpmfusion-nonfree-release-tainted &>/dev/null; then
  if ! rpm -q rpmfusion-free-release &>/dev/null || ! rpm -q rpmfusion-nonfree-release &>/dev/null; then
    echo "Running RPMFusion repos install..."
  fi
  if ! rpm -q rpmfusion-free-release &>/dev/null && ! rpm -q rpmfusion-nonfree-release &>/dev/null; then
    rpm-ostree install \
      "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-${OS_VERSION}.noarch.rpm" \
      "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${OS_VERSION}.noarch.rpm" || \
    rpm-ostree install \
      "https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-${OS_VERSION}.noarch.rpm" \
      "https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${OS_VERSION}.noarch.rpm"
  elif ! rpm -q rpmfusion-free-release &>/dev/null; then
    rpm-ostree install \
      "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-${OS_VERSION}.noarch.rpm" || \
    rpm-ostree install \
      "https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-${OS_VERSION}.noarch.rpm"
  elif ! rpm -q rpmfusion-nonfree-release &>/dev/null; then
    rpm-ostree install \
      "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${OS_VERSION}.noarch.rpm" || \
    rpm-ostree install \
      "https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${OS_VERSION}.noarch.rpm"
  fi
  if ! rpm -q rpmfusion-free-release-tainted &>/dev/null || ! rpm -q rpmfusion-nonfree-release-tainted &>/dev/null; then
    echo "Installing tainted RPMFusion repos"
  fi  
  if ! rpm -q rpmfusion-free-release-tainted &>/dev/null && ! rpm -q rpmfusion-nonfree-release-tainted &>/dev/null; then
    rpm-ostree install \
      rpmfusion-free-release-tainted \
      rpmfusion-nonfree-release-tainted
  elif ! rpm -q rpmfusion-free-release-tainted &>/dev/null; then
    rpm-ostree install \
      rpmfusion-free-release-tainted
  elif ! rpm -q rpmfusion-nonfree-release-tainted &>/dev/null; then
    rpm-ostree install \
      rpmfusion-nonfree-release-tainted
  fi 
  # check if negativo17 repo is installed
  if [[ -n "${NEGATIVO_REPO_FILE}" ]]; then
    echo "Making sure that Negativo17 repo is disabled"
    sed -i 's@enabled=1@enabled=0@g' "${NEGATIVO_REPO_FILE}"
  fi
else
  echo "RPMFusion repos are already installed"
fi
