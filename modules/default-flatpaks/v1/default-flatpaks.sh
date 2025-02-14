#!/usr/bin/env bash

# Tell build process to exit if there are any errors.
set -euo pipefail

MODULE_DIRECTORY="${MODULE_DIRECTORY:-"/tmp/modules"}"

cp -r "$MODULE_DIRECTORY"/default-flatpaks/system-flatpak-setup /usr/bin/system-flatpak-setup
cp -r "$MODULE_DIRECTORY"/default-flatpaks/user-flatpak-setup /usr/bin/user-flatpak-setup
cp -r "$MODULE_DIRECTORY"/default-flatpaks/system-flatpak-setup.service /usr/lib/systemd/system/system-flatpak-setup.service
cp -r "$MODULE_DIRECTORY"/default-flatpaks/user-flatpak-setup.service /usr/lib/systemd/user/user-flatpak-setup.service
cp -r "$MODULE_DIRECTORY"/default-flatpaks/system-flatpak-setup.timer /usr/lib/systemd/system/system-flatpak-setup.timer
cp -r "$MODULE_DIRECTORY"/default-flatpaks/user-flatpak-setup.timer /usr/lib/systemd/user/user-flatpak-setup.timer


configure_flatpak_repo () {
    CONFIG_FILE=$1
    INSTALL_LEVEL=$2
    REPO_INFO="/usr/share/bluebuild/default-flatpaks/$INSTALL_LEVEL/repo-info.json"
    get_json_array INSTALL "try .$INSTALL_LEVEL.install[]" "$CONFIG_FILE"


    # Checks pre-configured repo info, if exists
    if [[ -f $REPO_INFO ]]; then
        echo "Existing $INSTALL_LEVEL configuration found:"
        cat $REPO_INFO
        CONFIG_URL=$(jq -r 'try .["repo-url"]' "$REPO_INFO")
        CONFIG_NAME=$(jq -r 'try .["repo-name"]' "$REPO_INFO")
        CONFIG_TITLE=$(jq -r 'try .["repo-title"]' "$REPO_INFO")
    else
        CONFIG_URL="null"
        CONFIG_NAME="null"
        CONFIG_TITLE="null"
    fi

    echo "Configuring $INSTALL_LEVEL repo in $REPO_INFO"
    REPO_URL=$(echo "$CONFIG_FILE" | jq -r --arg INSTALL_LEVEL "$INSTALL_LEVEL" 'try getpath([$INSTALL_LEVEL, "repo-url"])')
    REPO_NAME=$(echo "$CONFIG_FILE" | jq -r --arg INSTALL_LEVEL "$INSTALL_LEVEL" 'try getpath([$INSTALL_LEVEL, "repo-name"])')
    REPO_TITLE=$(echo "$CONFIG_FILE" | jq -r --arg INSTALL_LEVEL "$INSTALL_LEVEL" 'try getpath([$INSTALL_LEVEL, "repo-title"])')

    # If repo-name isn't configured, use flathub as fallback
    # Checked separately from URL to allow custom naming
    if [[ $REPO_NAME == "null" && $CONFIG_NAME == "null" ]]; then
        if [[ ${#INSTALL[@]} -gt 0 ]]; then
            REPO_NAME="flathub"
        fi
    # Re-use existing config, if no new configuration was added
    elif [[ $REPO_NAME == "null" && ! $CONFIG_NAME == "null" ]]; then
        REPO_NAME=$CONFIG_NAME
    fi

    # Re-use existing config, if no new configuration was added
    if [[ $REPO_TITLE == "null" && ! $CONFIG_TITLE == "null" ]]; then
        REPO_TITLE=$CONFIG_TITLE
    fi

    if [[ $REPO_URL == "null" && $CONFIG_URL == "null" ]]; then
        # If repo name is configured, or if there are Flatpaks to be installed,
        # set Flathub as repo URL
        if [[ ! $REPO_NAME == "null" || ${#INSTALL[@]} -gt 0 ]]; then
            REPO_URL=https://dl.flathub.org/repo/flathub.flatpakrepo
        fi
    # Re-use existing config, if no new configuration was added
    elif [[ $REPO_URL == "null" && ! $CONFIG_URL == "null" ]]; then
        REPO_URL=$CONFIG_URL
    fi

    touch $REPO_INFO
    # EOF breaks if the contents are indented,
    # so the below lines are intentionally un-indented
cat > $REPO_INFO <<EOF
{
    "repo-url": "$REPO_URL",
    "repo-name": "$REPO_NAME",
    "repo-title": "$REPO_TITLE"
}
EOF

    # Show results of repo configuration
    cat $REPO_INFO
}

configure_lists () {
    CONFIG_FILE=$1
    INSTALL_LEVEL=$2
    INSTALL_LIST="/usr/share/bluebuild/default-flatpaks/$INSTALL_LEVEL/install"
    REMOVE_LIST="/usr/share/bluebuild/default-flatpaks/$INSTALL_LEVEL/remove"
    get_json_array INSTALL "try .$INSTALL_LEVEL.install[]" "$CONFIG_FILE"
    get_json_array REMOVE "try .$INSTALL_LEVEL.remove[]" "$CONFIG_FILE"

    echo "Creating $INSTALL_LEVEL Flatpak install list at $INSTALL_LIST"
    if [[ ${#INSTALL[@]} -gt 0 ]]; then
        for flatpak in "${INSTALL[@]}"; do
            echo "Adding to $INSTALL_LEVEL flatpak installs: $(printf ${flatpak})"
            echo $flatpak >> $INSTALL_LIST
        done
    fi

    echo "Creating $INSTALL_LEVEL Flatpak removals list $REMOVE_LIST"
    if [[ ${#REMOVE[@]} -gt 0 ]]; then
        for flatpak in "${REMOVE[@]}"; do
            echo "Adding to $INSTALL_LEVEL flatpak removals: $(printf ${flatpak})"
            echo $flatpak >> $REMOVE_LIST
        done
    fi
}

check_flatpak_id_validity_from_flathub () {
      if [[ -f "/usr/share/bluebuild/default-flatpaks/system/repo-info.json" ]]; then
        SYSTEM_FLATHUB_REPO=$(jq -r 'try .["repo-url"]' "/usr/share/bluebuild/default-flatpaks/system/repo-info.json")
      else
        SYSTEM_FLATHUB_REPO=""
      fi  
      if [[ -f "/usr/share/bluebuild/default-flatpaks/user/repo-info.json" ]]; then
        USER_FLATHUB_REPO=$(jq -r 'try .["repo-url"]' "/usr/share/bluebuild/default-flatpaks/user/repo-info.json")
      else
        USER_FLATHUB_REPO=""
      fi  
      FLATHUB_REPO_LINK="https://dl.flathub.org/repo/flathub.flatpakrepo"
      URL="https://flathub.org/api/v2/stats"
      CONFIG_FILE="${1}"
      INSTALL_LEVEL="${2}"
      get_json_array INSTALL "try .$INSTALL_LEVEL.install[]" "${CONFIG_FILE}"
      get_json_array REMOVE "try .$INSTALL_LEVEL.remove[]" "${CONFIG_FILE}"
      if [[ "${SYSTEM_FLATHUB_REPO}" == "${FLATHUB_REPO_LINK}" ]] || [[ "${USER_FLATHUB_REPO}" == "${FLATHUB_REPO_LINK}" ]]; then
        if [[ ${#INSTALL[@]} -gt 0 ]] || [[ ${#REMOVE[@]} -gt 0 ]]; then
          echo "Safe-checking if ${INSTALL_LEVEL} flatpak IDs are typed correctly. If test fails, build also fails"
        fi  
        if [[ ${#INSTALL[@]} -gt 0 ]]; then
          for id in "${INSTALL[@]}"; do
            if ! curl --output /dev/null --silent --head --fail "${URL}/${id}"; then
              echo "ERROR: This ${INSTALL_LEVEL} install flatpak ID '${id}' doesn't exist in FlatHub repo, please check if you typed it correctly in the recipe."
              exit 1
            fi
          done
        fi
        if [[ ${#REMOVE[@]} -gt 0 ]]; then  
          for id in "${REMOVE[@]}"; do
            if ! curl --output /dev/null --silent --head --fail "${URL}/${id}"; then
              echo "ERROR: This ${INSTALL_LEVEL} removal flatpak ID '${id}' doesn't exist in FlatHub repo, please check if you typed it correctly in the recipe."
              exit 1
            fi
          done
        fi  
      else
        if ! ${MESSAGE_DISPLAYED}; then
          echo "NOTE: Flatpak ID safe-check is only available for FlatHub repo"
          MESSAGE_DISPLAYED=true
        fi  
      fi  
}

echo "Enabling flatpaks module"
mkdir -p /usr/share/bluebuild/default-flatpaks/{system,user}
mkdir -p /etc/bluebuild/default-flatpaks/{system,user}
systemctl enable -f system-flatpak-setup.timer
systemctl enable -f --global user-flatpak-setup.timer

# Check that `system` is present before configuring. Also copy template list files before writing Flatpak IDs.
if [[ $(echo "$1" | jq -r 'try .["system"]') != "null" ]]; then
    configure_flatpak_repo "$1" "system"
    if [ ! -f "/usr/share/bluebuild/default-flatpaks/system/install" ]; then
      cp -r "$MODULE_DIRECTORY"/default-flatpaks/config/system/install /usr/share/bluebuild/default-flatpaks/system/install
    fi
    if [ ! -f "/usr/share/bluebuild/default-flatpaks/system/remove" ]; then  
      cp -r "$MODULE_DIRECTORY"/default-flatpaks/config/system/remove /usr/share/bluebuild/default-flatpaks/system/remove
    fi  
    configure_lists "$1" "system"
fi

# Check that `user` is present before configuring. Also copy template list files before writing Flatpak IDs.
if [[ $(echo "$1" | jq -r 'try .["user"]') != "null" ]]; then
    configure_flatpak_repo "$1" "user"
    if [ ! -f "/usr/share/bluebuild/default-flatpaks/user/install" ]; then
      cp -r "$MODULE_DIRECTORY"/default-flatpaks/config/user/install /usr/share/bluebuild/default-flatpaks/user/install
    fi
    if [ ! -f "/usr/share/bluebuild/default-flatpaks/user/remove" ]; then
      cp -r "$MODULE_DIRECTORY"/default-flatpaks/config/user/remove /usr/share/bluebuild/default-flatpaks/user/remove
    fi
    configure_lists "$1" "user"
fi

MESSAGE_DISPLAYED=false
check_flatpak_id_validity_from_flathub "${1}" "system"
check_flatpak_id_validity_from_flathub "${1}" "user"

echo "Configuring default-flatpaks notifications"
NOTIFICATIONS=$(echo "$1" | jq -r 'try .["notify"]')
CONFIG_NOTIFICATIONS="/usr/share/bluebuild/default-flatpaks/notifications"
cp -r "${MODULE_DIRECTORY}/default-flatpaks/config/notifications" "${CONFIG_NOTIFICATIONS}"
if [[ -z "${NOTIFICATIONS}" ]] || [[ "${NOTIFICATIONS}" == "null" ]]; then
  echo "false" >> "${CONFIG_NOTIFICATIONS}"
else
  echo "${NOTIFICATIONS}" >> "${CONFIG_NOTIFICATIONS}"
fi

echo "Copying user modification template files"

cp -r "$MODULE_DIRECTORY"/default-flatpaks/user-config/system/install /etc/bluebuild/default-flatpaks/system/install
cp -r "$MODULE_DIRECTORY"/default-flatpaks/user-config/system/remove /etc/bluebuild/default-flatpaks/system/remove
cp -r "$MODULE_DIRECTORY"/default-flatpaks/user-config/user/install /etc/bluebuild/default-flatpaks/user/install
cp -r "$MODULE_DIRECTORY"/default-flatpaks/user-config/user/remove /etc/bluebuild/default-flatpaks/user/remove
cp -r "$MODULE_DIRECTORY"/default-flatpaks/user-config/notifications /etc/bluebuild/default-flatpaks/notifications
