#!/usr/bin/env bash

set -euo pipefail

VERSION_DIR="/var/lib/bootc-hooks"
VERSION_FILE="$VERSION_DIR/version.yaml"
PREVIOUS_VERSION_FILE="$VERSION_DIR/version.previous.yaml"
SWITCH_HOOKS_DIR="/usr/libexec/bootc-hooks/system/switch"
UPDATE_HOOKS_DIR="/usr/libexec/bootc-hooks/system/update"
BOOT_HOOKS_DIR="/usr/libexec/bootc-hooks/system/boot"

# Create the directory if it doesn't exist
sudo mkdir -p "$VERSION_DIR"

# Rotate version files
if [ -f "$VERSION_FILE" ]; then
    echo "Moving old version file to $PREVIOUS_VERSION_FILE"
    sudo mv "$VERSION_FILE" "$PREVIOUS_VERSION_FILE"
fi

old_image=""
old_digest=""
if [ -f "$PREVIOUS_VERSION_FILE" ]; then
    echo "Reading previous image and digest from $PREVIOUS_VERSION_FILE"
    old_image=$(yq e '.image' "$PREVIOUS_VERSION_FILE")
    old_digest=$(yq e '.digest' "$PREVIOUS_VERSION_FILE")
    echo "Previous Image: ${old_image}"
    echo "Previous Digest: ${old_digest}"
fi

output=$(bootc status --format yaml --booted)

new_image=$(echo "$output" | yq e '.status.booted.image.image.image')
new_digest=$(echo "$output" | yq e '.status.booted.image.imageDigest')

# Create the YAML content
yaml_content=$(cat <<EOF
image: ${new_image}
digest: ${new_digest}
EOF
)

# Write the YAML content to the file
echo "$yaml_content" | sudo tee "$VERSION_FILE" > /dev/null

if [ "${new_image}" != "${old_image}" ]; then
    echo "Image has changed. Running switch hooks."
    if [ -d "$SWITCH_HOOKS_DIR" ]; then
        for hook in "$SWITCH_HOOKS_DIR"/*; do
            if [ -x "$hook" ]; then
                echo "Running hook: $hook"
                "$hook"
            fi
        done
    fi
fi

if [ "${new_digest}" != "${old_digest}" ]; then
    echo "Digest has changed. Running update hooks."
    if [ -d "$UPDATE_HOOKS_DIR" ]; then
        for hook in "$UPDATE_HOOKS_DIR"/*; do
            if [ -x "$hook" ]; then
                echo "Running hook: $hook"
                "$hook"
            fi
        done
    fi
fi

echo "Running boot hooks."
if [ -d "$BOOT_HOOKS_DIR" ]; then
    for hook in "$BOOT_HOOKS_DIR"/*; do
        if [ -x "$hook" ]; then
            echo "Running hook: $hook"
            "$hook"
        fi
    done
fi
