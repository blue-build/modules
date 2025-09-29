#!/usr/bin/env bash
set -euo pipefail

# Parse JSON input for url-fonts array
readarray -t FONTS < <(echo "$@" | jq -c '.[]')
DEST="/usr/share/fonts/url-fonts"

echo "Installation of url-fonts started"
rm -rf "${DEST}"
mkdir -p "${DEST}"

for FONT_JSON in "${FONTS[@]}"; do
    if [ -n "${FONT_JSON}" ]; then
        # Parse name and url from JSON object
        NAME=$(echo "${FONT_JSON}" | jq -r '.name')
        URL=$(echo "${FONT_JSON}" | jq -r '.url')
        
        # Validate that both name and url exist
        if [ "${NAME}" == "null" ] || [ "${URL}" == "null" ]; then
            echo "Error: Each url-font entry must have both 'name' and 'url' properties"
            exit 1
        fi
        
        NAME=$(echo "$NAME" | xargs) # trim whitespace
        mkdir -p "${DEST}/${NAME}"

        TMPFILE=$(mktemp)
        echo "Downloading ${NAME} from ${URL}"
        curl -fLs "$URL" -o "$TMPFILE"

        case "$URL" in
            *.zip)
                echo "Extracting ZIP archive..."
                unzip -j "$TMPFILE" -d "${DEST}/${NAME}" "*.otf" "*.ttf" 2>/dev/null || true
                # Also try extracting from subdirectories
                unzip -q "$TMPFILE" -d "/tmp/extract_$$" 2>/dev/null || true
                find "/tmp/extract_$$" -name "*.otf" -o -name "*.ttf" 2>/dev/null | while read -r font; do
                    cp "$font" "${DEST}/${NAME}/" 2>/dev/null || true
                done
                rm -rf "/tmp/extract_$$" 2>/dev/null || true
                ;;
            *.tar.*|*.tgz|*.tbz2)
                echo "Extracting TAR archive..."
                tar -xf "$TMPFILE" -C "${DEST}/${NAME}" --wildcards --no-anchored "*.otf" "*.ttf" 2>/dev/null || true
                ;;
            *.otf|*.ttf)
                echo "Copying font file..."
                FILENAME=$(basename "$URL")
                cp "$TMPFILE" "${DEST}/${NAME}/${FILENAME}"
                ;;
            *)
                echo "Unknown file type for $URL, trying as font file..."
                FILENAME=$(basename "$URL")
                cp "$TMPFILE" "${DEST}/${NAME}/${FILENAME}"
                ;;
        esac
        rm -f "$TMPFILE"

        # Verify fonts were extracted
        FONT_COUNT=$(find "${DEST}/${NAME}" -name "*.otf" -o -name "*.ttf" | wc -l)
        echo "Installed ${FONT_COUNT} font files for ${NAME}"
    fi
done

fc-cache --system-only --really-force "${DEST}"
echo "Font cache updated"
