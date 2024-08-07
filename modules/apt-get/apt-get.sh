#!/usr/bin/env bash

# Tell build process to exit if there are any errors.
set -euo pipefail

get_yaml_array INSTALL_PKGS '.install[]' "$1"

apt-get install -y "${INSTALL_PKGS[@]}"
apt-get clean