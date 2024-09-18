#!/usr/bin/env bash

# Tell build process to exit if there are any errors.
set -euo pipefail

# Pull in repos
get_yaml_array REPOS '.repos[]' "$1"
if [[ ${#REPOS[@]} -gt 0 ]]; then
    echo "Adding repositories"
    for REPO in "${REPOS[@]}"; do
    REPO="${REPO//%OS_VERSION%/${OS_VERSION}}"
        # If it's the COPR repo, then download the repo normally
        # If it's not, then download the repo with URL in it's filename, to avoid duplicate repo name issue
        if [[ "${REPO}" =~ ^https?:\/\/.* ]] && [[ "${REPO}" == "https://copr.fedorainfracloud.org/coprs/"* ]]; then
          REPO_URL="${REPO//[$'\t\r\n ']}"

          echo "Downloading repo file ${REPO_URL}"
          curl -fLs --create-dirs -O "${REPO_URL}" --output-dir "/etc/yum.repos.d/"
          echo "Downloaded repo file ${REPO_URL}"
        elif [[ "${REPO}" =~ ^https?:\/\/.* ]] && [[ "${REPO}" != "https://copr.fedorainfracloud.org/coprs/"* ]]; then
          REPO_URL="${REPO//[$'\t\r\n ']}"
          CLEAN_REPO_NAME=$(echo "${REPO_URL}" | sed 's/^https\?:\/\///')
          CLEAN_REPO_NAME="${CLEAN_REPO_NAME//\//.}"
          
          echo "Downloading repo file ${REPO_URL}"
          curl -fLs --create-dirs "${REPO_URL}" -o "/etc/yum.repos.d/${CLEAN_REPO_NAME}"
          echo "Downloaded repo file ${REPO_URL}"
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
        mkdir -p "/usr/lib/opt/${OPTPKG}"
        ln -s "../../usr/lib/opt/${OPTPKG}" "/var/opt/${OPTPKG}"
        echo "Created symlinks for ${OPTPKG}"
    done
fi

get_yaml_array INSTALL_PKGS '.install[]' "$1"
get_yaml_array REMOVE_PKGS '.remove[]' "$1"

CLASSIC_INSTALL=false
HTTPS_INSTALL=false
LOCAL_INSTALL=false

# Install and remove RPM packages
# Sort classic, URL & local packages
if [[ ${#INSTALL_PKGS[@]} -gt 0 ]]; then
  for PKG in "${INSTALL_PKGS[@]}"; do
      if [[ "${PKG}" =~ ^https?:\/\/.* ]]; then
        VERSION_SUBSTITUTED_PKG="${PKG//%OS_VERSION%/${OS_VERSION}}"    
        HTTPS_INSTALL=true
        HTTPS_PKGS+=("${VERSION_SUBSTITUTED_PKG}")
      elif [[ ! "${PKG}" =~ ^https?:\/\/.* ]] && [[ -f "${CONFIG_DIRECTORY}/rpm-ostree/${PKG}" ]]; then
        LOCAL_INSTALL=true
        LOCAL_PKGS+=("${CONFIG_DIRECTORY}/rpm-ostree/${PKG}")
      else
        CLASSIC_INSTALL=true
        CLASSIC_PKGS+=("${PKG}")
      fi
  done
fi

echo_rpm_install() {
    if ${CLASSIC_INSTALL} && ! ${HTTPS_INSTALL} && ! ${LOCAL_INSTALL}; then
      echo "Installing: ${CLASSIC_PKGS[*]}"
    elif ! ${CLASSIC_INSTALL} && ${HTTPS_INSTALL} && ! ${LOCAL_INSTALL}; then
      echo "Installing package(s) directly from URL: ${HTTPS_PKGS[*]}"
    elif ! ${CLASSIC_INSTALL} && ! ${HTTPS_INSTALL} && ${LOCAL_INSTALL}; then
      echo "Installing local package(s): ${LOCAL_PKGS[*]}"
    elif ${CLASSIC_INSTALL} && ${HTTPS_INSTALL} && ! ${LOCAL_INSTALL}; then
      echo "Installing: ${CLASSIC_PKGS[*]}"
      echo "Installing package(s) directly from URL: ${HTTPS_PKGS[*]}"
    elif ${CLASSIC_INSTALL} && ! ${HTTPS_INSTALL} && ${LOCAL_INSTALL}; then
      echo "Installing: ${CLASSIC_PKGS[*]}"
      echo "Installing local package(s): ${LOCAL_PKGS[*]}"
    elif ! ${CLASSIC_INSTALL} && ${HTTPS_INSTALL} && ${LOCAL_INSTALL}; then
      echo "Installing package(s) directly from URL: ${HTTPS_PKGS[*]}"    
      echo "Installing local package(s): ${LOCAL_PKGS[*]}"
    elif ${CLASSIC_INSTALL} && ${HTTPS_INSTALL} && ${LOCAL_INSTALL}; then
      echo "Installing: ${CLASSIC_PKGS[*]}"
      echo "Installing package(s) directly from URL: ${HTTPS_PKGS[*]}"
      echo "Installing local package(s): ${LOCAL_PKGS[*]}"
    fi
}

if [[ ${#INSTALL_PKGS[@]} -gt 0 && ${#REMOVE_PKGS[@]} -gt 0 ]]; then
    echo "Installing & Removing RPMs"
    echo_rpm_install
    echo "Removing: ${REMOVE_PKGS[*]}"
    # Doing both actions in one command allows for replacing required packages with alternatives
    # When --install= flag is used, URLs & local packages are not supported
    if ${CLASSIC_INSTALL} && ! ${HTTPS_INSTALL} && ! ${LOCAL_INSTALL}; then
      rpm-ostree override remove "${REMOVE_PKGS[@]}" $(printf -- "--install=%s " "${CLASSIC_PKGS[@]}")
    elif ${CLASSIC_INSTALL} && ${HTTPS_INSTALL} && ! ${LOCAL_INSTALL}; then
      rpm-ostree override remove "${REMOVE_PKGS[@]}" $(printf -- "--install=%s " "${CLASSIC_PKGS[@]}")
      rpm-ostree install "${HTTPS_PKGS[@]}"
    elif ${CLASSIC_INSTALL} && ! ${HTTPS_INSTALL} && ! ${LOCAL_INSTALL}; then
      rpm-ostree override remove "${REMOVE_PKGS[@]}" $(printf -- "--install=%s " "${CLASSIC_PKGS[@]}")    
      rpm-ostree install "${LOCAL_PKGS[@]}"
    elif ${CLASSIC_INSTALL} && ${HTTPS_INSTALL} && ${LOCAL_INSTALL}; then
      rpm-ostree override remove "${REMOVE_PKGS[@]}" $(printf -- "--install=%s " "${CLASSIC_PKGS[@]}")
      rpm-ostree install "${HTTPS_PKGS[@]}" "${LOCAL_PKGS[@]}"
    fi  
elif [[ ${#INSTALL_PKGS[@]} -gt 0 ]]; then
    echo "Installing RPMs"
    echo_rpm_install
    rpm-ostree install "${INSTALL_PKGS[@]}"
elif [[ ${#REMOVE_PKGS[@]} -gt 0 ]]; then
    echo "Removing RPMs"
    echo "Removing: ${REMOVE_PKGS[*]}"
    rpm-ostree override remove "${REMOVE_PKGS[@]}"
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

        REPO_URL="${REPO//[$'\t\r\n ']}"

        echo "Downloading repo file ${REPO_URL}"
        curl -fLs --create-dirs -O "${REPO_URL}" --output-dir "/etc/yum.repos.d/"
        echo "Downloaded repo file ${REPO_URL}"

        rpm-ostree override replace --experimental --from "repo=copr:copr.fedorainfracloud.org:${MAINTAINER}:${REPO_NAME}" "${REPLACE_STR}"
        rm "/etc/yum.repos.d/${FILE_NAME}"

    done
fi
