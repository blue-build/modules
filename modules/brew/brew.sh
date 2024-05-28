#!/usr/bin/env bash

set -euo pipefail

# Debugging
DEBUG="${DEBUG:-false}"
if [[ "${DEBUG}" == true ]]; then
    set -x
fi

# Module-specific directories and paths
MODULE_DIRECTORY="${MODULE_DIRECTORY:-/tmp/modules}"

# Get list of brew packages to install
get_yaml_array PACKAGE_LIST '.packages[]' "${1}"

# Configuration values
UPDATE_INTERVAL=$(echo "${1}" | yq -I=0 ".update_interval")
if [[ -z "${UPDATE_INTERVAL}" || "${UPDATE_INTERVAL}" == "null" ]]; then
    UPDATE_INTERVAL="6h"
fi

UPGRADE_INTERVAL=$(echo "$1" | yq -I=0 ".upgrade_interval")
if [[ -z "${UPGRADE_INTERVAL}" || "${UPGRADE_INTERVAL}" == "null" ]]; then
    UPGRADE_INTERVAL="8h"
fi

WAIT_AFTER_BOOT_UPDATE=$(echo "${1}" | yq -I=0 ".wait_after_boot_update")
if [[ -z "${WAIT_AFTER_BOOT_UPDATE}" || "${WAIT_AFTER_BOOT_UPDATE}" == "null" ]]; then
    WAIT_AFTER_BOOT_UPDATE="10min"
fi

WAIT_AFTER_BOOT_UPGRADE=$(echo "${1}" | yq -I=0 ".wait_after_boot_upgrade")
if [[ -z "${WAIT_AFTER_BOOT_UPGRADE}" || "${WAIT_AFTER_BOOT_UPGRADE}" == "null" ]]; then
    WAIT_AFTER_BOOT_UPGRADE="30min"
fi

AUTO_UPDATE=$(echo "${1}" | yq -I=0 ".auto_update")
if [[ -z "${AUTO_UPDATE}" || "${AUTO_UPDATE}" == "null" ]]; then
    AUTO_UPDATE=true
fi

AUTO_UPGRADE=$(echo "${1}" | yq -I=0 ".auto_upgrade")
if [[ -z "${AUTO_UPGRADE}" || "${AUTO_UPGRADE}" == "null" ]]; then
    AUTO_UPGRADE=true
fi

# Create necessary directories
mkdir -p /var/home
mkdir -p /var/roothome

# Always install Brew
echo "Downloading and installing Brew..."
curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh > /tmp/brew.sh
chmod +x /tmp/brew.sh
/tmp/brew.sh

# Move Brew installation and set ownership to default user (UID 1000)
tar --zstd -cvf /usr/share/homebrew.tar.zst /home/linuxbrew/.linuxbrew
cp -R /home/linuxbrew /usr/share/homebrew
chown -R 1000:1000 /usr/share/homebrew

# Write systemd service files dynamically
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
cp -r "${MODULE_DIRECTORY}"/brew/brew-fish-completions.fish /usr/share/fish/vendor_conf.d/brew-fish-completions.fish
cp -r "${MODULE_DIRECTORY}"/brew/brew-bash-completion.sh /etc/profile.d/brew-bash-completion.sh

# Copy tmpfiles.d configuration file
cp -r "${MODULE_DIRECTORY}"/brew/homebrew.conf /usr/lib/tmpfiles.d/homebrew.conf

# Enable the setup service
systemctl enable brew-setup.service

# Always enable or disable update and upgrade services for consistency
if [[ "${AUTO_UPDATE}" == true ]]; then
    systemctl enable brew-update.timer
else
    systemctl disable brew-update.timer
fi

if [[ "${AUTO_UPGRADE}" == true ]]; then
    systemctl enable brew-upgrade.timer
else
    systemctl disable brew-upgrade.timer
fi

# Install specified Brew packages if any
if [[ "${#PACKAGE_LIST[@]}" -gt 0 ]]; then
    echo "Installing specified Brew packages..."
    su -c "/home/linuxbrew/.linuxbrew/bin/brew install ${PACKAGE_LIST[*]}" -s /bin/bash linuxbrew
else
    echo "No Brew packages specified for installation."
fi

echo "Brew setup completed."
