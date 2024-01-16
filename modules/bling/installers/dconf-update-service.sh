#!/usr/bin/env bash

# Tell build process to exit if there are any errors.
set -euo pipefail

cp -r "$BLING_DIRECTORY/files/usr/lib/systemd/system/dconf-update.service" "/usr/lib/systemd/system/dconf-update.service"
systemctl enable dconf-update.service
