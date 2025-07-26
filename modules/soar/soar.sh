#!/usr/bin/env bash

set -euo pipefail

# Install 'soar'
echo "Downloading & installing 'soar' package manager"
REPO="pkgforge/soar"
LATEST_VER="$(basename $(curl -Ls -o /dev/null -w %{url_effective} https://github.com/${REPO}/releases/latest))"
# Assuming that ARM64 custom images will be built from ARM64 runners for this working detection
ARCH="$(uname -m)"
curl -fLs --create-dirs "https://github.com/${REPO}/releases/download/${LATEST_VER}/soar-${ARCH}-linux" -o "/usr/bin/soar"
chmod +x "/usr/bin/soar"

# Configuration values for package auto-upgrades (using upgrade term here from brew)
AUTO_UPGRADE=$(echo "${1}" | jq -r 'try .["auto-upgrade"]')
if [[ -z "${AUTO_UPGRADE}" || "${AUTO_UPGRADE}" == "null" ]]; then
    AUTO_UPGRADE=true
fi

UPGRADE_INTERVAL=$(echo "${1}" | jq -r 'try .["upgrade-interval"]')
if [[ -z "${UPGRADE_INTERVAL}" || "${UPGRADE_INTERVAL}" == "null" ]]; then
    UPGRADE_INTERVAL="8h"
fi

# Configuration for enabling additional repos (outside of 'bincache')
ADDITIONAL_REPOS=$(echo "${1}" | jq -r 'try .["additional-repos"]')
mkdir -p "/usr/share/bluebuild/soar"
if [[ "${ADDITIONAL_REPOS}" == "true" ]]; then
  echo "Enabling all additional 'soar' repos in config, including external ones"
  soar defconfig --external -c "/usr/share/bluebuild/soar/config.toml"
else
  echo "Using the default 'bincache', 'pkgforge-cargo' & 'pkgforge-go' repositories in config"
  soar -c /usr/share/bluebuild/soar/config.toml defconfig -r bincache -r pkgforge-cargo -r pkgforge-go
fi
# Fix /root being ${HOME}
sed -i 's|/root|~|g' "/usr/share/bluebuild/soar/config.toml"
# Add soar config to environment
echo "SOAR_CONFIG=/usr/share/bluebuild/soar/config.toml" >> /etc/environment

if [[ "${AUTO_UPGRADE}" == true ]]; then
  echo "Configuring auto-upgrades of 'soar' packages"
  echo "Copying soar-upgrade-packages service"
  cp "${MODULE_DIRECTORY}/soar/soar-upgrade-packages.service" "/usr/lib/systemd/user/soar-upgrade-packages.service"
  if [[ -n "${UPGRADE_INTERVAL}" ]] && [[ "${UPGRADE_INTERVAL}" != "8h" ]]; then
    echo "Applying custom 'upgrade-interval' value in '${UPGRADE_INTERVAL}' time interval for soar-upgrade-packages timer"
    sed -i "s/^OnUnitInactiveSec=.*/OnUnitInactiveSec=${UPGRADE_INTERVAL}/" "${MODULE_DIRECTORY}/soar/soar-upgrade-packages.timer"
  fi
  echo "Copying soar-upgrade-packages timer"
  cp "${MODULE_DIRECTORY}/soar/soar-upgrade-packages.timer" "/usr/lib/systemd/user/soar-upgrade-packages.timer"
  echo "Enabling auto-upgrades for 'soar' packages"
  systemctl --global enable soar-upgrade-packages.timer
else
  echo "Auto-upgrades for 'soar' packages are disabled"
fi

# Add 'soar' packages to path only when it's interactive terminal session & non-root user, similar to brew
if [[ ! -d "/etc/profile.d/" ]]; then
  mkdir -p "/etc/profile.d/"
fi
echo "Applying shell profile for exporting 'soar' packages directory to PATH"
cp "${MODULE_DIRECTORY}/soar/soar-profile.sh" "/etc/profile.d/soar.sh"
