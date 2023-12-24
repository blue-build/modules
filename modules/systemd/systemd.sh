#!/usr/bin/env bash

# Tell build process to exit if there are any errors.
set -oue pipefail

get_yaml_array ENABLED '.system.enabled[]' "$1"
get_yaml_array DISABLED '.system.disabled[]' "$1"
get_yaml_array MASKED '.system.masked[]' "$1"
get_yaml_array USER_ENABLED '.user.enabled[]' "$1"
get_yaml_array USER_DISABLED '.user.disabled[]' "$1"
get_yaml_array USER_MASKED '.user.masked[]' "$1"


if [[ ${#ENABLED[@]} -gt 0 ]]; then
    for unit in "${ENABLED[@]}"; do
        unit=$(printf "$unit")
        systemctl -f enable $unit
    done
fi
if [[ ${#DISABLED[@]} -gt 0 ]]; then
    for unit in "${DISABLED[@]}"; do
        unit=$(printf "$unit")
        systemctl disable $unit
    done
fi
if [[ ${#MASKED[@]} -gt 0 ]]; then
    for unit in "${MASKED[@]}"; do
        unit=$(printf "$unit")
        systemctl mask $unit
    done
fi
if [[ ${#USER_ENABLED[@]} -gt 0 ]]; then
    for unit in "${USER_ENABLED[@]}"; do
        unit=$(printf "$unit")
        systemctl --global -f enable $unit
    done
fi
if [[ ${#USER_DISABLED[@]} -gt 0 ]]; then
    for unit in "${USER_DISABLED[@]}"; do
        unit=$(printf "$unit")
        systemctl --global disable $unit
    done
fi
if [[ ${#USER_MASKED[@]} -gt 0 ]]; then
    for unit in "${USER_MASKED[@]}"; do
        unit=$(printf "$unit")
        systemctl --global mask $unit
    done
fi
