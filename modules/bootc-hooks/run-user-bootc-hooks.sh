#!/usr/bin/env bash

set -euo pipefail

# Define paths
VERSION_FILE="/var/lib/bootc-hooks/version.yaml"
PREVIOUS_VERSION_FILE="/var/lib/bootc-hooks/version.previous.yaml"
SWITCH_HOOKS_DIR="/usr/libexec/bootc-hooks/user/switch"
UPDATE_HOOKS_DIR="/usr/libexec/bootc-hooks/user/update"
BOOT_HOOKS_DIR="/usr/libexec/bootc-hooks/user/boot"

old_image=""
old_digest=""
if [ -f "$PREVIOUS_VERSION_FILE" ]; then
    echo "Reading previous image and digest from $PREVIOUS_VERSION_FILE"
    old_image=$(yq e '.image' "$PREVIOUS_VERSION_FILE")
    old_digest=$(yq e '.digest' "$PREVIOUS_VERSION_FILE")
    echo "Previous User Image: ${old_image}"
    echo "Previous User Digest: ${old_digest}"
fi

new_image=""
new_digest=""
if [ -f "$VERSION_FILE" ]; then
    echo "Reading new image and digest from $VERSION_FILE"
    new_image=$(yq e '.image' "$VERSION_FILE")
    new_digest=$(yq e '.digest' "$VERSION_FILE")
    echo "New User Image: ${new_image}"
    echo "New User Digest: ${new_digest}"
fi

# --- Run Hooks ---

# Run switch hooks if the image has changed
if [ "${new_image}" != "${old_image}" ]; then
    echo "Image has changed for user. Running switch hooks."
    if [ -d "$SWITCH_HOOKS_DIR" ]; then
        for hook in "$SWITCH_HOOKS_DIR"/*; do
            if [ -x "$hook" ]; then
                echo "Running user switch hook: $hook"
                "$hook"
            fi
        done
    fi
fi

# Run update hooks if the digest has changed
if [ "${new_digest}" != "${old_digest}" ]; then
    echo "Digest has changed for user. Running update hooks."
    if [ -d "$UPDATE_HOOKS_DIR" ]; then
        for hook in "$UPDATE_HOOKS_DIR"/*; do
            if [ -x "$hook" ]; then
                echo "Running user update hook: $hook"
                "$hook"
            fi
        done
    fi
fi

# Always run boot hooks
echo "Running user boot hooks."
if [ -d "$BOOT_HOOKS_DIR" ]; then
    for hook in "$BOOT_HOOKS_DIR"/*; do
        if [ -x "$hook" ];
        then
            echo "Running user boot hook: $hook"
            "$hook"
        fi
    done
fi

echo "User bootc hooks finished."
