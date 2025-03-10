#!/usr/bin/env bash

set -euo pipefail

get_json_array CONFIG_SELECTION 'try .["include"][]' "$1"
VALIDATE="$(echo "$1" | jq -r 'try .["validate"]')"

IMPORT_FILE="/usr/share/ublue-os/just/60-custom.just"
CONFIG_FOLDER="${CONFIG_DIRECTORY}/justfiles"
DEST_FOLDER="/usr/share/bluebuild/justfiles"

# Abort if justfiles folder is not present
if [ ! -d "${CONFIG_FOLDER}" ]; then
    echo "Error: The config folder '${CONFIG_FOLDER}' was not found."
    exit 1
fi

# Include all files in the folder if none specified
if [[ ${#CONFIG_SELECTION[@]} == 0 ]]; then
    CONFIG_SELECTION=($(find "${CONFIG_FOLDER}" -mindepth 1 -maxdepth 1 -exec basename {} \;))
fi

for SELECTED in "${CONFIG_SELECTION[@]}"; do

    echo "------------------------------------------------------------------------"
    echo "--- Adding folder/file '${SELECTED}'"
    echo "------------------------------------------------------------------------"

    # Find all justfiles, starting from 'SELECTED' and get their paths
    JUSTFILES=($(find "${CONFIG_FOLDER}/${SELECTED}" -type f -name "*.just" | sed "s|${CONFIG_FOLDER}/||g"))

    # Abort if no justfiles found at 'SELECTED'
    if [[ ${#JUSTFILES[@]} == 0 ]]; then
        echo "Error: No justfiles were found in '${CONFIG_FOLDER}/${SELECTED}'."
        exit 1
    fi

    # Validate all found justfiles if set to do so
    if [ "${VALIDATE}" == "true" ]; then

        echo "Validating justfiles"
        VALIDATION_FAILED=0
        for JUSTFILE in "${JUSTFILES[@]}"; do
            if ! /usr/bin/just --fmt --check --unstable --justfile "${CONFIG_FOLDER}/${JUSTFILE}" &> /dev/null; then
                echo "- The justfile '${JUSTFILE}' FAILED validation."
                VALIDATION_FAILED=1
            fi
        done

        # Exit if any justfiles are not valid
        if [ ${VALIDATION_FAILED} -eq 1 ]; then
            echo "Error: Some justfiles didn't pass validation."
            exit 1
        else
            echo "- All justfiles passed validation."
        fi

    fi

    # Copy 'SELECTED' to destination folder
    echo "Copying folders/files"
    mkdir -p "${DEST_FOLDER}/$(dirname ${SELECTED})"
    cp -rfT "${CONFIG_FOLDER}/${SELECTED}" "${DEST_FOLDER}/${SELECTED}"
    echo "- Copied '${CONFIG_FOLDER}/${SELECTED}' to '${DEST_FOLDER}/${SELECTED}'."

    # Generate import lines for all found justfiles
    echo "Adding import lines"
    for JUSTFILE in "${JUSTFILES[@]}"; do

        # Create an import line
        IMPORT_LINE="import \"${DEST_FOLDER}/${JUSTFILE}\""
        
        # Skip the import line if it already exists, else append it to import file
        if [[ -f "${IMPORT_FILE}" ]]; then
          if grep -wq "${IMPORT_LINE}" "${IMPORT_FILE}"; then
              echo "- Skipped: '${IMPORT_LINE}' (already present)"
          else
              echo "${IMPORT_LINE}" >> "${IMPORT_FILE}"
              echo "- Added: '${IMPORT_LINE}'"
          fi
        else  
            echo "${IMPORT_LINE}" > "${IMPORT_FILE}"
            echo "- Added: '${IMPORT_LINE}'"
        fi  
    done

done
