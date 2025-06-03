#!/usr/bin/env bash

# Tell build process to exit if there are any errors.
set -euo pipefail

CONTAINER_DIR="/etc/containers"
MODULE_DIRECTORY="${MODULE_DIRECTORY:-"/tmp/modules"}"
IMAGE_NAME_FILE="${IMAGE_NAME//\//_}"

echo "Setting up container signing in policy.json and cosign.yaml for ${IMAGE_NAME}"
echo "Registry to write: ${IMAGE_REGISTRY}"

if ! [ -d "${CONTAINER_DIR}" ]; then
  mkdir -p "${CONTAINER_DIR}"
fi

if ! [ -d "${CONTAINER_DIR}/registries.d" ]; then
  mkdir -p "${CONTAINER_DIR}/registries.d"
fi

if ! [ -d "/etc/pki/containers" ]; then
  mkdir -p "/etc/pki/containers"
fi

if ! [ -f "/etc/pki/containers/${IMAGE_NAME_FILE}.pub" ]; then
  echo "ERROR: Cannot find '${IMAGE_NAME_FILE}.pub' image key in '/etc/pki/containers/'"
  echo "       BlueBuild CLI should have copied it, but it didn't"
  exit 1
fi

TEMPLATE_POLICY="${MODULE_DIRECTORY}/signing/policy.json"
POLICY_FILE="${CONTAINER_DIR}/policy.json"

# If there is no policy.json file, then copy the template policy
if ! [ -f "${POLICY_FILE}" ]; then
  cp "${TEMPLATE_POLICY}" "${POLICY_FILE}"
fi

# If the already existing policy.json file doesn't have 'reject' as default policy,
# then signing is effectively disabled & template policy.json should be copied in that case also
if [[ "$(jq -r '.default[0].type' "${POLICY_FILE}")" == "insecureAcceptAnything" ]]; then
  cp "${TEMPLATE_POLICY}" "${POLICY_FILE}"
fi

jq --arg image_registry "${IMAGE_REGISTRY}" \
   --arg image_name "${IMAGE_NAME}" \
   --arg image_name_file "${IMAGE_NAME_FILE}" \
   '.transports.docker |= 
    { ($image_registry + "/" + $image_name): [
        {
            "type": "sigstoreSigned",
            "keyPath": ("/etc/pki/containers/" + $image_name_file + ".pub"),
            "signedIdentity": {
                "type": "matchRepository"
            }
        }
    ] } + .' "${POLICY_FILE}" > "/tmp/POLICY.tmp"

mv "/tmp/POLICY.tmp" "${POLICY_FILE}"

mv "${MODULE_DIRECTORY}/signing/registry-config.yaml" "${CONTAINER_DIR}/registries.d/${IMAGE_REGISTRY##*/}-${IMAGE_NAME_FILE}.yaml"
sed -i "s ghcr.io/IMAGENAME ${IMAGE_REGISTRY}/${IMAGE_NAME} g" "${CONTAINER_DIR}/registries.d/${IMAGE_REGISTRY##*/}-${IMAGE_NAME_FILE}.yaml"
