#!/usr/bin/env bash
set -euo pipefail

# Workaround for fonts module failing on legacy templates (with build.sh)
get_yaml_array() {
    # creates array $1 with content at key $2 from $3
    readarray "$1" < <(echo "$3" | yq -I=0 "$2")
}

for SOURCE in "$MODULE_DIRECTORY"/fonts/sources/*.sh; do
    chmod +x "${SOURCE}"

    # get array of fonts for current source
    FILENAME=$(basename -- "${SOURCE}")
    get_yaml_array FONTS ".fonts.${FILENAME%.*}[]" "$1"
    
    if [ ${#FONTS[@]} -gt 0 ]; then
        bash "${SOURCE}" "${FONTS[@]}"
    fi
done
