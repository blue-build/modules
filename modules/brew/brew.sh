#!/usr/bin/env bash

set -euo pipefail

# Convince the installer that we are in CI
touch /.dockerenv

# Debugging
DEBUG="${DEBUG:-false}"
if [[ "${DEBUG}" == true ]]; then
    set -x
fi

# Check if gcc is installed
if ! command -v gcc &> /dev/null
then
    echo "ERROR: \"gcc\" package could not be found."
    echo "       Brew depends on \"gcc\" in order to function"
    echo "       Please include \"gcc\" in the list of packages to install with the system package manager"
    exit 1
fi

# Module-specific directories and paths
MODULE_DIRECTORY="${MODULE_DIRECTORY:-/tmp/modules}"

# Configuration values
UPDATE_INTERVAL=$(echo "${1}" | yq -I=0 ".update-interval")
if [[ -z "${UPDATE_INTERVAL}" || "${UPDATE_INTERVAL}" == "null" ]]; then
    UPDATE_INTERVAL="6h"
fi

UPGRADE_INTERVAL=$(echo "$1" | yq -I=0 ".upgrade-interval")
if [[ -z "${UPGRADE_INTERVAL}" || "${UPGRADE_INTERVAL}" == "null" ]]; then
    UPGRADE_INTERVAL="8h"
fi

WAIT_AFTER_BOOT_UPDATE=$(echo "${1}" | yq -I=0 ".wait-after-boot-update")
if [[ -z "${WAIT_AFTER_BOOT_UPDATE}" || "${WAIT_AFTER_BOOT_UPDATE}" == "null" ]]; then
    WAIT_AFTER_BOOT_UPDATE="10min"
fi

WAIT_AFTER_BOOT_UPGRADE=$(echo "${1}" | yq -I=0 ".wait-after-boot-upgrade")
if [[ -z "${WAIT_AFTER_BOOT_UPGRADE}" || "${WAIT_AFTER_BOOT_UPGRADE}" == "null" ]]; then
    WAIT_AFTER_BOOT_UPGRADE="30min"
fi

AUTO_UPDATE=$(echo "${1}" | yq -I=0 ".auto-update")
if [[ -z "${AUTO_UPDATE}" || "${AUTO_UPDATE}" == "null" ]]; then
    AUTO_UPDATE=true
fi

AUTO_UPGRADE=$(echo "${1}" | yq -I=0 ".auto-upgrade")
if [[ -z "${AUTO_UPGRADE}" || "${AUTO_UPGRADE}" == "null" ]]; then
    AUTO_UPGRADE=true
fi

NOFILE_LIMITS=$(echo "${1}" | yq -I=0 ".nofile-limits")
if [[ -z "${NOFILE_LIMITS}" || "${NOFILE_LIMITS}" == "null" ]]; then
    NOFILE_LIMITS=false
fi

BREW_ANALYTICS=$(echo "${1}" | yq -I=0 ".brew-analytics")
if [[ -z "${BREW_ANALYTICS}" || "${BREW_ANALYTICS}" == "null" ]]; then
    BREW_ANALYTICS=true
fi

# Create necessary directories
mkdir -p /var/home
mkdir -p /var/roothome

# Always install Brew
echo "Downloading and installing Brew..."
curl -Lo /tmp/brew-install https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh
chmod +x /tmp/brew-install
/tmp/brew-install

# Move Brew installation and set ownership to default user (UID 1000)
tar --zstd -cvf /usr/share/homebrew.tar.zst /home/linuxbrew/.linuxbrew
cp -R /home/linuxbrew /usr/share/homebrew
chown -R 1000:1000 /usr/share/homebrew

# Write systemd service files dynamically
echo "Writing brew-setup service"
cat >/usr/lib/systemd/system/brew-setup.service <<EOF
[Unit]
Description=Setup Brew
Wants=network-online.target
After=network-online.target
ConditionPathExists=!/etc/.linuxbrew
ConditionPathExists=!/var/home/linuxbrew/.linuxbrew

[Service]
Type=oneshot
ExecStart=/usr/bin/mkdir -p /tmp/homebrew
ExecStart=/usr/bin/tar --zstd -xvf /usr/share/homebrew.tar.zst -C /tmp/homebrew
ExecStart=/usr/bin/cp -R -n /tmp/homebrew/home/linuxbrew/.linuxbrew /var/home/linuxbrew
ExecStart=/usr/bin/chown -R 1000:1000 /var/home/linuxbrew
ExecStart=/usr/bin/rm -rf /tmp/homebrew
ExecStart=/usr/bin/touch /etc/.linuxbrew

[Install]
WantedBy=default.target multi-user.target
EOF

echo "Writing brew-update service"
cat >/usr/lib/systemd/system/brew-update.service <<EOF
[Unit]
Description=Auto update brew for mutable brew installs
After=local-fs.target
After=network-online.target
ConditionPathIsSymbolicLink=/home/linuxbrew/.linuxbrew/bin/brew

[Service]
User=1000
Type=oneshot
Environment=HOMEBREW_CELLAR=/home/linuxbrew/.linuxbrew/Cellar
Environment=HOMEBREW_PREFIX=/home/linuxbrew/.linuxbrew
Environment=HOMEBREW_REPOSITORY=/home/linuxbrew/.linuxbrew/Homebrew
ExecStart=/usr/bin/bash -c "/home/linuxbrew/.linuxbrew/bin/brew update"
EOF

echo "Writing brew-upgrade service"
cat >/usr/lib/systemd/system/brew-upgrade.service <<EOF
[Unit]
Description=Upgrade Brew packages
After=local-fs.target
After=network-online.target
ConditionPathIsSymbolicLink=/home/linuxbrew/.linuxbrew/bin/brew

