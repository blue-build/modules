#!/usr/bin/env bash

set -euo pipefail

# Debugging
DEBUG=${DEBUG:-false}
if [[ $DEBUG == true ]]; then
    set -x
fi

# Module-specific directories and paths
MODULE_DIRECTORY="${MODULE_DIRECTORY:-"/tmp/modules"}"

# Check if the packages element exists and is not null or empty
PACKAGE_LIST=$(echo "$1" | yq -I=0 ".packages | select(. != null) | select(length > 0) | .[]")

# Configuration values
UPDATE_INTERVAL=$(echo "$1" | yq -I=0 ".update_interval")
if [[ -z $UPDATE_INTERVAL || $UPDATE_INTERVAL == "null" ]]; then
    UPDATE_INTERVAL="6h"
fi

UPGRADE_INTERVAL=$(echo "$1" | yq -I=0 ".upgrade_interval")
if [[ -z $UPGRADE_INTERVAL || $UPGRADE_INTERVAL == "null" ]]; then
    UPGRADE_INTERVAL="8h"
fi

WAIT_AFTER_BOOT_UPDATE=$(echo "$1" | yq -I=0 ".wait_after_boot_update")
if [[ -z $WAIT_AFTER_BOOT_UPDATE || $WAIT_AFTER_BOOT_UPDATE == "null" ]]; then
    WAIT_AFTER_BOOT_UPDATE="10min"
fi

WAIT_AFTER_BOOT_UPGRADE=$(echo "$1" | yq -I=0 ".wait_after_boot_upgrade")
if [[ -z $WAIT_AFTER_BOOT_UPGRADE || $WAIT_AFTER_BOOT_UPGRADE == "null" ]]; then
    WAIT_AFTER_BOOT_UPGRADE="30min"
fi

AUTO_UPDATE=$(echo "$1" | yq -I=0 ".auto_update")
if [[ -z $AUTO_UPDATE || $AUTO_UPDATE == "null" ]]; then
    AUTO_UPDATE=true
fi

AUTO_UPGRADE=$(echo "$1" | yq -I=0 ".auto_upgrade")
if [[ -z $AUTO_UPGRADE || $AUTO_UPGRADE == "null" ]]; then
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

# Copy systemd service and timer files
cp -r "$MODULE_DIRECTORY"/brew/brew-setup.service /usr/lib/systemd/system/brew-setup.service
cp -r "$MODULE_DIRECTORY"/brew/brew-update.service /usr/lib/systemd/system/brew-update.service
cp -r "$MODULE_DIRECTORY"/brew/brew-upgrade.service /usr/lib/systemd/system/brew-upgrade.service
cp -r "$MODULE_DIRECTORY"/brew/brew-update.timer /usr/lib/systemd/system/brew-update.timer
cp -r "$MODULE_DIRECTORY"/brew/brew-upgrade.timer /usr/lib/systemd/system/brew-upgrade.timer

# Copy shell configuration files
cp -r "$MODULE_DIRECTORY"/brew/brew-fish-completions.fish /usr/share/fish/vendor_conf.d/brew-fish-completions.fish
cp -r "$MODULE_DIRECTORY"/brew/brew-bash-completion.sh /etc/profile.d/brew-bash-completion.sh

# Copy tmpfiles.d configuration file
cp -r "$MODULE_DIRECTORY"/brew/homebrew.conf /usr/lib/tmpfiles.d/homebrew.conf

# Enable the setup service
systemctl enable brew-setup.service

# Conditionally enable or disable update service based on configuration
if [[ $AUTO_UPDATE == true ]]; then
    systemctl enable brew-update.timer
else
    systemctl disable brew-update.timer
fi

# Conditionally enable or disable upgrade service based on configuration
if [[ $AUTO_UPGRADE == true ]]; then
    systemctl enable brew-upgrade.timer
else
    systemctl disable brew-upgrade.timer
fi

# Install specified Brew packages if any
if [[ -n $PACKAGE_LIST ]]; then
    echo "Installing specified Brew packages..."
    su -c "/home/linuxbrew/.linuxbrew/bin/brew install $PACKAGE_LIST" -s /bin/bash linuxbrew
else
    echo "No Brew packages specified for installation."
fi

