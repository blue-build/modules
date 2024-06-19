#!/usr/bin/env bash

# Tell build process to exit if there are any errors.
set -euo pipefail

MODULE_DIRECTORY="${MODULE_DIRECTORY:-"/tmp/modules"}"

cp -r "$MODULE_DIRECTORY"/default-flatpaks/system-flatpak-setup /usr/bin/system-flatpak-setup
cp -r "$MODULE_DIRECTORY"/default-flatpaks/user-flatpak-setup /usr/bin/user-flatpak-setup
cp -r "$MODULE_DIRECTORY"/default-flatpaks/system-flatpak-setup.service /usr/lib/systemd/system/system-flatpak-setup.service
cp -r "$MODULE_DIRECTORY"/default-flatpaks/user-flatpak-setup.service /usr/lib/systemd/user/user-flatpak-setup.service

configure_flatpak_repo () {
    CONFIG_FILE=$1
    INSTALL_LEVEL=$2
    REPO_INFO="/usr/share/bluebuild/default-flatpaks/$INSTALL_LEVEL/repo-info.yml"
    get_yaml_array INSTALL ".$INSTALL_LEVEL.install[]" "$CONFIG_FILE"


    # Checks pre-configured repo info, if exists
    if [[ -f $REPO_INFO ]]; then
        echo "Existing $INSTALL_LEVEL configuration found:"
        cat $REPO_INFO
        CONFIG_URL=$(yq ".repo-url" "$REPO_INFO")
        CONFIG_NAME=$(yq ".repo-name" "$REPO_INFO")
        CONFIG_TITLE=$(yq ".repo-title" "$REPO_INFO")
    else
        CONFIG_URL="null"
        CONFIG_NAME="null"
        CONFIG_TITLE="null"
    fi

    echo "Configuring $INSTALL_LEVEL repo in $REPO_INFO"
    REPO_URL=$(echo "$CONFIG_FILE" | yq -I=0 ".$INSTALL_LEVEL.repo-url")
    REPO_NAME=$(echo "$CONFIG_FILE" | yq -I=0 ".$INSTALL_LEVEL.repo-name")
    REPO_TITLE=$(echo "$CONFIG_FILE" | yq -I=0 ".$INSTALL_LEVEL.repo-title")

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
repo-url: "$REPO_URL"
repo-name: "$REPO_NAME"
repo-title: "$REPO_TITLE"
EOF

    # Show results of repo configuration
    cat $REPO_INFO
}

configure_lists () {
    CONFIG_FILE=$1
    INSTALL_LEVEL=$2
    INSTALL_LIST="/usr/share/bluebuild/default-flatpaks/$INSTALL_LEVEL/install"
    REMOVE_LIST="/usr/share/bluebuild/default-flatpaks/$INSTALL_LEVEL/remove"
    get_yaml_array INSTALL ".$INSTALL_LEVEL.install[]" "$CONFIG_FILE"
    get_yaml_array REMOVE ".$INSTALL_LEVEL.remove[]" "$CONFIG_FILE"

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

echo "Enabling flatpaks module"
mkdir -p /usr/share/bluebuild/default-flatpaks/{system,user}
mkdir -p /usr/etc/bluebuild/default-flatpaks/{system,user}
systemctl enable -f system-flatpak-setup.service
systemctl enable -f --global user-flatpak-setup.service

# Check that `system` is present before configuring. Also copy template list files before writing Flatpak IDs.
if [[ ! $(echo "$1" | yq -I=0 ".system") == "null" ]]; then
    configure_flatpak_repo "$1" "system"
    if [ ! -f "/usr/share/bluebuild/default-flatpaks/system/install" ]; then
      cp -r "$MODULE_DIRECTORY"/default-flatpaks/config/system/install /usr/share/bluebuild/default-flatpaks/system/install
    elif [ ! -f "/usr/share/bluebuild/default-flatpaks/system/remove" ]; then  
      cp -r "$MODULE_DIRECTORY"/default-flatpaks/config/system/remove /usr/share/bluebuild/default-flatpaks/system/remove
    fi  
    configure_lists "$1" "system"
fi

# Check that `user` is present before configuring. Also copy template list files before writing Flatpak IDs.
if [[ ! $(echo "$1" | yq -I=0 ".user") == "null" ]]; then
    configure_flatpak_repo "$1" "user"
    if [ ! -f "/usr/share/bluebuild/default-flatpaks/user/install" ]; then
      cp -r "$MODULE_DIRECTORY"/default-flatpaks/config/user/install /usr/share/bluebuild/default-flatpaks/user/install
    elif [ ! -f "/usr/share/bluebuild/default-flatpaks/user/remove" ]; then
      cp -r "$MODULE_DIRECTORY"/default-flatpaks/config/user/remove /usr/share/bluebuild/default-flatpaks/user/remove
    fi
    configure_lists "$1" "user"
fi

echo "Configuring default-flatpaks notifications"
NOTIFICATIONS=$(echo "$1" | yq -I=0 ".notify")
CONFIG_NOTIFICATIONS="/usr/share/bluebuild/default-flatpaks/notifications"
cp -r "$MODULE_DIRECTORY"/default-flatpaks/config/notifications "$CONFIG_NOTIFICATIONS"
echo "$NOTIFICATIONS" >> "$CONFIG_NOTIFICATIONS"

echo "Copying user modification template files"

cp -r "$MODULE_DIRECTORY"/default-flatpaks/user-config/system/install /usr/etc/bluebuild/default-flatpaks/system/install
cp -r "$MODULE_DIRECTORY"/default-flatpaks/user-config/system/remove /usr/etc/bluebuild/default-flatpaks/system/remove
cp -r "$MODULE_DIRECTORY"/default-flatpaks/user-config/user/install /usr/etc/bluebuild/default-flatpaks/user/install
cp -r "$MODULE_DIRECTORY"/default-flatpaks/user-config/user/remove /usr/etc/bluebuild/default-flatpaks/user/remove
cp -r "$MODULE_DIRECTORY"/default-flatpaks/user-config/notifications /usr/etc/bluebuild/default-flatpaks/notifications
