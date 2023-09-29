#!/usr/bin/env bash
set -oue pipefail

declare FONTS=( "$@" )
declare URL="https://fonts.google.com/download?family="
declare DIR_PRINCIPAL=/usr/share/fonts/google-fonts

if [ ${#FONTS[@]} -gt 0 ]; then

    echo "Installation of google-fonts started"

    for font in "${FONTS[@]}"; do

        font="$(echo "$font" | tr -d '\n')"

        mkdir -p "$DIR_PRINCIPAL/$font"

        bash "$FONTS_MODULE_DIR"/scripts/download.sh "$font" "$URL${font// /%20}" "$DIR_PRINCIPAL/$font"

    done

    fc-cache -f $DIR_PRINCIPAL

fi