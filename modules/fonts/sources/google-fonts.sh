#!/usr/bin/env bash
set -oue pipefail

mapfile -t FONTS <<< "$@"
URL="https://fonts.google.com/download?family="
DIR_PRINCIPAL=/usr/share/fonts
COMPACT_FORMAT="zip"

# To download google-fonts it is necessary to enter the name of the font replacing the spaces with '%20'. See the 3rd parameter of the download script.

if [ ${#FONTS[@]} -gt 0 ]; then

    echo "Installation of google-fonts started"

    rm -rf "$DIR_PRINCIPAL"

    for font in "${FONTS[@]}"; do

        font="$(echo "$font" | sed -e 's|^[[:blank:]]||g' | tr -d '\n')"

        bash "$(dirname "$0")"/../download.sh "$font" "$COMPACT_FORMAT" "$URL${font// /%20}" "$DIR_PRINCIPAL/google-fonts-$font" 

    done

    fc-cache -f $DIR_PRINCIPAL

fi