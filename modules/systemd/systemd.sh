#!/usr/bin/env bash

# Tell build process to exit if there are any errors.
set -euo pipefail

# Copy included systemd unit files to system. Also supports zram-generator & system/user conf.d
SYSTEM_UNIT_INCLUDE="${CONFIG_DIRECTORY}/systemd/system"
USER_UNIT_INCLUDE="${CONFIG_DIRECTORY}/systemd/user"
ZRAM_GENERATOR_INCLUDE="${CONFIG_DIRECTORY}/systemd/zram-generator.conf.d"
SYSTEM_CONF_D_INCLUDE="${CONFIG_DIRECTORY}/systemd/system.conf.d"
USER_CONF_D_INCLUDE="${CONFIG_DIRECTORY}/systemd/user.conf.d"
SYSTEM_UNIT_DIR="/usr/lib/systemd/system"
USER_UNIT_DIR="/usr/lib/systemd/user"
ZRAM_GENERATOR_DIR="/usr/lib/systemd/zram-generator.conf.d"
SYSTEM_CONF_D_DIR="/usr/lib/systemd/system.conf.d"
USER_CONF_D_DIR="/usr/lib/systemd/user.conf.d"

if [[ -d "${SYSTEM_UNIT_INCLUDE}" ]]; then
  if [[ -n $(find "${SYSTEM_UNIT_INCLUDE}" -type f) ]]; then
    echo "Copying 'system systemd units' to system directory"
    cp -r "${SYSTEM_UNIT_INCLUDE}"/* "${SYSTEM_UNIT_DIR}"
  fi
fi
if [[ -d "${USER_UNIT_INCLUDE}" ]]; then
  if [[ -n $(find "${USER_UNIT_INCLUDE}" -type f) ]]; then
    echo "Copying 'user systemd units' to system directory"  
    cp -r "${USER_UNIT_INCLUDE}"/* "${USER_UNIT_DIR}"
  fi  
fi  
if [[ -d "${ZRAM_GENERATOR_INCLUDE}" ]]; then
  if [[ -n $(find "${ZRAM_GENERATOR_INCLUDE}" -type f) ]]; then
    echo "Copying 'zram-generator config' to system directory"
    mkdir -p "${ZRAM_GENERATOR_DIR}"
    cp -r "${ZRAM_GENERATOR_INCLUDE}"/* "${ZRAM_GENERATOR_DIR}"
  fi
fi
if [[ -d "${SYSTEM_CONF_D_INCLUDE}" ]]; then
  if [[ -n $(find "${SYSTEM_CONF_D_INCLUDE}" -type f) ]]; then
    echo "Copying 'system.conf.d config' to system directory"
    mkdir -p "${SYSTEM_CONF_D_DIR}"
    cp -r "${SYSTEM_CONF_D_INCLUDE}"/* "${SYSTEM_CONF_D_DIR}"
  fi
fi
if [[ -d "${USER_CONF_D_INCLUDE}" ]]; then
  if [[ -n $(find "${USER_CONF_D_INCLUDE}" -type f) ]]; then
    echo "Copying 'user.conf.d config' to system directory"
    mkdir -p "${USER_CONF_D_DIR}"
    cp -r "${USER_CONF_D_INCLUDE}"/* "${USER_CONF_D_DIR}"
  fi
fi

# Systemd units configuration (enable, disable, unmask & mask)
get_yaml_array ENABLED '.system.enabled[]' "$1"
get_yaml_array DISABLED '.system.disabled[]' "$1"
get_yaml_array UNMASKED '.system.unmasked[]' "$1"
get_yaml_array MASKED '.system.masked[]' "$1"
get_yaml_array USER_ENABLED '.user.enabled[]' "$1"
get_yaml_array USER_DISABLED '.user.disabled[]' "$1"
get_yaml_array USER_UNMASKED '.user.unmasked[]' "$1"
get_yaml_array USER_MASKED '.user.masked[]' "$1"

if [[ ${#ENABLED[@]} -gt 0 ]]; then
    for unit in "${ENABLED[@]}"; do
        systemctl -f enable "${unit}"
    done
fi
if [[ ${#DISABLED[@]} -gt 0 ]]; then
    for unit in "${DISABLED[@]}"; do
        systemctl disable "${unit}"
    done
fi
if [[ ${#UNMASKED[@]} -gt 0 ]]; then
    for unit in "${UNMASKED[@]}"; do
        systemctl unmask "${unit}"
    done
fi
if [[ ${#MASKED[@]} -gt 0 ]]; then
    for unit in "${MASKED[@]}"; do
        systemctl mask "${unit}"
    done
fi
if [[ ${#USER_ENABLED[@]} -gt 0 ]]; then
    for unit in "${USER_ENABLED[@]}"; do
        systemctl --global -f enable "${unit}"
    done
fi
if [[ ${#USER_DISABLED[@]} -gt 0 ]]; then
    for unit in "${USER_DISABLED[@]}"; do
        systemctl --global disable "${unit}"
    done
fi
if [[ ${#USER_UNMASKED[@]} -gt 0 ]]; then
    for unit in "${USER_UNMASKED[@]}"; do
        systemctl --global unmask "${unit}"
    done
fi
if [[ ${#USER_MASKED[@]} -gt 0 ]]; then
    for unit in "${USER_MASKED[@]}"; do
        systemctl --global mask "${unit}"
    done
fi
