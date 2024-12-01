#!/usr/bin/env bash
set -euo pipefail

MODULE_DIRECTORY="${MODULE_DIRECTORY:-"/tmp/modules"}"
for SOURCE in "$MODULE_DIRECTORY"/fonts/sources/*.sh; do
    chmod +x "${SOURCE}"

    # get array of fonts for current source
    FILENAME=$(basename -- "${SOURCE}")
    get_json_array FONTS ".fonts.${FILENAME%.*}[]" "$1"

    if [ ${#FONTS[@]} -gt 0 ]; then
        bash "${SOURCE}" "${FONTS[@]}"
    fi
done
