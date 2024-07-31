#!/usr/bin/env bash

# Tell build process to exit if there are any errors.
set -euo pipefail

# Pull in repos
get_yaml_array REPOS '.repos[]' "$1"
if [[ ${#REPOS[@]} -gt 0 ]]; then
    echo "Adding repositories"
    for REPO in "${REPOS[@]}"; do
    REPO="${REPO//%OS_VERSION%/${OS_VERSION}}"
        if [[ "${REPO}" =~ ^https?:\/\/.* ]]; then
          curl --output-dir "/etc/yum.repos.d/" -O "${REPO//[$'\t\r\n ']}"
        elif [[ ! "${REPO}" =~ ^https?:\/\/.* ]] && [[ "${REPO}" == *".repo" ]] && [[ -f "${CONFIG_DIRECTORY}/rpm-ostree/${REPO}" ]]; then
          cp "${CONFIG_DIRECTORY}/rpm-ostree/${REPO}" "/etc/yum.repos.d/${REPO##*/}"
        fi  
    done
fi

get_yaml_array KEYS '.keys[]' "$1" 
if [[ ${#KEYS[@]} -gt 0 ]]; then
    echo "Adding keys"
    for KEY in "${KEYS[@]}"; do
        KEY="${KEY//%OS_VERSION%/${OS_VERSION}}"
        rpm --import "${KEY//[$'\t\r\n ']}"
    done
fi

# Create symlinks to fix packages that create directories in /opt
get_yaml_array OPTFIX '.optfix[]' "$1"
if [[ ${#OPTFIX[@]} -gt 0 ]]; then
    echo "Creating symlinks to fix packages that install to /opt"
    # Create symlink for /opt to /var/opt since it is not created in the image yet
    mkdir -p "/var/opt"
    ln -s "/var/opt"  "/opt"
    # Create symlinks for each directory specified in recipe.yml
    for OPTPKG in "${OPTFIX[@]}"; do
        OPTPKG="${OPTPKG%\"}"
        OPTPKG="${OPTPKG#\"}"
        OPTPKG=$(printf "$OPTPKG")
        mkdir -p "/usr/lib/opt/${OPTPKG}"
        ln -s "../../usr/lib/opt/${OPTPKG}" "/var/opt/${OPTPKG}"
        echo "Created symlinks for ${OPTPKG}"
    done
fi

get_yaml_array INSTALL '.install[]' "$1"
get_yaml_array REMOVE '.remove[]' "$1"

# Install and remove RPM packages
# Sort classic, URL & local packages
if [[ ${#INSTALL[@]} -gt 0 ]]; then
    for PKG in "${INSTALL[@]}"; do
    if [[ "$PKG" =~ ^https?:\/\/.* ]]; then
      VERSION_SUBSTITUTED_PKG="${PKG//%OS_VERSION%/${OS_VERSION}}"    
      HTTPS_INSTALL=true
      HTTPS_PKG+=("${VERSION_SUBSTITUTED_PKG}")
    elif [[ ! "$PKG" =~ ^https?:\/\/.* ]] && [[ -f "${CONFIG_DIRECTORY}/rpm-ostree/${PKG}" ]]; then
      LOCAL_INSTALL=true
      LOCAL_PKG+=("${PKG}")
    else
      CLASSIC_INSTALL=true
      CLASSIC_PKG+=("${PKG}")
    fi
done

# The installation is done with some wordsplitting hacks
# because of errors when doing array destructuring at the installation step.
# This is different from other ublue projects and could be investigated further.
INSTALL_STR=$(echo "${INSTALL[*]}" | tr -d '\n')
REMOVE_STR=$(echo "${REMOVE[*]}" | tr -d '\n')

echo_rpm_install() {
    if ${CLASSIC_INSTALL} && ! ${HTTPS_INSTALL} && ! ${LOCAL_INSTALL}; then
      echo "Installing: ${CLASSIC_PKG[*]}"
    elif ! ${CLASSIC_INSTALL} && ${HTTPS_INSTALL} && ! ${LOCAL_INSTALL}; then
      echo "Installing package(s) directly from URL: ${HTTPS_PKG[*]}"
    elif ! ${CLASSIC_INSTALL} && ! ${HTTPS_INSTALL} && ${LOCAL_INSTALL}; then
      echo "Installing local package(s): ${LOCAL_PKG[*]}"
    elif ${CLASSIC_INSTALL} && ${HTTPS_INSTALL} && ! ${LOCAL_INSTALL}; then
      echo "Installing: ${CLASSIC_PKG[*]}"
      echo "Installing package(s) directly from URL: ${HTTPS_PKG[*]}"
    elif ${CLASSIC_INSTALL} && ! ${HTTPS_INSTALL} && ${LOCAL_INSTALL}; then
      echo "Installing: ${CLASSIC_PKG[*]}"
      echo "Installing local package(s): ${LOCAL_PKG[*]}"
    elif ! ${CLASSIC_INSTALL} && ${HTTPS_INSTALL} && ${LOCAL_INSTALL}; then
      echo "Installing package(s) directly from URL: ${HTTPS_PKG[*]}"    
      echo "Installing local package(s): ${LOCAL_PKG[*]}"
    elif ${CLASSIC_INSTALL} && ${HTTPS_INSTALL} && ${LOCAL_INSTALL}; then
      echo "Installing: ${CLASSIC_PKG[*]}"
      echo "Installing package(s) directly from URL: ${HTTPS_PKG[*]}"
      echo "Installing local package(s): ${LOCAL_PKG[*]}"
    fi
}

if [[ ${#INSTALL[@]} -gt 0 && ${#REMOVE[@]} -gt 0 ]]; then
    echo "Installing & Removing RPMs"
    echo_rpm_install
    echo "Removing: ${REMOVE_STR[*]}"
    # Doing both actions in one command allows for replacing required packages with alternatives
    rpm-ostree override remove $REMOVE_STR $(printf -- "--install=%s " $INSTALL_STR)
elif [[ ${#INSTALL[@]} -gt 0 ]]; then
    echo "Installing RPMs"
    echo_rpm_install
    rpm-ostree install $INSTALL_STR
elif [[ ${#REMOVE[@]} -gt 0 ]]; then
    echo "Removing RPMs"
    echo "Removing: ${REMOVE_STR[*]}"
    rpm-ostree override remove $REMOVE_STR
fi

get_yaml_array REPLACE '.replace[]' "$1"

# Override-replace RPM packages
if [[ ${#REPLACE[@]} -gt 0 ]]; then
    for REPLACEMENT in "${REPLACE[@]}"; do

        # Get repository
        REPO=$(echo "${REPLACEMENT}" | yq -I=0 ".from-repo")
        REPO="${REPO//%OS_VERSION%/${OS_VERSION}}"

        # Ensure repository is provided
        if [[ "${REPO}" == "null" ]]; then
            echo "Error: Key 'from-repo' was declared, but repository URL was not provided."
            exit 1
        fi

        # Get info from repository URL
        MAINTAINER=$(awk -F'/' '{print $5}' <<< "${REPO}")
        REPO_NAME=$(awk -F'/' '{print $6}' <<< "${REPO}")
        FILE_NAME=$(awk -F'/' '{print $9}' <<< "${REPO}")

        # Get packages to replace
        get_yaml_array PACKAGES '.packages[]' "${REPLACEMENT}"
        REPLACE_STR="$(echo "${PACKAGES[*]}" | tr -d '\n')"

        # Ensure packages are provided
        if [[ ${#PACKAGES[@]} == 0 ]]; then
            echo "Error: No packages were provided for repository '${REPO_NAME}'."
            exit 1
        fi

        echo "Replacing packages from COPR repository: '${REPO_NAME}' owned by '${MAINTAINER}'"
        echo "Replacing: ${REPLACE_STR}"

        curl --output-dir "/etc/yum.repos.d/" -O "${REPO//[$'\t\r\n ']}"
        rpm-ostree override replace --experimental --from repo=copr:copr.fedorainfracloud.org:${MAINTAINER}:${REPO_NAME} ${REPLACE_STR}
        rm "/etc/yum.repos.d/${FILE_NAME}"

    done
fi
