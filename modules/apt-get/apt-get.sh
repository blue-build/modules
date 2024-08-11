#!/usr/bin/env bash

# Tell build process to exit if there are any errors.
set -euo pipefail

NO_RECOMMENDS=$(echo "${1}" | yq -I=0 ".no-recommends")
if [[ -z "${NO_RECOMMENDS}" || "${NO_RECOMMENDS}" == "null" ]]; then
    NO_RECOMMENDS=false
fi

INSTALL_SUGGESTS=$(echo "${1}" | yq -I=0 ".install-suggests")
if [[ -z "${INSTALL_SUGGESTS}" || "${INSTALL_SUGGESTS}" == "null" ]]; then
    INSTALL_SUGGESTS=false
fi

FIX_MISSING=$(echo "${1}" | yq -I=0 ".fix-missing")
if [[ -z "${FIX_MISSING}" || "${FIX_MISSING}" == "null" ]]; then
    FIX_MISSING=false
fi

FIX_BROKEN=$(echo "${1}" | yq -I=0 ".fix-broken")
if [[ -z "${FIX_BROKEN}" || "${FIX_BROKEN}" == "null" ]]; then
    FIX_BROKEN=false
fi

if [[ ${NO_RECOMMENDS} == true ]]; then
    APT_ARGS+=("--no-install-recommends")
fi

if [[ ${INSTALL_SUGGESTS} == true ]]; then
    APT_ARGS+=("--install-suggests")
fi

if [[ ${FIX_MISSING} == true ]]; then
    APT_ARGS+=("--fix-missing")
fi

if [[ ${FIX_BROKEN} == true ]]; then
    APT_ARGS+=("--fix-broken")
fi

# get_yaml_array INSTALL_PKGS '.install[]' "$1"

INSTALL_PKGS=("https://discord.com/api/download?platform=linux&format=deb" "micro")

if [[ ${#INSTALL_PKGS[@]} -gt 0 ]]; then
  for PKG in "${INSTALL_PKGS[@]}"; do
      if [[ "${PKG}" =~ ^https?:\/\/.* ]]; then
        PKG_PATH=$(mktemp --suffix=".deb")
        wget -o "${PKG_PATH}" "${PKG}"
        wait
        PROCESSED_INSTALL_PKGS+=("${PKG_PATH}")
      else
        PROCESSED_INSTALL_PKGS+=("${PKG}")
      fi
  done
fi

# shellcheck disable=SC2068
apt-get install -y ${APT_ARGS[@]} "${PROCESSED_INSTALL_PKGS[@]}"

get_yaml_array REMOVE_PKGS '.remove[]' "$1"
apt-get remove -y "${REMOVE_PKGS[@]}"

apt-get clean
