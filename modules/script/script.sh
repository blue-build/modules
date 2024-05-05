#!/usr/bin/env bash

# Tell build process to exit if there are any errors.
set -euo pipefail

get_yaml_array SCRIPTS '.scripts[]' "$1"
get_yaml_array SNIPPETS '.snippets[]' "$1"

cd "$CONFIG_DIRECTORY/scripts"
# Make every script executable
find "$PWD" -type f -exec chmod +x {} \;
for SCRIPT in "${SCRIPTS[@]}"; do
    echo "Running script $SCRIPT"
    "$PWD/$SCRIPT"
done

for SNIPPET in "${SNIPPETS[@]}"; do
    echo "Running snippet $SNIPPET"
    bash -c "$SNIPPET"
done