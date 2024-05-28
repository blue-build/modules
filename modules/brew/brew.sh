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
    echo "Error: gcc could not be found. Include \"gcc\" in the list of packages to install with rpm-ostree"
    exit 1
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

NOFILE_LIMITS=$(echo "${1}" | yq -I=0 ".nofile_limits")
if [[ -z "${NOFILE_LIMITS}" || "${NOFILE_LIMITS}" == "null" ]]; then
    NOFILE_LIMITS=false
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
cp -r "${MODULE_DIRECTORY}"/brew/brew-bash-completions.sh /etc/profile.d/brew-bash-completions.sh

# Register path symlink
# We do this via tmpfiles.d so that it is created by the live system.
cat >/usr/lib/tmpfiles.d/homebrew.conf <<EOF
d /var/lib/homebrew 0755 1000 1000 - -
d /var/cache/homebrew 0755 1000 1000 - -
d /var/home/linuxbrew 0755 1000 1000 - -
EOF

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

# Apply nofile limits if enabled
if [[ "${NOFILE_LIMITS}" == true ]]; then
    echo "Applying nofile limits..."
    cat >/usr/etc/security/limits.d/30-brew-limits.conf > /dev/null <<EOF
# This file sets the resource limits for users logged in via PAM,
# more specifically, users logged in via SSH or tty (console).
# Limits related to terminals in Wayland/Xorg sessions depend on a
# change to /etc/systemd/user.conf.
# This does not affect resource limits of the system services.
# This file overrides defaults set in /etc/security/limits.conf

* soft nofile 4096
* hard nofile 524288
EOF

    cat >/usr/lib/systemd/system/system.conf.d/30-brew-limits.conf > /dev/null <<EOF
[Manager]
DefaultLimitNOFILE=4096:524288
EOF

    cat >/usr/lib/systemd/user/user.conf.d/30-brew-limits.conf > /dev/null <<EOF
[Manager]
DefaultLimitNOFILE=4096:524288
EOF
fi

# Install specified Brew packages if any
if [[ "${#PACKAGE_LIST[@]}" -gt 0 ]]; then
    echo "Installing specified Brew packages..."
    su -c "/home/linuxbrew/.linuxbrew/bin/brew install ${PACKAGE_LIST[*]}" -s /bin/bash linuxbrew
else
    echo "No Brew packages specified for installation."
fi

echo "Brew setup completed."
