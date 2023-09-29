#!/usr/bin/env bash
set -oue pipefail

COMPRESS_TYPES=("zip" "tar.gz")

declare NAME=$1
declare URL=$2
declare DEST=$3

mkdir -p "$DEST"

echo "${COMPRESS_TYPES[@]}" | while IFS=$'\n' read -r -d ' ' type; do

    DOWNLOAD=$(ls | wc -l)
    FILE="$NAME.$type"

    if [[ $DOWNLOAD -eq 0 ]]; then

        echo "Downloading $FILE"

        curl -o "$FILE" -OL "$URL"

        if [[ -f "$FILE" ]]; then

            case $type in

            tar.xz) tar xvJf "$FILE" -C "$DEST" ;;
            zip) unzip "$FILE" -d "$DEST" ;;

            esac

            rm -rf "$FILE"

            echo "$FILE DOWNLOAD"

        else

            echo "Unable to download $FILE"

        fi

    fi

done