#!/usr/bin/env bash
set -euo pipefail

mapfile -t FONTS <<< "$@"
URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download"
DEST="/usr/share/fonts/nerd-fonts"

echo "Installation of nerd-fonts started"
rm -rf "$DEST"

for FONT in "${FONTS[@]}"; do
    mkdir -p "${DEST}/${FONT}"

    echo "Downloading ${FONT} from ${URL}/${FONT}.tar.xz"
    
    curl "${URL}/${FONT}.tar.xz" -L -o "/tmp/fonts/${FONT}.tar.xz"
    tar -xf "/tmp/fonts/${FONT}.tar.xz" -C "${DEST}/${FONT}"
done

fc-cache -f "${DEST}"