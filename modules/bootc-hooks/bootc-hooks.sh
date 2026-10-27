#!/bin/bash
echo "Running bootc-hooks module"

set -euo pipefail

# Define paths
SYSTEM_SCRIPT_NAME="run-system-bootc-hooks.sh"
USER_SCRIPT_NAME="run-user-bootc-hooks.sh"
MODULE_DIR="$MODULE_DIRECTORY/bootc-hooks"
LIBEXEC_DIR="/usr/libexec/bootc-hooks"
SYSTEM_SERVICE_NAME="system-bootc-hooks.service"
USER_SERVICE_NAME="user-bootc-hooks.service"
SYSTEM_SERVICE_FILE="/usr/lib/systemd/system/$SYSTEM_SERVICE_NAME"
USER_SERVICE_FILE="/usr/lib/systemd/user/$USER_SERVICE_NAME"

# Copy the scripts to /usr/libexec
echo "Copying script runners"
install -Dm 0755 "$MODULE_DIR/$SYSTEM_SCRIPT_NAME" "$LIBEXEC_DIR/$SYSTEM_SCRIPT_NAME"
install -Dm 0755 "$MODULE_DIR/$USER_SCRIPT_NAME" "$LIBEXEC_DIR/$USER_SCRIPT_NAME"

# Create the system systemd service file
echo "Creating services"
cat <<EOF >"$SYSTEM_SERVICE_FILE"
[Unit]
Description=Run bootc hooks after boot
Requires=network-online.target
After=network-online.target multi-user.target

[Service]
Type=oneshot
ExecStart=$LIBEXEC_DIR/$SYSTEM_SCRIPT_NAME

[Install]
WantedBy=multi-user.target
EOF

# Create the user systemd service file
cat <<EOF >"$USER_SERVICE_FILE"
[Unit]
Description=Run user bootc hooks after login
After=default.target system-bootc-hooks.service

[Service]
Type=oneshot
ExecStart=$LIBEXEC_DIR/$USER_SCRIPT_NAME

[Install]
WantedBy=default.target
EOF

# Enable the service
systemctl -f enable $SYSTEM_SERVICE_NAME
systemctl -f --global enable $USER_SERVICE_NAME

echo "Copying hooks"
SCRIPT_DIR="${CONFIG_DIRECTORY}/scripts"
mkdir -p /usr/libexec/bootc-hooks/{system,user}/{boot,switch,update}

for scope in system user; do
  for event in boot update switch; do
    query=".${scope}.${event}[]?"
    declare -a scripts_array=()
    get_json_array scripts_array "${query}" "$1"
    if [ ${#scripts_array[@]} -gt 0 ]; then
      dest_dir="${LIBEXEC_DIR}/${scope}/${event}"
      echo "Copying ${#scripts_array[@]} scripts for ${scope}/${event} hook..."
      for script in "${scripts_array[@]}"; do
        script_path="${SCRIPT_DIR}/${script}"
        if [ -f "$script_path" ]; then
          echo "  - ${script}"
          install -m 0755 "$script_path" "$dest_dir/"
        else
          echo "Warning: Script '${script}' for ${scope}/${event} hook not found in ${SCRIPT_DIR}" >&2
        fi
      done
    fi
  done
done

chmod -R +x /usr/libexec/bootc-hooks

# Install dependencies
echo "Install yq dependency"
dnf -y install yq
