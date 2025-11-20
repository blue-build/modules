#!/usr/bin/env bash

# Tell build process to exit if there are any errors.
set -euo pipefail

MODULE_DIRECTORY="${MODULE_DIRECTORY:-"/tmp/modules"}"

FIRSTBOOT_DATA="/usr/share/ublue-os/firstboot"

mkdir -p "$FIRSTBOOT_DATA/launcher/"

# doesn't overwrite user's yafti.yml
cp --update=none "$MODULE_DIRECTORY/yafti/yafti.yml" "$FIRSTBOOT_DATA/yafti.yml"
cp -r "$MODULE_DIRECTORY/yafti/launcher/" "$FIRSTBOOT_DATA"

FIRSTBOOT_SCRIPT="${FIRSTBOOT_DATA}/launcher/login-profile.sh"
PROFILED_DIR="/etc/profile.d"
FIRSTBOOT_LINK="${PROFILED_DIR}/ublue-firstboot.sh"

# Install yafti
YAFTI_REPO="https://github.com/fiftydinar/Yafti-AppImage"
ARCH="$(uname -m)"
VER=$(basename $(curl -Ls -o /dev/null -w %{url_effective} "$YAFTI_REPO"/releases/latest))
curl -fLs --create-dirs "$YAFTI_REPO/releases/download/${VER}/yafti-${VER%@*}-anylinux-${ARCH}.AppImage" -o /usr/bin/yafti
chmod +x /usr/bin/yafti

# If the profile.d directory doesn't exist, create it
if [ ! -d "${PROFILED_DIR}" ]; then
    mkdir -p "${PROFILED_DIR}"
fi

# Create symlink to our profile script, which creates the per-user "autorun yafti" links.
if [ -f "${FIRSTBOOT_SCRIPT}" ]; then
    ln -sf "${FIRSTBOOT_SCRIPT}" "${FIRSTBOOT_LINK}"
fi

YAFTI_FILE="${FIRSTBOOT_DATA}/yafti.yml"

get_json_array FLATPAKS 'try .["custom-flatpaks"][]' "${1}"
if [[ ${#FLATPAKS[@]} -gt 0 ]]; then
    echo "Adding Flatpaks to yafti.yml"
    sed -i -e '/- Boatswain for Streamdeck: com.feaneron.Boatswain/a \
        Custom:\n          description: Flatpaks suggested by the image maintainer.\n          default: true' "${YAFTI_FILE}"

    for pkg in "${FLATPAKS[@]}"; do
        echo "Adding to yafti: ${pkg}"
        sed -i '/^[[:space:]]*Custom:/ { 
        n; n; n; 
        i\
            - REPLACEMEHERE
    }' "${YAFTI_FILE}"    
        sed -i "s/            - REPLACEMEHERE/            - ${pkg}/g" "${YAFTI_FILE}"
    done
fi
