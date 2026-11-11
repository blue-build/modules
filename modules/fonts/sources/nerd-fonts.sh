#!/usr/bin/env bash
set -euo pipefail

mapfile -t FONTS <<< "$@"
URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download"
DEST="/usr/share/fonts/nerd-fonts"

echo "Installation of nerd-fonts started"

mkdir -p /tmp/fonts
for FONT in "${FONTS[@]}"; do
    FONT=${FONT// /} # remove spaces
    if [ ${#FONT} -gt 0 ]; then
        rm -rf "${DEST}/${FONT}"
        mkdir -p "${DEST}/${FONT}"

        echo "Downloading ${FONT} from ${URL}/${FONT}.tar.xz"
        curl -fLsS --retry 5 --create-dirs "${URL}/${FONT}.tar.xz" -o "/tmp/fonts/${FONT}.tar.xz"
        echo "Downloaded ${FONT}"

        tar -xf "/tmp/fonts/${FONT}.tar.xz" -C "${DEST}/${FONT}"

        if [[ "${FONT}" == "NerdFontsSymbolsOnly" ]]; then
            FONTCONFIG="/usr/share/fontconfig/conf.avail"
            mv "${DEST}/${FONT}/10-nerd-font-symbols.conf" "${FONTCONFIG}"
            ln -s "${FONTCONFIG}" "/etc/fonts/conf.d/10-nerd-font-symbols.conf"
        fi
    fi
done
rm -rf /tmp/fonts

fc-cache --system-only --really-force "${DEST}"
