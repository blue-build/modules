#!/usr/bin/env bash

# Tell build process to exit if there are any errors.
set -euo pipefail

MODULE_DIRECTORY="${MODULE_DIRECTORY:-"/tmp/modules"}"

cp -r "$MODULE_DIRECTORY/bling/dconf-update.service" "/usr/lib/systemd/system/dconf-update.service"
systemctl enable dconf-update.service
