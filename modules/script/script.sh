#!/usr/bin/env bash

# Tell build process to exit if there are any errors.
set -euo pipefail

get_json_array SCRIPTS 'try .["scripts"][]' "$1"
get_json_array SNIPPETS 'try .["snippets"][]' "$1"

# shellcheck disable=SC2153
if [[ ${#SCRIPTS[@]} -gt 0  ]]; then
    cd "$CONFIG_DIRECTORY/scripts"
    # Make every script executable
    find "$PWD" -type f -exec chmod +x {} \;
    for SCRIPT in "${SCRIPTS[@]}"; do
        echo "Running script $SCRIPT"
        "$PWD/$SCRIPT"
    done
fi

# shellcheck disable=SC2153
for SNIPPET in "${SNIPPETS[@]}"; do
    echo "Running snippet $SNIPPET"
    bash -c "$SNIPPET"
done