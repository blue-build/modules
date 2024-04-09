#!/usr/bin/env bash

# Tell build process to exit if there are any errors.
set -euo pipefail

get_yaml_array GETTEXT_DOMAIN '.install[]' "$1"
GNOME_VER=$(gnome-shell --version | sed 's/[^0-9]*\([0-9]*\).*/\1/')
echo "Gnome version: v${GNOME_VER}"

if [[ ${#GETTEXT_DOMAIN[@]} -gt 0 ]]; then
  for EXTENSION in "${GETTEXT_DOMAIN[@]}"; do
      URL="https://extensions.gnome.org/extension-data/${EXTENSION}.shell-extension.zip"
      TMP_DIR="/tmp/${EXTENSION}"
      ARCHIVE=$(basename "${URL}")
      ARCHIVE_DIR="${TMP_DIR}/${ARCHIVE}"
      VERSION=$(echo "${EXTENSION}" | grep -oP 'v\d+')
      echo "Installing ${EXTENSION} Gnome extension with version ${VERSION}"
      # Download archive
      curl -L "${URL}" --create-dirs -o "${ARCHIVE_DIR}"
      # Extract archive
      echo "Extracting ZIP archive"
      unzip "${ARCHIVE_DIR}" -d "${TMP_DIR}" > /dev/null
      # Remove archive
      echo "Removing archive"
      rm "${ARCHIVE_DIR}"
      # Read necessary info from metadata.json
      echo "Reading necessary info from metadata.json"
      EXTENSION_NAME=$(yq '.name' < "${TMP_DIR}/metadata.json")
      UUID=$(yq '.uuid' < "${TMP_DIR}/metadata.json")
      EXT_GNOME_VER=$(yq '.shell-version[]' < "${TMP_DIR}/metadata.json")
      # If extension does not have the important key in metadata.json,
      # inform the user & fail the build
      if [[ "${UUID}" == "null" ]]; then
        echo "ERROR: Extension ${EXTENSION_NAME} doesn't have 'uuid' key inside metadata.json"
        echo "You may inform the extension developer about this error, as he can fix it"
        exit 1
      fi
      if [[ "${EXT_GNOME_VER}" == "null" ]]; then
        echo "ERROR: Extension ${EXTENSION_NAME} doesn't have 'shell-version' key inside metadata.json"
        echo "You may inform the extension developer about this error, as he can fix it"
        exit 1
      fi      
      # Compare if extension is compatible with current Gnome version
      # If extension is not compatible, inform the user & fail the build
      if ! [[ "${EXT_GNOME_VER}" =~ "${GNOME_VER}" ]]; then
        echo "ERROR: Extension ${EXTENSION_NAME} is not compatible with current Gnome v${GNOME_VER}!"
        exit 1
      fi  
      # Install main extension files
      echo "Installing main extension files"
      install -d -m 0755 "/usr/share/gnome-shell/extensions/${UUID}/"
      find "${TMP_DIR}" -mindepth 1 -maxdepth 1 ! -path "*locale*" ! -path "*schemas*" -exec cp -r {} "/usr/share/gnome-shell/extensions/${UUID}/" \;
      find "/usr/share/gnome-shell/extensions/${UUID}" -type d -exec chmod 0755 {} +
      find "/usr/share/gnome-shell/extensions/${UUID}" -type f -exec chmod 0644 {} +
      # Install schema
      echo "Installing schema extension file"
      install -d -m 0755 "/usr/share/glib-2.0/schemas/"
      install -D -p -m 0644 "${TMP_DIR}/schemas/"*.gschema.xml "/usr/share/glib-2.0/schemas/"
      # Install languages
      echo "Installing language extension files"
      install -d -m 0755 "/usr/share/locale/"
      cp -r "${TMP_DIR}/locale"/* "/usr/share/locale/"
      # Delete the temporary directory
      echo "Cleaning up the temporary directory"
      rm -r "${TMP_DIR}"
      echo "Extension ${EXTENSION_NAME} is successfully installed"
      echo "------------------------------DONE----------------------------------"     
  done
else
  echo "ERROR: You did not specify gettext-domain in module recipe file"
  exit 1
fi

echo "Finished the installation of Gnome extensions"
