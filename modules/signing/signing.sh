#!/usr/bin/env bash

# Tell build process to exit if there are any errors.
set -euo pipefail

CONTAINER_DIR="/usr/etc/containers"
MODULE_DIRECTORY="${MODULE_DIRECTORY:-"/tmp/modules"}"

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

cp "/usr/share/ublue-os/cosign.pub" "/usr/etc/pki/containers/$IMAGE_NAME.pub"

POLICY_FILE="$CONTAINER_DIR/policy.json"

yq -i -o=j '.transports.docker |=
    {"'"$IMAGE_REGISTRY"'/'"$IMAGE_NAME"'": [
            {
                "type": "sigstoreSigned",
                "keyPath": "/usr/etc/pki/containers/'"$IMAGE_NAME"'.pub",
                "signedIdentity": {
                    "type": "matchRepository"
                }
            }
        ]
    }
+ .' "$POLICY_FILE"

IMAGE_REF="ostree-image-signed:docker://$IMAGE_REGISTRY/$IMAGE_NAME"

mv "$MODULE_DIRECTORY/signing/registry-config.yaml" "$CONTAINER_DIR/registries.d/$IMAGE_NAME.yaml"
sed -i "s ghcr.io/IMAGENAME $IMAGE_REGISTRY g" "$CONTAINER_DIR/registries.d/$IMAGE_NAME.yaml"
