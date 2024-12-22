#!/usr/bin/env bash

# Tell build process to exit if there are any errors.
set -euo pipefail

# Check if rpmfusion is installed before running
if rpm -q rpmfusion-free-release &>/dev/null || rpm -q rpmfusion-nonfree-release &>/dev/null || rpm -q rpmfusion-free-release-tainted &>/dev/null || rpm -q rpmfusion-nonfree-release-tainted &>/dev/null; then
  if rpm -q rpmfusion-free-release &>/dev/null || rpm -q rpmfusion-nonfree-release &>/dev/null; then
    echo "Uninstalling RPMFusion repos..."
  fi
  if rpm -q rpmfusion-free-release &>/dev/null && rpm -q rpmfusion-nonfree-release &>/dev/null; then
    rpm-ostree uninstall rpmfusion-free-release rpmfusion-nonfree-release
  elif rpm -q rpmfusion-free-release &>/dev/null; then
    rpm-ostree uninstall rpmfusion-free-release
  elif rpm -q rpmfusion-nonfree-release &>/dev/null; then
    rpm-ostree uninstall rpmfusion-nonfree-release
  fi
  if rpm -q rpmfusion-free-release &>/dev/null || rpm -q rpmfusion-nonfree-release &>/dev/null; then
    echo "Uninstalling tainted RPMFusion repos..."
  fi
  if rpm -q rpmfusion-free-release-tainted &>/dev/null && rpm -q rpmfusion-nonfree-release-tainted &>/dev/null; then
    rpm-ostree uninstall rpmfusion-free-release-tainted rpmfusion-nonfree-release-tainted
  elif rpm -q rpmfusion-free-release-tainted &>/dev/null; then
    rpm-ostree uninstall rpmfusion-free-release-tainted
  elif rpm -q rpmfusion-nonfree-release-tainted &>/dev/null; then
    rpm-ostree uninstall rpmfusion-nonfree-release-tainted
  fi
else
  echo "All RPMFusion repos are already uninstalled"
fi 

NEGATIVO_REPO_FILE="$(awk -F'=' '$1 == "name" && $2 == "negativo17 - Multimedia" {print FILENAME}' /etc/yum.repos.d/*)"

# check if negativo17 repo is installed
if [[ -n "${NEGATIVO_REPO_FILE}" ]]; then
  echo "Negativo17 repo is already installed"
  echo "Making sure that Negativo17 repo is enabled"
  # Set all Negativo repo sources to disabled
  sed -i 's@enabled=.*@enabled=0@g' "${NEGATIVO_REPO_FILE}"
  # Enable only the 1st repo source (Multimedia repo)
  sed -i '0,/enabled=/s/enabled=[^ ]*/enabled=1/' "${NEGATIVO_REPO_FILE}"
  # Wipe all existing source priorities
  sed -i '/priority=/d' "${NEGATIVO_REPO_FILE}"
  # Set priority to 90 for 1st repo source (Multimedia repo)
  sed -i '0,/enabled=1/{s/enabled=1/enabled=1\npriority=90/}' "${NEGATIVO_REPO_FILE}"
else
  echo "Installing Negativo17 repo..."
  curl -Lo /etc/yum.repos.d/negativo17-fedora-multimedia.repo https://negativo17.org/repos/fedora-multimedia.repo
  echo "Setting Negativo17 repo priority to 90..."
  sed -i '0,/enabled=1/{s/enabled=1/enabled=1\npriority=90/}' /etc/yum.repos.d/negativo17-fedora-multimedia.repo
fi