[Service]
User=1000
Type=oneshot
Environment=HOMEBREW_CELLAR=/home/linuxbrew/.linuxbrew/Cellar
Environment=HOMEBREW_PREFIX=/home/linuxbrew/.linuxbrew
Environment=HOMEBREW_REPOSITORY=/home/linuxbrew/.linuxbrew/Homebrew
ExecStart=/usr/bin/bash -c "/home/linuxbrew/.linuxbrew/bin/brew upgrade"
EOF

# Write systemd timer files dynamically
echo "Writing brew-update timer"
if [[ -n "${WAIT_AFTER_BOOT_UPDATE}" ]] && [[ "${WAIT_AFTER_BOOT_UPDATE}" != "10min" ]]; then
  echo "Applying custom 'wait-after-boot' value in '${WAIT_AFTER_BOOT_UPDATE}' time interval for brew update timer"
fi
if [[ -n "${UPDATE_INTERVAL}" ]] && [[ "${UPDATE_INTERVAL}" != "6h" ]]; then
  echo "Applying custom 'update-interval' value in '${UPDATE_INTERVAL}' time interval for brew update timer"
fi
cat >/usr/lib/systemd/system/brew-update.timer <<EOF
[Unit]
Description=Timer for brew update for mutable brew
Wants=network-online.target

[Timer]
OnBootSec=${WAIT_AFTER_BOOT_UPDATE}
OnUnitInactiveSec=${UPDATE_INTERVAL}
Persistent=true

[Install]
WantedBy=timers.target
EOF

echo "Writing brew-upgrade timer"
if [[ -n "${WAIT_AFTER_BOOT_UPGRADE}" ]] && [[ "${WAIT_AFTER_BOOT_UPGRADE}" != "30min" ]]; then
  echo "Applying custom 'wait-after-boot' value in '${WAIT_AFTER_BOOT_UPGRADE}' time interval for brew upgrade timer"
fi
if [[ -n "${UPGRADE_INTERVAL}" ]] && [[ "${UPGRADE_INTERVAL}" != "8h" ]]; then
  echo "Applying custom 'upgrade-interval' value in '${UPGRADE_INTERVAL}' time interval for brew upgrade timer"
fi
cat >/usr/lib/systemd/system/brew-upgrade.timer <<EOF
[Unit]
Description=Timer for brew upgrade for on image brew
Wants=network-online.target

[Timer]
OnBootSec=${WAIT_AFTER_BOOT_UPGRADE}
OnUnitInactiveSec=${UPGRADE_INTERVAL}
Persistent=true

[Install]
WantedBy=timers.target
EOF

# Copy shell configuration files
echo "Copying brew bash & fish shell completions"
cp -r "${MODULE_DIRECTORY}"/brew/brew-fish-completions.fish /usr/share/fish/vendor_conf.d/brew-fish-completions.fish
cp -r "${MODULE_DIRECTORY}"/brew/brew-bash-completions.sh /etc/profile.d/brew-bash-completions.sh

# Register path symlink
# We do this via tmpfiles.d so that it is created by the live system.
echo "Writing brew tmpfiles.d configuration"
cat >/usr/lib/tmpfiles.d/homebrew.conf <<EOF
d /var/lib/homebrew 0755 1000 1000 - -
d /var/cache/homebrew 0755 1000 1000 - -
d /var/home/linuxbrew 0755 1000 1000 - -
EOF

# Enable the setup service
echo "Enabling brew-setup service"
systemctl enable brew-setup.service

# Always enable or disable update and upgrade services for consistency
if [[ "${AUTO_UPDATE}" == true ]]; then
    echo "Enabling auto-updates for brew packages"
    systemctl enable brew-update.timer
else
    echo "Disabling auto-updates for brew packages"
    systemctl disable brew-update.timer
fi

if [[ "${AUTO_UPGRADE}" == true ]]; then
    echo "Enabling auto-upgrades for brew binary"
    systemctl enable brew-upgrade.timer
else
    echo "Disabling auto-upgrades for brew binary"
    systemctl disable brew-upgrade.timer
fi

# Apply nofile limits if enabled
if [[ "${NOFILE_LIMITS}" == true ]]; then
  source "${MODULE_DIRECTORY}"/brew/brew-nofile-limits-logic.sh
fi

# Disable homebrew analytics if the flag is set to false
# like secureblue: https://github.com/secureblue/secureblue/blob/live/config/scripts/homebrewanalyticsoptout.sh
if [[ "${BREW_ANALYTICS}" == false ]]; then
  if [[ ! -f "/usr/etc/environment" ]]; then
    echo "" > "/usr/etc/environment" # touch fails for some reason, probably a bug with it
  fi  
  CURRENT_HOMEBREW_CONFIG=$(cat "/usr/etc/environment" | grep -o "HOMEBREW_NO_ANALYTICS=0")
  if [[ "${CURRENT_HOMEBREW_CONFIG}" == "HOMEBREW_NO_ANALYTICS=0" ]]; then
    echo "Disabling Brew analytics"  
    sed -i 's/HOMEBREW_NO_ANALYTICS=0/HOMEBREW_NO_ANALYTICS=1/' "/usr/etc/environment"
  elif [[ -z "${CURRENT_HOMEBREW_CONFIG}" ]]; then
    echo "Disabling Brew analytics"
    echo "HOMEBREW_NO_ANALYTICS=1" >> "/usr/etc/environment"
  elif [[ "${CURRENT_HOMEBREW_CONFIG}" == "HOMEBREW_NO_ANALYTICS=1" ]]; then
    echo "Brew analytics are already disabled!"
  fi
fi

echo "Brew setup completed."
