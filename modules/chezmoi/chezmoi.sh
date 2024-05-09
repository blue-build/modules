#!/usr/bin/env bash

# Tell build process to exit if there are any errors.
set -euo pipefail

# '-I=0' makes sure the output isn't indented

# Activates debugging output. This should only be true if you changed it yourself.
# -v = Verbose output. Outputs every line before executing.
# -u = Treat unset variables as errors. Useful for spotting typos.
# -x = Show expanded input for conditional statements.
DEBUG=false
if [[ $DEBUG == true ]]; then
	echo "Running in debug mode. If you didn't enable this yourself, this is a bug."
	set -vux
fi

# If true, downloads the chezmoi binary from the latest Github release and moves it to /usr/bin/. (default: true)
INSTALL_CHEZMOI=$(echo "$1" | yq -I=0 ".install-chezmoi") # (boolean)
if [[ -z $INSTALL_CHEZMOI || $INSTALL_CHEZMOI == "null" ]]; then
	INSTALL_CHEZMOI=true
fi

# The repository with your chezmoi dotfiles. (default: null)
DOTFILE_REPOSITORY=$(echo "$1" | yq -I=0 ".repository") # (string)

# If true, chezmoi services will be enabled for all logged in users, and users with lingering enabled. (default: true)
# If false, chezmoi services will not be enabled for any users, but can be enabled manually, after installation.
#
# To enable the services for a single user, run the following command as that user:
# 'systemctl enable --user chezmoi-init.service chezmoi-update.timer'
#
# To manually enable the services for all users, run the following command with sudo:
# 'sudo systemctl enable --user chesmoi-init.service chezmoi-update.timer'
#
# To turn on lingering for a given user, run the following commmand with sudo:
# 'sudo loginctl enable-linger <username>'
ENABLE_ALL_USERS=$(echo "$1" | yq -I=0 ".enable-all-users") # (boolean)
if [[ -z $ENABLE_ALL_USERS || $ENABLE_ALL_USERS == "null" ]]; then
	ENABLE_ALL_USERS=true
fi

# chezmoi-update.service will run with this interval
# This string is passed on directly to systemd's OnUnitInactiveSec. Complete syntax is described here:
# https://www.freedesktop.org/software/systemd/man/latest/systemd.time.html#
# Examples: '1d' (1 day - default), '6h' (6 hours), '10m' (10 minutes)
RUN_EVERY=$(echo "$1" | yq -I=0 ".run-every") # (string)
if [[ -z $RUN_EVERY || $RUN_EVERY == "null" ]]; then
	RUN_EVERY="1d"
fi
# chezmoi-update.service will also run this much time after the system has booted.
# Same syntax as RUN_EVERY (default: '5m')
WAIT_AFTER_BOOT=$(echo "$1" | yq -I=0 ".wait-after-boot") # (string)
if [[ -z $WAIT_AFTER_BOOT || $WAIT_AFTER_BOOT == "null" ]]; then
	WAIT_AFTER_BOOT="5m"
fi

# If true, disables automatic initialization of chezmoi if no dotfile directory is found. (default: false)
DISABLE_INIT=$(echo "$1" | yq -I=0 ".disable-init") # (boolean)
if [[ -z $DISABLE_INIT || $DISABLE_INIT == "null" ]]; then
	DISABLE_INIT=false
fi
# If true, disables automatic activation of 'chezmoi-update.timer'. (default: false)
DISABLE_UPDATE=$(echo "$1" | yq -I=0 ".disable-update") # (boolean)
if [[ -z $DISABLE_UPDATE || $DISABLE_UPDATE == "null" ]]; then
	DISABLE_UPDATE=false
fi

# Determines how chezmoi handles duplicate files. (default: "skip")
# "skip" will not replace files that have changed.
# "replace" will overwrite all files that have changed.
CHANGED_FILE_POLICY=$(echo "$1" | yq -I=0 ".changed-file-policy") # (string)
if [[ -z $CHANGED_FILE_POLICY || $CHANGED_FILE_POLICY == "null" ]]; then
	CHANGED_FILE_POLICY="skip"
