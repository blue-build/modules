#!/usr/bin/env bash



set -euo pipefail



# Debugging

DEBUG=${DEBUG:-false}

if [[ $DEBUG == true ]]; then

    set -x

fi



# Module-specific directories and paths

MODULE_DIRECTORY="${MODULE_DIRECTORY:-"/tmp/modules"}"

PACKAGE_LIST=$(echo "$1" | yq -I=0 ".packages[]") # Packages from config



# Configuration values

INSTALL_BREW=$(echo "$1" | yq -I=0 ".install_brew")

if [[ -z $INSTALL_BREW || $INSTALL_BREW == "null" ]]; then

    INSTALL_BREW=true

fi



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



DISABLE_UPDATE=$(echo "$1" | yq -I=0 ".disable_update")

if [[ -z $DISABLE_UPDATE || $DISABLE_UPDATE == "null" ]]; then

    DISABLE_UPDATE=false

fi



DISABLE_UPGRADE=$(echo "$1" | yq -I=0 ".disable_upgrade")

if [[ -z $DISABLE_UPGRADE || $DISABLE_UPGRADE == "null" ]]; then

    DISABLE_UPGRADE=false

fi



# Create necessary directories

mkdir -p /var/home

mkdir -p /var/roothome



# Install Brew

if [[ $INSTALL_BREW == true ]]; then

    echo "Downloading and installing Brew..."

    curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh > /tmp/brew.sh

    chmod +x /tmp/brew.sh

    /tmp/brew.sh



    # Move Brew installation and set ownership to default user (UID 1000)

    tar --zstd -cvf /usr/share/homebrew.tar.zst /home/linuxbrew/.linuxbrew

    cp -R /home/linuxbrew /usr/share/homebrew

    chown -R 1000:1000 /usr/share/homebrew

else

    echo "Skipping Brew installation."

fi



# Copy systemd service and timer files

cp -r "$MODULE_DIRECTORY"/brew/brew-setup.service /usr/lib/systemd/system/brew-setup.service

cp -r "$MODULE_DIRECTORY"/brew/brew-update.service /usr/lib/systemd/system/brew-update.service

cp -r "$MODULE_DIRECTORY"/brew/brew-upgrade.service /usr/lib/systemd/system/brew-upgrade.service

cp -r "$MODULE_DIRECTORY"/brew/brew-update.timer /usr/lib/systemd/system/brew-update.timer

cp -r "$MODULE_DIRECTORY"/brew/brew-upgrade.timer /usr/lib/systemd/system/brew-upgrade.timer



# Copy shell configuration files

cp -r "$MODULE_DIRECTORY"/brew/brew.fish /usr/share/fish/vendor_conf.d/brew.fish

cp -r "$MODULE_DIRECTORY"/brew/brew-bash-completion.sh /etc/profile.d/brew-bash-completion.sh



# Copy tmpfiles.d configuration file

cp -r "$MODULE_DIRECTORY"/brew/homebrew.conf /usr/lib/tmpfiles.d/homebrew.conf



# Copy mounts configuration file

cp -r "$MODULE_DIRECTORY"/brew/var-home-linuxbrew.mount /usr/lib/systemd/system/var-home-linuxbrew.mount



# Enable the setup service

systemctl enable brew-setup.service



# Conditionally enable or disable update service based on configuration

if [[ $DISABLE_UPDATE == false ]]; then

    systemctl enable brew-update.timer

else

    systemctl disable brew-update.timer

fi



# Conditionally enable or disable upgrade service based on configuration

if [[ $DISABLE_UPGRADE == false ]]; then

    systemctl enable brew-upgrade.timer

else

    systemctl disable brew-upgrade.timer

fi



# Install specified Brew packages

if [[ -n $PACKAGE_LIST && $PACKAGE_LIST != "null" ]]; then

    echo "Installing specified Brew packages..."

    su -c "/home/linuxbrew/.linuxbrew/bin/brew install $PACKAGE_LIST" -s /bin/bash linuxbrew

else

    echo "No Brew packages specified for installation."

fi
