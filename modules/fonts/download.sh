#!/usr/bin/env bash
set -euo pipefail

NAME=$1
FORMAT=$2
URL=$3
DEST=$4

mkdir -p "$DEST"

DOWNLOAD=$(ls "$DEST" | wc -l)
FILE="$NAME.$FORMAT"

if [[ $DOWNLOAD -eq 0 ]] && [[ -n $NAME ]]; then

    echo "Downloading $FILE"

    curl -o "$FILE" -OL "$URL"

    if [[ -f "$FILE" ]]; then

        case $FORMAT in

        tar.xz) tar xvJf "$FILE" -C "$DEST" ;;
        zip) unzip "$FILE" -d "$DEST" ;;

        esac

        rm -rf "$FILE"

        echo "$FILE downloaded"

    else

        echo "Unable to download $FILE"

    fi

fi
