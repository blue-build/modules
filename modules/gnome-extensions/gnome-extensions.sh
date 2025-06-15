#!/usr/bin/env bash
# shellcheck disable=SC2128,SC2178

# Tell build process to exit if there are any errors.
set -euo pipefail

get_json_array INSTALL 'try .["install"][]' "$1"
get_json_array UNINSTALL 'try .["uninstall"][]' "$1"

if [[ ${#INSTALL[@]} -lt 1 ]] && [[ ${#UNINSTALL[@]} -lt 1 ]]; then
  echo "ERROR: You did not specify the extension to install or uninstall in module recipe file"
  exit 1
fi

if ! command -v gnome-shell &> /dev/null; then 
  echo "ERROR: Your custom image is using non-Gnome desktop environment, where Gnome extensions are not supported"
  exit 1
fi

echo "Testing connection with https://extensions.gnome.org/..."
if ! curl --output /dev/null --silent --head --fail "https://extensions.gnome.org/"; then
  echo "ERROR: Connection unsuccessful."
  echo "       This usually happens when https://extensions.gnome.org/ website is down."
  echo "       Please try again later (or disable the module temporarily)"
  exit 1
else
  echo "Connection successful, proceeding."
fi  


GNOME_VER=$(gnome-shell --version | sed 's/[^0-9]*\([0-9]*\).*/\1/')
echo "Gnome version: ${GNOME_VER}"
LEGACY=false

# Legacy support for installing extensions, to retain compatibility with legacy configs
if [[ ${#INSTALL[@]} -gt 0 ]]; then
  for EXTENSION in "${INSTALL[@]}"; do
      # If extension contains .v12 suffix at the end, than it's the legacy install entry
      # 12 number in .v12 is just an example, any integer after it is allowed
      shopt -s extglob
      if [[ ! "${EXTENSION}" == *".v"*([0-9]) ]]; then
        break
      else
        LEGACY=true
      fi
      shopt -u extglob
      echo "ATTENTION: This is the legacy method of installing extensions."
      echo "           Change the install entry to literal name of the extension"
      echo "           Please see the latest docs of gnome-extensions module for more details:"
      echo "           https://blue-build.org/reference/modules/gnome-extensions/"
      URL="https://extensions.gnome.org/extension-data/${EXTENSION}.shell-extension.zip"
      TMP_DIR="/tmp/${EXTENSION}"
      ARCHIVE=$(basename "${URL}")
      ARCHIVE_DIR="${TMP_DIR}/${ARCHIVE}"
      VERSION=$(echo "${EXTENSION}" | grep -oP 'v\d+')
      echo "Installing ${EXTENSION} Gnome extension with version ${VERSION}"
      # Download archive
      echo "Downloading ZIP archive ${URL}"
      curl -fLs --create-dirs "${URL}" -o "${ARCHIVE_DIR}"
      echo "Downloaded ZIP archive ${URL}"
      # Extract archive
      echo "Extracting ZIP archive"
      unzip "${ARCHIVE_DIR}" -d "${TMP_DIR}" > /dev/null
      # Remove archive
      echo "Removing archive"
      rm "${ARCHIVE_DIR}"
      # Read necessary info from metadata.json
      echo "Reading necessary info from metadata.json"
      EXTENSION_NAME=$(jq -r '.["name"]' < "${TMP_DIR}/metadata.json")
      UUID=$(jq -r '.["uuid"]' < "${TMP_DIR}/metadata.json")
      EXT_GNOME_VER=$(jq -r '.["shell-version"][]' < "${TMP_DIR}/metadata.json")
      # If extension does not have the important key in metadata.json,
      # inform the user & fail the build
      if [[ "${UUID}" == "null" ]]; then
        echo "ERROR: Extension '${EXTENSION_NAME}' doesn't have 'uuid' key inside metadata.json"
        echo "You may inform the extension developer about this error, as he can fix it"
        exit 1
      fi
      if [[ "${EXT_GNOME_VER}" == "null" ]]; then
        echo "ERROR: Extension '${EXTENSION_NAME}' doesn't have 'shell-version' key inside metadata.json"
        echo "You may inform the extension developer about this error, as he can fix it"
        exit 1
      fi      
      # Compare if extension is compatible with current Gnome version
      # If extension is not compatible, inform the user & fail the build
      if ! [[ "${EXT_GNOME_VER}" =~ "${GNOME_VER}" ]]; then
        echo "ERROR: Extension '${EXTENSION_NAME}' is not compatible with current Gnome v${GNOME_VER}!"
        exit 1
      fi  
      # Install main extension files
      echo "Installing main extension files"
      install -d -m 0755 "/usr/share/gnome-shell/extensions/${UUID}/"
      find "${TMP_DIR}" -mindepth 1 -maxdepth 1 ! -path "*locale*" ! -path "*schemas*" -exec cp -r {} "/usr/share/gnome-shell/extensions/${UUID}/" \;
      find "/usr/share/gnome-shell/extensions/${UUID}" -type d -exec chmod 0755 {} +
      find "/usr/share/gnome-shell/extensions/${UUID}" -type f -exec chmod 0644 {} +
      # Install schema
      if [[ -d "${TMP_DIR}/schemas" ]]; then
        echo "Installing schema extension file"
        # Workaround for extensions, which explicitly require compiled schema to be in extension UUID directory (rare scenario due to how extension is programmed in non-standard way)
        # Error code example:
        # GLib.FileError: Failed to open file “/usr/share/gnome-shell/extensions/flypie@schneegans.github.com/schemas/gschemas.compiled”: open() failed: No such file or directory
        # If any extension produces this error, it can be added in if statement below to solve the problem
        # Fly-Pie or PaperWM
        if [[ "${UUID}" == "flypie@schneegans.github.com" || "${UUID}" == "paperwm@paperwm.github.com" ]]; then
          install -d -m 0755 "/usr/share/gnome-shell/extensions/${UUID}/schemas/"
          install -D -p -m 0644 "${TMP_DIR}/schemas/"*.gschema.xml "/usr/share/gnome-shell/extensions/${UUID}/schemas/"
          glib-compile-schemas "/usr/share/gnome-shell/extensions/${UUID}/schemas/" &>/dev/null
        else
          # Regular schema installation
          install -d -m 0755 "/usr/share/glib-2.0/schemas/"
          install -D -p -m 0644 "${TMP_DIR}/schemas/"*.gschema.xml "/usr/share/glib-2.0/schemas/"
        fi  
      fi  
      # Install languages
      # Locale is not crucial for extensions to work, as they will fallback to gschema.xml
      # Some of them might not have any locale at the moment
      # So that's why I made a check for directory
      # I made an additional check if language files are available, in case if extension is packaged with an empty folder, like with Default Workspace extension
      if [[ -d "${TMP_DIR}/locale/" ]]; then
          if find "${TMP_DIR}/locale/" -type f -name "*.mo" -print -quit | read; then
            echo "Installing language extension files"
            install -d -m 0755 "/usr/share/locale/"
            cp -r "${TMP_DIR}/locale"/* "/usr/share/locale/"
          fi  
      fi  
      # Delete the temporary directory
      echo "Cleaning up the temporary directory"
      rm -r "${TMP_DIR}"
      echo "Extension '${EXTENSION_NAME}' is successfully installed"
      echo "----------------------------------INSTALLATION DONE----------------------------------"
  done
fi

# New method of installing extensions
if [[ ${#INSTALL[@]} -gt 0 ]] && ! "${LEGACY}"; then
  for INSTALL_EXT in "${INSTALL[@]}"; do
      if [[ ! "${INSTALL_EXT}" =~ ^[0-9]+$ ]]; then
        # Literal-name extension config
        # Replaces whitespaces with %20 for install entries which contain extension name, since URLs can't contain whitespace      
        WHITESPACE_HTML="${INSTALL_EXT// /%20}"
        URL_QUERY=$(curl -sf "https://extensions.gnome.org/extension-query/?search=${WHITESPACE_HTML}")
        QUERIED_EXT=$(echo "${URL_QUERY}" | jq ".extensions[] | select(.name == \"${INSTALL_EXT}\")")
        if [[ -z "${QUERIED_EXT}" ]] || [[ "${QUERIED_EXT}" == "null" ]]; then
          echo "ERROR: Extension '${INSTALL_EXT}' does not exist in https://extensions.gnome.org/ website"
          echo "       Extension name is case-sensitive, so be sure that you typed it correctly,"
          echo "       including the correct uppercase & lowercase characters"
          exit 1
        fi
        readarray -t EXT_UUID < <(echo "${QUERIED_EXT}" | jq -r '.["uuid"]')
        readarray -t EXT_NAME < <(echo "${QUERIED_EXT}" | jq -r '.["name"]')
        if [[ ${#EXT_UUID[@]} -gt 1 ]] || [[ ${#EXT_NAME[@]} -gt 1 ]]; then
          echo "ERROR: Multiple compatible Gnome extensions with the same name are found, which this module cannot select"
          echo "       To solve this problem, please use PK ID as a module input entry instead of the extension name"
          echo "       You can get PK ID from the extension URL, like from Blur my Shell's 3193 PK ID example below:"
          echo "       https://extensions.gnome.org/extension/3193/blur-my-shell/"
          exit 1
        fi        
        # Gets suitable extension version for Gnome version from the image
        SUITABLE_VERSION=$(echo "${QUERIED_EXT}" | jq ".shell_version_map[\"${GNOME_VER}\"].version")
        if [[ -z "${SUITABLE_VERSION}" ]] || [[ "${SUITABLE_VERSION}" == "null" ]]; then
          echo "ERROR: Extension '${EXT_NAME}' is not compatible with Gnome v${GNOME_VER} in your image"
          exit 1
        fi
      else
        # PK ID extension config fallback if specified
        URL_QUERY=$(curl -sf "https://extensions.gnome.org/extension-info/?pk=${INSTALL_EXT}")
        PK_EXT=$(echo "${URL_QUERY}" | jq -r '.["pk"]' 2>/dev/null)
        if [[ -z "${PK_EXT}" ]] || [[ "${PK_EXT}" == "null" ]]; then
          echo "ERROR: Extension with PK ID '${INSTALL_EXT}' does not exist in https://extensions.gnome.org/ website"
          echo "       Please assure that you typed the PK ID correctly,"
          echo "       and that it exists in Gnome extensions website"
          exit 1
        fi
        EXT_UUID=$(echo "${URL_QUERY}" | jq -r '.["uuid"]')
        EXT_NAME=$(echo "${URL_QUERY}" | jq -r '.["name"]')
        SUITABLE_VERSION=$(echo "${URL_QUERY}" | jq ".shell_version_map[\"${GNOME_VER}\"].version")
        # Fail the build if extension is not compatible with the current Gnome version
        if [[ -z "${SUITABLE_VERSION}" ]] || [[ "${SUITABLE_VERSION}" == "null" ]]; then
          echo "ERROR: Extension '${EXT_NAME}' is not compatible with Gnome v${GNOME_VER} in your image"
          exit 1
        fi
      fi  
      # Removes every @ symbol from UUID, since extension URL doesn't contain @ symbol
      URL="https://extensions.gnome.org/extension-data/${EXT_UUID//@/}.v${SUITABLE_VERSION}.shell-extension.zip"
      TMP_DIR="/tmp/${EXT_UUID}"
      ARCHIVE=$(basename "${URL}")
      ARCHIVE_DIR="${TMP_DIR}/${ARCHIVE}"
      echo "Installing '${EXT_NAME}' Gnome extension with version ${SUITABLE_VERSION}"
      # Download archive
      echo "Downloading ZIP archive ${URL}"
      curl -fLs --create-dirs "${URL}" -o "${ARCHIVE_DIR}"
      echo "Downloaded ZIP archive ${URL}"
      # Extract archive
      echo "Extracting ZIP archive"
      unzip "${ARCHIVE_DIR}" -d "${TMP_DIR}" > /dev/null
      # Remove archive
      echo "Removing archive"
      rm "${ARCHIVE_DIR}"
      # Install main extension files
      echo "Installing main extension files"
      install -d -m 0755 "/usr/share/gnome-shell/extensions/${EXT_UUID}/"
      find "${TMP_DIR}" -mindepth 1 -maxdepth 1 ! -path "*locale*" ! -path "*schemas*" -exec cp -r {} "/usr/share/gnome-shell/extensions/${EXT_UUID}/" \;
      find "/usr/share/gnome-shell/extensions/${EXT_UUID}" -type d -exec chmod 0755 {} +
      find "/usr/share/gnome-shell/extensions/${EXT_UUID}" -type f -exec chmod 0644 {} +
      # Install schema
      if [[ -d "${TMP_DIR}/schemas" ]]; then
        echo "Installing schema extension file"
        # Workaround for extensions, which explicitly require compiled schema to be in extension UUID directory (rare scenario due to how extension is programmed in non-standard way)
        # Error code example:
        # GLib.FileError: Failed to open file “/usr/share/gnome-shell/extensions/flypie@schneegans.github.com/schemas/gschemas.compiled”: open() failed: No such file or directory
        # If any extension produces this error, it can be added in if statement below to solve the problem
        # Fly-Pie or PaperWM
        if [[ "${EXT_UUID}" == "flypie@schneegans.github.com" || "${EXT_UUID}" == "paperwm@paperwm.github.com" ]]; then
          install -d -m 0755 "/usr/share/gnome-shell/extensions/${EXT_UUID}/schemas/"
          install -D -p -m 0644 "${TMP_DIR}/schemas/"*.gschema.xml "/usr/share/gnome-shell/extensions/${EXT_UUID}/schemas/"
          glib-compile-schemas "/usr/share/gnome-shell/extensions/${EXT_UUID}/schemas/" &>/dev/null
        else
          # Regular schema installation
          install -d -m 0755 "/usr/share/glib-2.0/schemas/"
          install -D -p -m 0644 "${TMP_DIR}/schemas/"*.gschema.xml "/usr/share/glib-2.0/schemas/"
        fi  
      fi  
      # Install languages
      # Locale is not crucial for extensions to work, as they will fallback to gschema.xml
      # Some of them might not have any locale at the moment
      # So that's why I made a check for directory
      # I made an additional check if language files are available, in case if extension is packaged with an empty folder, like with Default Workspace extension
      if [[ -d "${TMP_DIR}/locale/" ]]; then
        if find "${TMP_DIR}/locale/" -type f -name "*.mo" -print -quit | read; then          
          echo "Installing language extension files"
          install -d -m 0755 "/usr/share/locale/"
          cp -r "${TMP_DIR}/locale"/* "/usr/share/locale/"
        fi
      fi  
      # Delete the temporary directory
      echo "Cleaning up the temporary directory"
      rm -r "${TMP_DIR}"
      echo "Extension '${EXT_NAME}' is successfully installed"
      echo "----------------------------------INSTALLATION DONE----------------------------------"
  done
fi

if [[ ${#UNINSTALL[@]} -gt 0 ]]; then
  for UNINSTALL_EXT in "${UNINSTALL[@]}"; do
      if [[ ! "${UNINSTALL_EXT}" =~ ^[0-9]+$ ]]; then
        # Literal-name extension config
        # Replaces whitespaces with %20 for install entries which contain extension name, since URLs can't contain whitespace
        # Getting json query from the website is useful to intuitively uninstall the extension without need to manually input UUID
        WHITESPACE_HTML="${UNINSTALL_EXT// /%20}"
        URL_QUERY=$(curl -sf "https://extensions.gnome.org/extension-query/?search=${WHITESPACE_HTML}")
        QUERIED_EXT=$(echo "${URL_QUERY}" | jq ".extensions[] | select(.name == \"${UNINSTALL_EXT}\")")
        if [[ -z "${QUERIED_EXT}" ]] || [[ "${QUERIED_EXT}" == "null" ]]; then
          echo "ERROR: Extension '${UNINSTALL_EXT}' does not exist in https://extensions.gnome.org/ website"
          echo "       Extension name is case-sensitive, so be sure that you typed it correctly,"
          echo "       including the correct uppercase & lowercase characters"
          exit 1
        fi
        EXT_UUID=$(echo "${QUERIED_EXT}" | jq -r '.["uuid"]')
        EXT_NAME=$(echo "${QUERIED_EXT}" | jq -r '.["name"]')
      else
        # PK ID extension config fallback if specified
        URL_QUERY=$(curl -sf "https://extensions.gnome.org/extension-info/?pk=${UNINSTALL_EXT}")
        PK_EXT=$(echo "${URL_QUERY}" | jq -r '.["pk"]' 2>/dev/null)
        if [[ -z "${PK_EXT}" ]] || [[ "${PK_EXT}" == "null" ]]; then
          echo "ERROR: Extension with PK ID '${UNINSTALL_EXT}' does not exist in https://extensions.gnome.org/ website"
          echo "       Please assure that you typed the PK ID correctly,"
          echo "       and that it exists in Gnome extensions website"
          exit 1
        fi
        EXT_UUID=$(echo "${URL_QUERY}" | jq -r '.["uuid"]')
        EXT_NAME=$(echo "${URL_QUERY}" | jq -r '.["name"]')
      fi
      # This is where uninstall step goes, above step is reused from install part
      EXT_FILES="/usr/share/gnome-shell/extensions/${EXT_UUID}"
      UNINSTALL_METADATA="${EXT_FILES}/metadata.json"
      GETTEXT_DOMAIN=$(jq -r '.["gettext-domain"]' < "${UNINSTALL_METADATA}")
      SETTINGS_SCHEMA=$(jq -r '.["settings-schema"]' < "${UNINSTALL_METADATA}")
      LANGUAGE_LOCATION="/usr/share/locale"
      # If settings-schema YAML key exists, than use that, if it doesn't
      # Than substract the schema ID before @ symbol
      if [[ ! "${SETTINGS_SCHEMA}" == "null" ]]; then
        SCHEMA_LOCATION="/usr/share/glib-2.0/schemas/${SETTINGS_SCHEMA}.gschema.xml"
      else
        SUBSTRACTED_UUID=$(echo "${EXT_UUID}" | cut -d'@' -f1)
        SCHEMA_LOCATION="/usr/share/glib-2.0/schemas/org.gnome.shell.extensions.${SUBSTRACTED_UUID}.gschema.xml"
      fi  
      # Remove languages
      if [[ ! "${GETTEXT_DOMAIN}" == "null" ]]; then
        find "${LANGUAGE_LOCATION}" -type f -name "${GETTEXT_DOMAIN}.mo" -exec rm {} \;
      else
        echo "There are no extension languages to remove, since extension doesn't contain them"
      fi
      # Remove gschema xml
      if [[ ! "${SETTINGS_SCHEMA}" == "null" ]] && [[ -f "${SCHEMA_LOCATION}" ]]; then
        rm "${SCHEMA_LOCATION}"
      else
        echo "There is no gschema xml to remove, since extension doesn't have any settings"
      fi
      # Removing main extension files
      if [[ -d "${EXT_FILES}" ]]; then
        echo "Removing main extension files"
        rm -r "${EXT_FILES}"
      else
        echo "ERROR: There are no main extension files to remove from the base image"
        echo "       It is possible that the extension that you inputted is not actually installed"
        exit 1
      fi
      echo "----------------------------------UNINSTALLATION DONE----------------------------------"
  done    
fi

# Compile gschema to include schemas from extensions  & to refresh schema state after uninstall is done
echo "Compiling gschema to include extension schemas & to refresh the schema state"
glib-compile-schemas "/usr/share/glib-2.0/schemas/" &>/dev/null

