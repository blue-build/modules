#!/usr/bin/env bash

# Tell build process to exit if there are any errors.
set -euo pipefail

rpm-ostree install "$BLING_DIRECTORY"/rpms/ublue-os-wallpapers*.rpm