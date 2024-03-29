#!/usr/bin/env bash
set -euo pipefail

mapfile -t FONTS <<< "$@"
DEST="/usr/share/fonts/google-fonts"

echo "Installation of google-fonts started"
rm -rf "${DEST}"

for FONT in "${FONTS[@]}"; do
    mkdir -p "${DEST}/${FONT}"

    readarray -t "FILE_REFS" < <(
        curl -s "https://fonts.google.com/download/list?family=${FONT// /%20}" | # spaces are replaced with %20 for the URL
        tail -n +2 | # remove first line, which as of March 2024 contains ")]}'" and breaks JSON parsing
        jq -c '.manifest.fileRefs[]' # -c option makes output bash parsable
    )

    for FILE_REF in "${FILE_REFS[@]}"; do
        FILENAME=$(echo "${FILE_REF}" | jq -r '.filename')
        URL=$(echo "${FILE_REF}" | jq -r '.url')

        echo "Downloading ${FILENAME} from ${URL}"
        
        curl "${URL}" -o "${DEST}/${FONT}/${FILENAME##*/}" # everything before the last / is removed to get the filename
    done
done

fc-cache -f "${DEST}"