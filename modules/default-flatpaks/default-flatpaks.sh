#!/usr/bin/env bash

# Tell build process to exit if there are any errors.
set -oue pipefail

cp -r "$BLING_DIRECTORY"/files/usr/bin/system-flatpak-setup /usr/bin/system-flatpak-setup
cp -r "$BLING_DIRECTORY"/files/usr/bin/user-flatpak-setup /usr/bin/user-flatpak-setup
cp -r "$BLING_DIRECTORY"/files/usr/lib/systemd/system/system-flatpak-setup.service /usr/lib/systemd/system/system-flatpak-setup.service
cp -r "$BLING_DIRECTORY"/files/usr/lib/systemd/user/user-flatpak-setup.service /usr/lib/systemd/user/user-flatpak-setup.service

echo "Enabling flatpaks module"
systemctl enable system-flatpak-setup.service
systemctl enable --global user-flatpak-setup.service
mkdir -p /usr/etc/flatpak/{system,user}

# $1, $repo_location
configure_flatpak_repo () {
    repo_info="/usr/etc/flatpak/$2/repo-info.yml"
    # If repo_info already exists, don't re-create it
    if [[ ! -f $repo_info ]]; then
        echo "Configuring $2 repo in $repo_info"
        repo_url=$(echo "$1" | yq -I=0 ".$2.repo-url")
        repo_name=$(echo "$1" | yq -I=0 ".$2.repo-name")
        repo_title=$(echo "$1" | yq -I=0 ".$2.repo-title")

        touch $repo_info
        # EOF breaks if the contents are indented,
        # so the below lines are intentionally un-indented
        cat > $repo_info <<EOF
repo-url: "$repo_url"
repo-name: "$repo_name"
repo-title: "$repo_title"
EOF
    fi
}

# $1, $repo_location
configure_lists () {
    install_list="/usr/etc/flatpak/$2/install"
    remove_list="/usr/etc/flatpak/$2/remove"
    get_yaml_array INSTALL ".$2.install[]" "$1"
    get_yaml_array REMOVE ".$2.remove[]" "$1"

    echo "Creating $2 Flatpak install list at $install_list"
    if [[ ${#INSTALL[@]} -gt 0 ]]; then
        touch $install_list
        for flatpak in "${INSTALL[@]}"; do
            echo "Adding to $2 flatpak installs: $(printf ${flatpak})"
            echo $flatpak >> $install_list
        done
    fi

    echo "Creating $2 Flatpak removals list $remove_list"
    if [[ ${#REMOVE[@]} -gt 0 ]]; then
        touch $remove_list
        for flatpak in "${REMOVE[@]}"; do
            echo "Adding to $2 flatpak removals: $(printf ${flatpak})"
            echo $flatpak >> $remove_list
        done
    fi
}

configure_flatpak_repo "$1" "system"
configure_flatpak_repo "$1" "user"

configure_lists "$1" "system"
configure_lists "$1" "user"
