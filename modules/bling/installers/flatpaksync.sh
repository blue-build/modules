#!/usr/bin/env bash
set -euo pipefail

SYSTEMD_USER_JOBS_DIR="/usr/lib/systemd/user/"

mkdir -p "$SYSTEMD_USER_JOBS_DIR"

chmod +x "$BLING_DIRECTORY"/files/usr/bin/flatpaksync/*

cp -r "$BLING_DIRECTORY"/files/usr/bin/flatpaksync/* /usr/bin/
cp -r "$BLING_DIRECTORY"/files/usr/lib/systemd/user/flatpaksync/* "$SYSTEMD_USER_JOBS_DIR"

systemctl enable --global flatpaksync.path