fi

if [[ $CHANGED_FILE_POLICY == "skip" ]]; then
	CHANGED_FILE_POLICY_FLAGS="--no-tty --keep-going"
elif [[ $CHANGED_FILE_POLICY == "replace" ]]; then
	CHANGED_FILE_POLICY_FLAGS="--no-tty --force"
else
	echo "ERROR: 'duplicate-file-policy' has an invalid value."
	echo "Only \"skip\" or \"replace\" are acceptable values"
	exit 1
fi

echo "Checking for conflicting arguments"
if [[ (-z $DOTFILE_REPOSITORY || $DOTFILE_REPOSITORY == "null") && $DISABLE_INIT == false ]]; then
	echo "ERROR: Invalid Config: 'repository' is not set, but initialization is not disabled."
	echo "Set a value for 'repository' or set 'disable_update' to true, if you do not wish to initialize a chezmoi directory using this module"
	exit 1
fi

if [[ $INSTALL_CHEZMOI == true ]]; then
	echo "Checking if curl is installed and executable at /usr/bin/curl"
	if [ -x /usr/bin/curl ]; then
		echo "Downloading chezmoi binary from the latest Github release"
		/usr/bin/curl -Ls https://github.com/twpayne/chezmoi/releases/latest/download/chezmoi-linux-amd64 -o /usr/bin/chezmoi
		echo "Ensuring chezmoi is executable"
		/usr/bin/chmod 755 /usr/bin/chezmoi
	else
		echo "ERROR: curl could not be found in /usr/bin/."
		echo "Please make sure curl is installed on the system you are building your image."
		exit 1
	fi
else
	echo "Skipping install of chezmoi binary"
fi

if [[ $DISABLE_INIT == false ]]; then
	# Write the service to initialize Chezmoi, and insert the repo url in the file
	echo "Writing init service to user unit directory"
	cat >>/usr/lib/systemd/user/chezmoi-init.service <<EOF
  [Unit]
  Description=Initializes Chezmoi if directory is missing
  
  # This service will not execute for a user with an existing chezmoi directory
  ConditionPathExists=!%h/.local/share/chezmoi/.git/
  [Service]
  ExecStart=/usr/bin/chezmoi init --apply ${DOTFILE_REPOSITORY}
  Type=oneshot

  [Install]
  WantedBy=default.target
EOF
else
	echo "Skipping install of chezmoi-init.service"
fi

if [[ $DISABLE_UPDATE == false ]]; then
	# Write the service and timer to update chezmoi for all logged in users and users with lingering enabled
	echo "Writing update service to user unit directory"
	cat >>/usr/lib/systemd/user/chezmoi-update.service <<EOF
  [Unit]
  Description=Chezmoi Update

  [Service]
  ExecStart=/usr/bin/chezmoi update ${CHANGED_FILE_POLICY_FLAGS}
  Type=oneshot
EOF

	echo "Writing update timer to user unit directory"
	cat >>/usr/lib/systemd/user/chezmoi-update.timer <<EOF
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
else
	echo "Skipping install of chezmoi-update.service"
fi

# Enable services
echo "Checking which services to enable"
if [[ $ENABLE_ALL_USERS == true && $DISABLE_INIT == false && $DISABLE_UPDATE == false ]]; then
	echo "Enabling init timer and update service"
	systemctl --global enable chezmoi-init.service chezmoi-update.timer
elif [[ $ENABLE_ALL_USERS == true && $DISABLE_INIT == true && $DISABLE_UPDATE == false ]]; then
	echo "Enabling update timer"
	systemctl --global enable chezmoi-update.timer
elif [[ $ENABLE_ALL_USERS == true && $DISABLE_INIT == false && $DISABLE_UPDATE == true ]]; then
	echo "Enabling init service"
	systemctl --global enable chezmoi-init.service
else
	echo "No services were enabled"
fi
