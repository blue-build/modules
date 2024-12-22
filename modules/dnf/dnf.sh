#!/usr/bin/env bash

# Tell build process to exit if there are any errors.
set -euo pipefail

# Fail the build if dnf5 isn't installed
if ! rpm -q dnf5 &>/dev/null; then
  echo "ERROR: Main dependency 'dnf5' is not installed. Install 'dnf5' before using this module to solve this error."
  exit 1
fi

# Fail the build if dnf5 plugins aren't installed
if ! rpm -q dnf5-plugins &>/dev/null; then
  echo "ERROR: Dependency 'dnf5-plugins' is not installed. It is needed for cleanly adding COPR repositories."
  echo "       Install 'dnf5-plugins' before using this module to solve this error."
  exit 1
fi

# Pull in repos
get_json_array REPOS 'try .["repos"][]' "${1}"
if [[ ${#REPOS[@]} -gt 0 ]]; then
  echo "Adding repositories"
  # Substitute %OS_VERSION% & remove newlines/whitespaces from all repo entries
  for i in "${!REPOS[@]}"; do
      repo="${REPOS[$i]}"
      repo="${repo//%OS_VERSION%/${OS_VERSION}}"
      # Extract copr repo array element properly here without JSON brackets (jq doesn't extract elements with spaces properly like yq does)
      if [[ "${repo}" == "{\"copr\":\""*"\"}" ]]; then
        REPOS[$i]="copr: $(echo "${repo}" | jq -r '.copr')"
      else
        # Trim all whitespaces/newlines for other repos
        REPOS[$i]="${repo//[$'\t\r\n ']}"
      fi
  done
  # dnf config-manager & dnf copr don't support adding multiple repositories at once, hence why for/done loop is used
  for repo in "${REPOS[@]}"; do
      if [[ "${repo}" =~ ^https?:\/\/.* ]]; then
        echo "Adding repository URL: '${repo}'"
        dnf -y config-manager addrepo --from-repofile="${repo}"
      elif [[ "${repo}" == *".repo" ]] && [[ -f "${CONFIG_DIRECTORY}/dnf/${repo}" ]]; then
        echo "Adding repository file: '${repo}'"    
        dnf -y config-manager addrepo --from-repofile="${repo}"
      elif [[ "${repo}" == "copr: "* ]]; then
        echo "Adding COPR repository: '${repo#copr: }'"
        dnf -y copr enable "${repo#copr: }"
      fi    
  done
fi

# Install RPM keys if they are provided
get_json_array KEYS 'try .["keys"][]' "${1}" 
if [[ ${#KEYS[@]} -gt 0 ]]; then
    echo "Adding keys"
    for KEY in "${KEYS[@]}"; do
        KEY="${KEY//%OS_VERSION%/${OS_VERSION}}"
        rpm --import "${KEY//[$'\t\r\n ']}"
    done
fi

# Create symlinks to fix packages that create directories in /opt
get_json_array OPTFIX 'try .["optfix"][]' "${1}"
if [[ ${#OPTFIX[@]} -gt 0 ]]; then
    echo "Creating symlinks to fix packages that install to /opt"
    # Create symlink for /opt to /var/opt since it is not created in the image yet
    mkdir -p "/var/opt"
    ln -snf "/var/opt" "/opt"
    # Create symlinks for each directory specified in recipe.yml
    for OPTPKG in "${OPTFIX[@]}"; do
        OPTPKG="${OPTPKG%\"}"
        OPTPKG="${OPTPKG#\"}"
        mkdir -p "/usr/lib/opt/${OPTPKG}"
        ln -s "../../usr/lib/opt/${OPTPKG}" "/var/opt/${OPTPKG}"
        echo "Created symlinks for ${OPTPKG}"
    done
fi

get_json_array INSTALL_PKGS 'try .["install"][]' "${1}"
get_json_array REMOVE_PKGS 'try .["remove"][]' "${1}"

CLASSIC_INSTALL=false
HTTPS_INSTALL=false
LOCAL_INSTALL=false

# Sort classic, URL & local install packages
if [[ ${#INSTALL_PKGS[@]} -gt 0 ]]; then
  for i in "${!INSTALL_PKGS[@]}"; do
      PKG="${INSTALL_PKGS[$i]}"
      if [[ "${PKG}" =~ ^https?:\/\/.* ]]; then
        INSTALL_PKGS[$i]="${PKG//%OS_VERSION%/${OS_VERSION}}"
        HTTPS_INSTALL=true
        HTTPS_PKGS+=("${INSTALL_PKGS[$i]}")
      elif [[ ! "${PKG}" =~ ^https?:\/\/.* ]] && [[ -f "${CONFIG_DIRECTORY}/rpm-ostree/${PKG}" ]]; then
        LOCAL_INSTALL=true
        LOCAL_PKGS+=("${CONFIG_DIRECTORY}/rpm-ostree/${PKG}")
      else
        CLASSIC_INSTALL=true
        CLASSIC_PKGS+=("${PKG}")
      fi
  done
fi

# Function to inform the user about which type of packages is he installing
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

# Remove & install RPM packages
if [[ ${#INSTALL_PKGS[@]} -gt 0 && ${#REMOVE_PKGS[@]} -gt 0 ]]; then
    echo "Removing & Installing RPMs"
    echo "Removing: ${REMOVE_PKGS[*]}"
    echo_rpm_install
    dnf -y remove "${REMOVE_PKGS[@]}"
    dnf -y install "${INSTALL_PKGS[@]}"
elif [[ ${#INSTALL_PKGS[@]} -gt 0 ]]; then
    echo "Installing RPMs"
    echo_rpm_install
    dnf -y install "${INSTALL_PKGS[@]}"
elif [[ ${#REMOVE_PKGS[@]} -gt 0 ]]; then
    echo "Removing RPMs"
    echo "Removing: ${REMOVE_PKGS[*]}"
    dnf -y remove "${REMOVE_PKGS[@]}"
fi

get_json_array REPLACE 'try .["replace"][]' "$1"

# Replace RPM packages from any repository
if [[ ${#REPLACE[@]} -gt 0 ]]; then
    for REPLACEMENT in "${REPLACE[@]}"; do

        # Get repository
        REPO=$(echo "${REPLACEMENT}" | jq -r 'try .["from-repo"]')
        REPO="${REPO//%OS_VERSION%/${OS_VERSION}}"
        REPO="${REPO//[$'\t\r\n ']}"

        # Ensure repository is provided
        if [[ "${REPO}" == "null" ]]; then
            echo "Error: Key 'from-repo' was declared, but repository URL was not provided."
            exit 1
        fi

        # Get packages to replace
        get_json_array PACKAGES 'try .["packages"][]' "${REPLACEMENT}"

        # Ensure packages are provided
        if [[ ${#PACKAGES[@]} == 0 ]]; then
            echo "Error: No packages were provided for repository '${REPO}'."
            exit 1
        fi

        echo "Replacing packages from repository: '${REPO}'"
        echo "Replacing: ${REPLACE_STR}"

        dnf -y distro-sync --refresh --repo "${REPO}" "${PACKEGES[@]}"

    done
fi