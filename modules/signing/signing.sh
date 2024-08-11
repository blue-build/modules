#!/usr/bin/env bash

# Tell build process to exit if there are any errors.
set -euo pipefail

if grep -q OSTREE /etc/os-release; then
    echo "Detected OSTREE"

    CONTAINER_DIR="/usr/etc/containers"
    MODULE_DIRECTORY="${MODULE_DIRECTORY:-"/tmp/modules"}"
    IMAGE_NAME_FILE="${IMAGE_NAME//\//_}"

    echo "Setting up container signing in policy.json and cosign.yaml for $IMAGE_NAME"
    echo "Registry to write: $IMAGE_REGISTRY"

    if ! [ -d "$CONTAINER_DIR" ]; then
        mkdir -p "$CONTAINER_DIR"
    fi

    if ! [ -d $CONTAINER_DIR/registries.d ]; then
    mkdir -p "$CONTAINER_DIR/registries.d"
    fi

    if ! [ -d "/usr/etc/pki/containers" ]; then
        mkdir -p "/usr/etc/pki/containers"
    fi

    if ! [ -f "$CONTAINER_DIR/policy.json" ]; then
        cp "$MODULE_DIRECTORY/signing/policy.json" "$CONTAINER_DIR/policy.json"
    fi

    if ! [ -f "/usr/etc/pki/containers/$IMAGE_NAME_FILE.pub" ]; then
        cp "/usr/share/ublue-os/cosign.pub" "/usr/etc/pki/containers/$IMAGE_NAME_FILE.pub"
    fi

    POLICY_FILE="$CONTAINER_DIR/policy.json"

    yq -i -o=j '.transports.docker |=
        {"'"$IMAGE_REGISTRY"'/'"$IMAGE_NAME"'": [
                {
                    "type": "sigstoreSigned",
                    "keyPath": "/usr/etc/pki/containers/'"$IMAGE_NAME_FILE"'.pub",
                    "signedIdentity": {
                        "type": "matchRepository"
                    }
                }
            ]
        }
    + .' "$POLICY_FILE"

    mv "$MODULE_DIRECTORY/signing/registry-config.yaml" "$CONTAINER_DIR/registries.d/$IMAGE_NAME_FILE.yaml"
    sed -i "s ghcr.io/IMAGENAME $IMAGE_REGISTRY g" "$CONTAINER_DIR/registries.d/$IMAGE_NAME_FILE.yaml"
elif grep -q "Vanilla OS" /etc/os-release; then
    echo "Detected Vanilla OS"
    USERNAME="${IMAGE_REGISTRY##*/}"
    jq -r ".name |= \"$USERNAME/$IMAGE_NAME\"" /usr/share/abroot/abroot.json > /usr/share/abroot/abroot_tmp.json
    mv /usr/share/abroot/abroot_tmp.json /usr/share/abroot/abroot.json
fi