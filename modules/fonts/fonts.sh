#!/usr/bin/env bash
set -euo pipefail

# Workaround for fonts module failing on legacy templates (with build.sh)
get_yaml_array() {
    # creates array $1 with content at key $2 from $3
    readarray "$1" < <(echo "$3" | yq -I=0 "$2")
}

export FONTS_MODULE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

for source in "$FONTS_MODULE_DIR"/sources/*.sh; do

    chmod +x "$source"

    filename=$(basename -- "$source")

    get_yaml_array FONTS ".fonts.${filename%.*}[]" "$1"

    bash "$source" "${FONTS[@]}"
    
done
