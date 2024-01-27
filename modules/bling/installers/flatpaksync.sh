#!/usr/bin/env bash
set -euo pipefail

MODULE_DIRECTORY="${MODULE_DIRECTORY:-"/tmp/modules"}"

SYSTEMD_USER_JOBS_DIR="/usr/lib/systemd/user"

mkdir -p "$SYSTEMD_USER_JOBS_DIR"

chmod +x "$MODULE_DIRECTORY"/bling/flatpaksync/flatpaksync
chmod +x "$MODULE_DIRECTORY"/bling/flatpaksync/flatpakcheckout

cp -r "$MODULE_DIRECTORY"/bling/flatpaksync/flatpaksync /usr/bin/flatpaksync
cp -r "$MODULE_DIRECTORY"/bling/flatpaksync/flatpakcheckout /usr/bin/flatpakcheckout
cp -r "$MODULE_DIRECTORY"/bling/flatpaksync/flatpaksync.service "$SYSTEMD_USER_JOBS_DIR/flatpaksync.service"
cp -r "$MODULE_DIRECTORY"/bling/flatpaksync/flatpaksync.path "$SYSTEMD_USER_JOBS_DIR/flatpaksync.path"


systemctl enable --global flatpaksync.path