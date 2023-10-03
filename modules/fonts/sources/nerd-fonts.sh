#!/usr/bin/env bash
set -oue pipefail

mapfile -t FONTS <<< "$@"
URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/"
DIR_PRINCIPAL=/usr/share/fonts
COMPACT_FORMAT="zip"

# To download nerd-fonts you need to enter the name of the font and the format you want. See the 3rd parameter of the download script.

if [ ${#FONTS[@]} -gt 0 ]; then

    echo "Installation of nerd-fonts started"

    rm -rf "$DIR_PRINCIPAL"

    for font in "${FONTS[@]}"; do

        font="$(echo "$font" | sed -e 's|^[[:blank:]]||g' | tr -d '\n')"
        
        bash "$(dirname "$0")"/../download.sh "$font" "$COMPACT_FORMAT" "$URL$font.$COMPACT_FORMAT" "$DIR_PRINCIPAL/nerd-fonts-$font"

    done

    fc-cache -f $DIR_PRINCIPAL

fi