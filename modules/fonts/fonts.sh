#!/usr/bin/env bash
set -euo pipefail

MODULE_DIRECTORY="${MODULE_DIRECTORY:-"/tmp/modules"}"
for SOURCE in "$MODULE_DIRECTORY"/fonts/sources/*.sh; do
    chmod +x "${SOURCE}"

    # get array of fonts for current source
    FILENAME=$(basename -- "${SOURCE}")
    ARRAY_NAME="${FILENAME%.*}"
    
    # For url-fonts, we need to pass the whole array as JSON
    if [ "${ARRAY_NAME}" = "url-fonts" ]; then
        FONTS_JSON=$(echo "${1}" | jq -c --arg ARRAY_NAME "${ARRAY_NAME}" 'try .fonts.[$ARRAY_NAME]')
        if [ "${FONTS_JSON}" != "null" ] && [ "${FONTS_JSON}" != "[]" ]; then
            bash "${SOURCE}" "${FONTS_JSON}"
        fi
    else
        # For nerd-fonts and google-fonts, keep the existing behavior
        readarray FONTS < <(echo "${1}" | jq -c -r --arg ARRAY_NAME "${ARRAY_NAME}" 'try .fonts.[$ARRAY_NAME][]')
        if [ ${#FONTS[@]} -gt 0 ]; then
            bash "${SOURCE}" "${FONTS[@]}"
        fi
    fi
done
