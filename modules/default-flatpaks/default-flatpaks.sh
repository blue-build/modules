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
        touch $INSTALL_LIST
        for flatpak in "${INSTALL[@]}"; do
            echo "Adding to $INSTALL_LEVEL flatpak installs: $(printf ${flatpak})"
            echo $flatpak >> $INSTALL_LIST
        done
    fi

    echo "Creating $INSTALL_LEVEL Flatpak removals list $REMOVE_LIST"
    if [[ ${#REMOVE[@]} -gt 0 ]]; then
        touch $REMOVE_LIST
        for flatpak in "${REMOVE[@]}"; do
            echo "Adding to $INSTALL_LEVEL flatpak removals: $(printf ${flatpak})"
            echo $flatpak >> $REMOVE_LIST
        done
    fi
}

echo "Enabling flatpaks module"
mkdir -p /usr/share/bluebuild/default-flatpaks/{system,user}
systemctl enable -f system-flatpak-setup.service
systemctl enable -f --global user-flatpak-setup.service

# Check that `system` is present before configuring. Also document list files with additional information.
if [[ ! $(echo "$1" | yq -I=0 ".system") == "null" ]]; then
    configure_flatpak_repo "$1" "system"
    system_install_list_doc="/usr/share/bluebuild/default-flatpaks/system/install"
    system_remove_list_doc="/usr/share/bluebuild/default-flatpaks/system/remove"
    echo -e "# This file utilizes maintainer's configuration for \`system flatpaks install\` used by \`default-flatpaks\` BlueBuild module.
# Flatpak ID format is used for inserting desired \`system flatpaks install\` entry.\n" > "$system_install_list_doc"
    echo -e "# This file utilizes maintainer's configuration for \`system flatpaks removal\` used by \`default-flatpaks\` BlueBuild module.
# Flatpak ID format is used for inserting desired \`system flatpaks removal\` entry.\n" > "$system_remove_list_doc"
    configure_lists "$1" "system"
fi

# Check that `user` is present before configuring. Also document list files with additional information.
if [[ ! $(echo "$1" | yq -I=0 ".user") == "null" ]]; then
    configure_flatpak_repo "$1" "user"
    user_install_list_doc="/usr/share/bluebuild/default-flatpaks/user/install"
    user_remove_list_doc="/usr/share/bluebuild/default-flatpaks/user/remove"
    echo -e "# This file utilizes maintainer's configuration for \`user flatpaks install\` used by \`default-flatpaks\` BlueBuild module.
# Flatpak ID format is used for inserting desired \`user flatpaks install\` entry.\n" > "$user_install_list_doc"
    echo -e "# This file utilizes maintainer's configuration for \`user flatpaks removal\` used by \`default-flatpaks\` BlueBuild module.
# Flatpak ID format is used for inserting desired \`user flatpaks removal\` entry.\n" > "$user_remove_list_doc"    
    configure_lists "$1" "user"
fi

echo "Configuring default-flatpaks notifications"
NOTIFICATIONS=$(echo "$1" | yq -I=0 ".notify")
NOTIFICATIONS_CONFIG_FILE="/usr/share/bluebuild/default-flatpaks/notifications"
echo -e "# This file utilizes maintainer's configuration for \`notifications\` used by \`default-flatpaks\` BlueBuild module.
# Possible values: true, false\n" > "$NOTIFICATIONS_CONFIG_FILE"
echo "$NOTIFICATIONS" >> "$NOTIFICATIONS_CONFIG_FILE"

echo "Writing live-user modification files"

mkdir -p /usr/etc/bluebuild/default-flatpaks/system
mkdir -p /usr/etc/bluebuild/default-flatpaks/user

USER_INSTALL_SYSTEM_LIST="/usr/etc/bluebuild/default-flatpaks/system/install"
echo "# This file utilizes user's configuration for \`system flatpaks install\` used by \`default-flatpaks\` BlueBuild module.
# If this file is not modified, maintainer's configuration will be used instead (located in /usr/share/bluebuild/default-flatpaks/system/install).
# Specify the ID of \`system flatpaks\` in the list you want to install.
# Duplicated entries won't be used if located in maintainer's configuration.
# Flatpak runtimes are not supported.
# Here's an example on how to edit this file (ignore # symbol):
#
# org.gnome.Maps
# org.gnome.TextEditor
# org.telegram.desktop" > "$USER_INSTALL_SYSTEM_LIST"

USER_REMOVE_SYSTEM_LIST="/usr/etc/bluebuild/default-flatpaks/system/remove"
echo "# This file utilizes user's configuration for \`system flatpaks removal\` used by \`default-flatpaks\` BlueBuild module.
# If this file is not modified, maintainer's configuration will be used instead (located in /usr/share/bluebuild/default-flatpaks/system/remove).
# Specify the ID of \`system flatpaks\` in the list you want to remove.
# Duplicated entries won't be used if located in maintainer's configuration.
# Flatpak runtimes are not supported.
# Here's an example on how to edit this file (ignore # symbol):
#
# org.gnome.Maps
# org.gnome.TextEditor
# org.telegram.desktop" > "$USER_REMOVE_SYSTEM_LIST"

USER_INSTALL_USER_LIST="/usr/etc/bluebuild/default-flatpaks/user/install"
echo "# This file utilizes user's configuration for \`user flatpaks install\` used by \`default-flatpaks\` BlueBuild module.
# If this file is not modified, maintainer's configuration will be used instead (located in /usr/share/bluebuild/default-flatpaks/user/install).
# Specify the ID of \`user flatpaks\` in the list you want to install.
# Duplicated entries won't be used if located in maintainer's configuration.
# Flatpak runtimes are not supported.
# Here's an example on how to edit this file (ignore # symbol):
#
# org.gnome.Maps
# org.gnome.TextEditor
# org.telegram.desktop" > "$USER_INSTALL_USER_LIST"

USER_REMOVE_USER_LIST="/usr/etc/bluebuild/default-flatpaks/user/remove"
echo "# This file utilizes user's configuration for \`user flatpaks removal\` used by \`default-flatpaks\` BlueBuild module.
# If this file is not modified, maintainer's configuration will be used instead (located in /usr/share/bluebuild/default-flatpaks/user/remove).
# Specify the ID of \`user flatpaks\` in the list you want to remove.
# Duplicated entries won't be used if located in maintainer's configuration.
# Flatpak runtimes are not supported.
# Here's an example on how to edit this file (ignore # symbol):
#
# org.gnome.Maps
# org.gnome.TextEditor
# org.telegram.desktop" > "$USER_REMOVE_USER_LIST"

USER_NOTIFICATIONS_CONFIG_FILE="/usr/etc/bluebuild/default-flatpaks/notifications"
echo "# This file utilizes user's configuration for \`notifications\` used by \`default-flatpaks\` BlueBuild module.
# If this file is not modified, maintainer's configuration will be used instead (located in /usr/share/bluebuild/default-flatpaks/notifications).
# Possible values: true, false
# Here's an example on how to edit this file (ignore # symbol):
#
# false" > "$USER_NOTIFICATIONS_CONFIG_FILE"
