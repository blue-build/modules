#!/usr/bin/env bash

# Tell build process to exit if there are any errors.
set -euo pipefail

MODULE_DIRECTORY="${MODULE_DIRECTORY:-"/tmp/modules"}"

FIRSTBOOT_DATA="/usr/share/ublue-os/firstboot"

mkdir -p "$FIRSTBOOT_DATA/launcher/"

# doesn't overwrite user's yafti.yml (ignores error)
cp -n "$MODULE_DIRECTORY/yafti/yafti.yml" "$FIRSTBOOT_DATA/yafti.yml" || true
cp -r "$MODULE_DIRECTORY/yafti/launcher/" "$FIRSTBOOT_DATA"

FIRSTBOOT_SCRIPT="${FIRSTBOOT_DATA}/launcher/login-profile.sh"
PROFILED_DIR="/etc/profile.d"
FIRSTBOOT_LINK="${PROFILED_DIR}/ublue-firstboot.sh"

# Fetch ublue COPR
REPO="https://copr.fedorainfracloud.org/coprs/ublue-os/staging/repo/fedora-${OS_VERSION}/ublue-os-staging-fedora-${OS_VERSION}.repo"
REPO_URL="${REPO//[$'\t\r\n ']}"
STAGING_REPO_PATH="/etc/yum.repos.d/ublue-os-staging-fedora-${OS_VERSION}.repo"
BACKUP_STAGING_REPO_PATH="${STAGING_REPO_PATH}.backup"

if [ -f "$STAGING_REPO_PATH" ]; then
    mv "$STAGING_REPO_PATH" "$BACKUP_STAGING_REPO_PATH"
fi

echo "Downloading repo file ${REPO_URL}"
curl -fLs --create-dirs "${REPO_URL}" -o "${STAGING_REPO_PATH}"
echo "Downloaded repo file ${REPO_URL}"

rpm-ostree install libadwaita yafti

# Remove ublue COPR
rm /etc/yum.repos.d/ublue-os-staging-fedora-*.repo

if [ -f "$BACKUP_STAGING_REPO_PATH" ]; then
    mv "$BACKUP_STAGING_REPO_PATH" "$STAGING_REPO_PATH"
fi

# If the profile.d directory doesn't exist, create it
if [ ! -d "${PROFILED_DIR}" ]; then
    mkdir -p "${PROFILED_DIR}"
fi

# Create symlink to our profile script, which creates the per-user "autorun yafti" links.
if [ -f "${FIRSTBOOT_SCRIPT}" ]; then
    ln -sf "${FIRSTBOOT_SCRIPT}" "${FIRSTBOOT_LINK}"
fi

YAFTI_FILE="${FIRSTBOOT_DATA}/yafti.yml"

get_yaml_array FLATPAKS '.custom-flatpaks[]' "$1"
if [[ ${#FLATPAKS[@]} -gt 0 ]]; then
    echo "Adding Flatpaks to yafti.yml"
    yq -i '.screens.applications.values.groups.Custom.description = "Flatpaks suggested by the image maintainer."' "${YAFTI_FILE}"
    yq -i '.screens.applications.values.groups.Custom.default = true' "${YAFTI_FILE}"

    for pkg in "${FLATPAKS[@]}"; do
        echo "Adding to yafti: ${pkg}"
        yq -i ".screens.applications.values.groups.Custom.packages += [$pkg]" "${YAFTI_FILE}"
    done
fi
