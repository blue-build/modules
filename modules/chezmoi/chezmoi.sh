#!/usr/bin/env bash

# Tell build process to exit if there are any errors.
set -euo pipefail

# `-I=0` makes sure the output isn't indented

# If true, downloads the chezmoi binary from the latest Github release and moves it to /usr/bin/. (default: true)
INSTALL_CHEZMOI==$(echo "$1" | yq -I=0 ".install") # (boolean)
INSTALL_CHEZMOI=${INSTALL_CHEZMOI:-true}

# The repository with your chezmoi dotfiles. (default: null)
DOTFILE_REPOSITORY=$(echo "$1" | yq -I=0 ".repository") # (string)

# If true, chezmoi services will be enabled for all logged in users, and users with lingering enabled. (default: true)
# If false, chezmoi services will not be enabled for any users, but can be enabled manually, after installation.
#
# To enable the services for a single user, run the following command as that user:
# `systemctl enable --user chezmoi-init.service chezmoi-update.timer`
#
# To manually enable the services for all users, run the following command with sudo:
# `sudo systemctl enable --user chesmoi-init.service chezmoi-update.timer`
#
# To turn on lingering for a given user, run the following commmand with sudo:
# `sudo loginctl enable-linger <username>`
ENABLE_ALL_USERS=$(echo "$1" | yq -I=0 ".enable_all_users") # (boolean)
ENABLE_ALL_USERS=${ENABLE_ALL_USERS:-true}

# chezmoi-update.service will run with this interval
# This string is passed on directly to systemd's OnUnitInactiveSec. Complete syntax is described here:
# https://www.freedesktop.org/software/systemd/man/latest/systemd.time.html#
# Examples: '1d' (1 day - default), '6h' (6 hours), '10m' (10 minutes)
RUN_EVERY=$(echo "$1" | yq -I=0 ".run_every") # (string)
RUN_EVERY=${RUN_EVERY:-'1d'}
# chezmoi-update.service will also run this much time after the system has booted.
# Same syntax as RUN_EVERY (default: '5m')
WAIT_AFTER_BOOT=$(echo "$1" | yq -I=0 ".wait_after_boot") # (string)
WAIT_AFTER_BOOT=${WAIT_AFTER_BOOT:-'5m'}

# If true, disables automatic initialization of chezmoi if no dotfile directory is found. (default: false)
DISABLE_INIT=$(echo "$1" | yq -I=0 ".disable_init") # (boolean)
DISABLE_INIT=${DISABLE_INIT:-false}
# If true, disables automatic activation of `chezmoi-update.timer`. (default: false)
DISABLE_UPDATE=$(echo "$1" | yq -I=0 ".disable_update") # (boolean)
DISABLE_UPDATE=${DISABLE_UPDATE:-false}

echo "Checking if \`repository\` is not set and \`disable_init\` is not true."
if [ ! -v DOTFILE_REPOSITORY && ! DISABLE_INIT ]; then
  echo "ERROR: `repository` is not set, but initialization is not disabled."
  echo "Set a value for `repository` or set `disable_update` to true, if you do not wish to initialize a chezmoi directory using this module"
  exit 1
fi

if [ INSTALL_CHEZMOI ]; then
  echo "Checking if curl is installed and executable at /usr/bin/curl"
  if [ -x /usr/bin/curl]; then
    echo "Downloading chezmoi binary from the latest Github release"
    /usr/bin/curl -Ls https://github.com/twpayne/chezmoi/releases/latest/download/chezmoi-linux-amd64 -o /usr/bin/chezmoi
    echo "Ensuring chezmoi is executable"
    /usr/bin/chmod 755 /usr/bin/chezmoi
  else
    echo "ERROR: curl could not be found in /usr/bin/."
    echo "Please make sure curl is installed on the system you are building your image."
    exit 1
  fi
fi

if [ ! DISABLE_INIT ]; then
  # Write the service to initialize Chezmoi, and insert the repo url in the file
  echo "Writing init service to user unit directory"
  cat >> /usr/lib/systemd/user/chezmoi-init.service << EOF
  [Unit]
  Description=Initializes Chezmoi if directory is missing
  # This service will not execute for a user with an existing chezmoi directory
  ConditionPathExists=!%h/.local/share/chezmoi
  [Service]
  ExecStart=/usr/bin/chezmoi init --apply ${DOTFILE_REPOSITORY}
  Type=oneshot

  [Install]
  WantedBy=multi-user.target
  Requires=network-online.target
  After=network-online.target
EOF
fi

if [ ! DISABLE_UPDATE ]; then
  # Write the service and timer to update chezmoi for all logged in users and users with lingering enabled
  echo "Writing update service to user unit directory"
  cat >> /usr/lib/systemd/user/chezmoi-update.service << EOF
  [Unit]
  Description=Chezmoi Update

  [Service]
  ExecStart=/usr/bin/chezmoi update
  Type=oneshot
EOF

  echo "Writing update timer to user unit directory"
  cat >> /usr/lib/systemd/user/chezmoi-update.timer << EOF
  [Unit]
  Description=Timer for Chezmoi Update
  # This service will only execute for a user with an existing chezmoi directory
  ConditionPathExists=%h/.local/share/chezmoi

  [Timer]
  OnBootSec=${WAIT_AFTER_BOOT}
  OnUnitInactiveSec=${RUN_EVERY}

  [Install]
  WantedBy=timers.target
EOF
fi

# Enable services
if [ ENABLE_ALL_USERS && ! DISABLE_INIT && ! DISABLE_UPDATE]; then
  echo "Enabling init timer and update service"
  systemctl --user enable --now chezmoi-init.service chezmoi-update.timer
elif [ ENABLE_ALL_USERS && DISABLE_INIT && ! DISABLE_UPDATE]; then
  echo "Enabling update timer and disabling init service"
  systemctl --user enable --now chezmoi-update.timer
  systemctl --user disable --now chesmoi-init.service
elif [ ENABLE_ALL_USERS && ! DISABLE_INIT && DISABLE_UPDATE]; then
  echo "Enabling init service and disabling update service"
  systemctl --user enable --now chezmoi-init.service
  systemctl --user disable --now chezmoi-update.service
fi
