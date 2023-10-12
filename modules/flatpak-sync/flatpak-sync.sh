#!/usr/bin/env bash
set -oue pipefail

export BLING_FILES_DIRECTORY="/tmp/bling/files"

chmod +x "$BLING_FILES_DIRECTORY"/usr/bin/flatpaksync/*

cp -r "$BLING_FILES_DIRECTORY"/usr/bin/flatpaksync/* /usr/bin/

cp -r "$BLING_FILES_DIRECTORY"/usr/lib/systemd/user/flatpaksync.service /usr/lib/systemd/user/flatpaksync.service
cp -r "$BLING_FILES_DIRECTORY"/usr/lib/systemd/user/flatpaksync.path /usr/lib/systemd/user/flatpaksync.path

systemctl enable --global flatpaksync.path