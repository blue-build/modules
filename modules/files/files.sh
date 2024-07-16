#!/usr/bin/env bash

# Tell build process to exit if there are any errors.
set -euo pipefail

get_yaml_array FILES '.files[]' "$1"

# Support for legacy "/tmp/config/" to satisfy transition period to "/tmp/files/"
if [[ "${CONFIG_DIRECTORY}" == "/tmp/config" ]]; then
  FILES_DIR="${CONFIG_DIRECTORY}/files"
elif [[ "${CONFIG_DIRECTORY}" == "/tmp/files" ]]; then
  FILES_DIR="${CONFIG_DIRECTORY}"
fi

cd "${FILES_DIR}"
shopt -s dotglob

if [[ ${#FILES[@]} -gt 0 ]]; then
    echo "Adding files to image"
    for pair in "${FILES[@]}"; do
        FILE="$PWD/$(echo $pair | yq '.source')"
        DEST=$(echo $pair | yq '.destination')
        if [ -d "$FILE" ]; then
            if [ ! -d "$DEST" ]; then
                mkdir -p "$DEST"
            fi
            echo "Copying $FILE to $DEST"
            cp -rf "$FILE"/* $DEST
            rm -f "$DEST"/.gitkeep
        elif [ -f "$FILE" ]; then
            DEST_DIR=$(dirname "$DEST")
            if [ ! -d "$DEST_DIR" ]; then
                mkdir -p "$DEST_DIR"
            fi
            echo "Copying $FILE to $DEST"
            cp -f $FILE $DEST
            rm -f "$DEST"/.gitkeep
        else
            echo "File or Directory $FILE Does Not Exist in ${FILES_DIR}"
            exit 1
        fi
    done
fi

shopt -u dotglob
