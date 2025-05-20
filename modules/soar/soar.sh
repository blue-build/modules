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

# Configuration for unlocking all default & external repos (outside of 'bincache')
UNLOCK_REPOS=$(echo "${1}" | jq -r 'try .["unlock-repos"]')
if [[ "${UNLOCK_REPOS}" == "true" ]]; then
  echo "Unlocking all available 'soar' repos in config"
  mkdir -p "/usr/share/bluebuild/soar"
  soar defconfig --external -c "/usr/share/bluebuild/soar/config.toml"
  # Fix /root being ${HOME}
  sed -i 's|/root|~|g' "/usr/share/bluebuild/soar/config.toml"
else
  echo "Using the default 'bincache' repository in config"
  mkdir -p "/usr/share/bluebuild/soar"
  soar defconfig -c "/usr/share/bluebuild/soar/config.toml"
  # Remove all other repositories except bincache
  sed -i '/^\[\[repositories\]\]/{:a;N;/name = "bincache"/!{/\n[[:space:]]*$/!ba;d}}' "/usr/share/bluebuild/soar/config.toml"
  # Fix /root being ${HOME}
  sed -i 's|/root|~|g' "/usr/share/bluebuild/soar/config.toml"
fi

# Configuration for always exporting the PATH (useful if you want scripts to use 'soar' packages & don't mind about the potential package conflicts)
UNLOCK_PATH=$(echo "${1}" | jq -r 'try .["unlock-path"]')

# Adding 'soar' systemd service for auto-upgrading packages
echo "Configuring auto-upgrades of 'soar' packages"
echo "Copying soar-upgrade-packages service"
cp "${MODULE_DIRECTORY}/soar/soar-upgrade-packages.service" "/usr/lib/systemd/user/soar-upgrade-packages.service"

echo "Copying soar-upgrade-packages timer"
if [[ -n "${UPGRADE_INTERVAL}" ]] && [[ "${UPGRADE_INTERVAL}" != "8h" ]]; then
  echo "Applying custom 'upgrade-interval' value in '${UPGRADE_INTERVAL}' time interval for soar-upgrade-packages timer"
  sed -i "s/^OnUnitInactiveSec=.*/OnUnitInactiveSec=${UPGRADE_INTERVAL}/" "${MODULE_DIRECTORY}/soar/soar-upgrade-packages.timer"
fi
cp "${MODULE_DIRECTORY}/soar/soar-upgrade-packages.timer" "/usr/lib/systemd/user/soar-upgrade-packages.timer"

# Enable 'soar' auto-upgrade of packages timer
if [[ "${AUTO_UPGRADE}" == true ]]; then
    echo "Enabling auto-upgrades for 'soar' packages"
    systemctl --global enable soar-upgrade-packages.timer
else
    echo "Auto-upgrades for 'soar' packages are disabled"
fi

# Add 'soar' packages to path only when it's interactive terminal session & non-root user, similar to brew
if [[ ! -d "/etc/profile.d/" ]]; then
  mkdir -p "/etc/profile.d/"
fi
if [[ ! -f "/etc/profile.d/soar.sh" ]]; then
  echo "Applying shell profile for exporting 'soar' packages directory to PATH"
  cp "${MODULE_DIRECTORY}/soar/soar-profile.sh" "/etc/profile.d/soar.sh"
fi

if [[ "${UNLOCK_PATH}" == "true" ]]; then
  echo "Unlocking the PATH to be set in all conditions for 'soar' packages"
  cat > "/etc/profile.d/soar.sh" << 'EOF'
#!/usr/bin/env bash
# Alias 'soar', so it uses BlueBuild's config
# Using function, because I see mixed results on alias overriding an alias in case of local-user config
soar() {
  /usr/bin/soar -c "/usr/share/bluebuild/soar/config.toml" "${@}"
}
export -f soar
# Check if custom packages directory is specified for soar in config to source PATH from
# If it is, export the PATH from that custom directory
finished=false
config_dir="${XDG_CONFIG_HOME:-$HOME/.config}" 
if [[ -f "${config_dir}/soar/config.toml" ]]; then
  binpath="$(grep 'bin_path' "${config_dir}/soar/config.toml" | sed 's/.*=//; s/"//g; s/^[ \t]*//; s/[ \t]*$//')"
  if [[ -n "${binpath}" ]]; then
    export PATH="${binpath/#\~/$HOME}:${PATH}"
    finished=true
  fi
fi  
# If there's no config, export regular 'soar' packages directory to PATH
if ! ${finished}; then
  share_dir="${XDG_DATA_HOME:-$HOME/.local/share}"    
  export PATH="${share_dir}/soar/bin:${PATH}"
fi
EOF
fi