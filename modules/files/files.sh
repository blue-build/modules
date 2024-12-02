#!/usr/bin/env bash

# Tell build process to exit if there are any errors.
set -euo pipefail

get_json_array FILES 'try .["files"][]' "$1"

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
      # Support for legacy recipe format to satisfy transition period to new source/destination recipe format
      if [[ $(echo "$pair" | jq -r 'try .["source"]') == "null" || -z $(echo "$pair" | jq -r 'try .["source"]') ]] && [[ $(echo "$pair" | jq -r 'try .["destination"]') == "null" || -z $(echo "$pair" | jq -r 'try .["destination"]') ]]; then
        echo "ATTENTION: You are using the legacy module recipe format"
        echo "           It is advised to switch to new module recipe format,"
        echo "           which contains 'source' & 'destination' YAML keys"
        echo "           For more details, please visit 'files' module documentation:"
        echo "           https://blue-build.org/reference/modules/files/"
        FILE="$PWD/$(echo $pair | jq -r 'to_entries | .[0].key')"
        DEST=$(echo $pair | jq -r 'to_entries | .[0].value')
      else
        FILE="$PWD/$(echo "$pair" | jq -r 'try .["source"]')"
        DEST=$(echo "$pair" | jq -r 'try .["destination"]')
      fi 
        if [ -d "$FILE" ]; then
            if [ ! -d "$DEST" ]; then
                mkdir -p "$DEST"
            fi
            echo "Copying $FILE/* to $DEST"
            cp -rf "$FILE"/* $DEST
            if [[ "${DEST}" =~ *"/" ]] || [[ "${DEST}" == "/" ]]; then
              rm -f "${DEST}.gitkeep"
            else
              rm -f "${DEST}/.gitkeep"
            fi  
        elif [ -f "$FILE" ]; then
            DEST_DIR=$(dirname "$DEST")
            if [ ! -d "$DEST_DIR" ]; then
                mkdir -p "$DEST_DIR"
            fi
            echo "Copying $FILE to $DEST"
            cp -f $FILE $DEST
            if [[ "${DEST}" =~ *"/" ]] || [[ "${DEST}" == "/" ]]; then
              rm -f "${DEST}.gitkeep"
            else
              rm -f "${DEST}/.gitkeep"
            fi  
        else
            echo "File or Directory $FILE Does Not Exist in ${FILES_DIR}"
            exit 1
        fi
    done
else
  echo "ERROR: You did not add any file or folder to the module recipe for copying,"
  echo "       Please assure that you performed this operation correctly"
  exit 1
fi

shopt -u dotglob
