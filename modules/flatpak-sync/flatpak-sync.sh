#!/usr/bin/env bash
set -oue pipefail

export BLING_FILES_DIRECTORY="/tmp/bling/files"
SYSTEMD_USER_JOBS_DIR="/usr/lib/systemd/user/"

mkdir -p $SYSTEMD_USER_JOBS_DIR

chmod +x "$BLING_FILES_DIRECTORY"/usr/bin/flatpaksync/*

cp -r "$BLING_FILES_DIRECTORY"/usr/bin/flatpaksync/* /usr/bin/

cp -r "$BLING_FILES_DIRECTORY"/usr/lib/systemd/user/flatpaksync/* $SYSTEMD_USER_JOBS_DIR

systemctl enable --global flatpaksync.path