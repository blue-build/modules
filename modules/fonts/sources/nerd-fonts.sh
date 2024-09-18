#!/usr/bin/env bash
set -euo pipefail

mapfile -t FONTS <<< "$@"
URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download"
DEST="/usr/share/fonts/nerd-fonts"

echo "Installation of nerd-fonts started"
rm -rf "${DEST}"

mkdir -p /tmp/fonts
for FONT in "${FONTS[@]}"; do
    FONT=${FONT// /} # remove spaces
    if [ ${#FONT} -gt 0 ]; then
        mkdir -p "${DEST}/${FONT}"

        echo "Downloading ${FONT} from ${URL}/${FONT}.tar.xz"
        curl -fLs --create-dirs "${URL}/${FONT}.tar.xz" -o "/tmp/fonts/${FONT}.tar.xz"
        echo "Downloaded ${FONT}"

        tar -xf "/tmp/fonts/${FONT}.tar.xz" -C "${DEST}/${FONT}"
    fi
done
rm -rf /tmp/fonts

fc-cache --system-only --really-force "${DEST}"
