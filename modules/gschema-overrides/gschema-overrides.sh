#!/usr/bin/env bash

set -euo pipefail

get_yaml_array INCLUDE '.include[]' "$1"

schema_include_location="/tmp/config/gschema-overrides"
schema_test_location="/tmp/bluebuild-schema-test"
schema_location="/usr/share/glib-2.0/schemas"
gschema_extension=false

echo "Installing gschema-overrides module"

# Abort build if file in module is not included
if [[ ${#INCLUDE[@]} == 0 ]]; then
  echo "Module failed because gschema-overrides aren't included into the module."
  exit 1
fi

# Abort build if included file does not have .gschema.override extension
if [[ ${#INCLUDE[@]} -gt 0 ]]; then
  for file in "${INCLUDE[@]}"; do
    if [[ "$file" == *.gschema.override ]]; then
      gschema_extension=true
    else  
      echo "Module failed because included files in module don't have .gschema.override extension."
      exit 1
    fi  
  done
fi

# Apply gschema-override when all conditions above are satisfied
if [[ ${#INCLUDE[@]} -gt 0 ]] && $gschema_extension; then
  printf "Applying the following gschema-overrides:\n"
  for file in "${INCLUDE[@]}"; do
    printf "%s\n" "$file"
  done
  mkdir -p "$schema_test_location" "$schema_location"
  find "$schema_location" -type f ! -name "*.gschema.override" -exec cp {} "$schema_test_location" \;
  for file in "${INCLUDE[@]}"; do
    file_path="${schema_include_location}/${file}"
    cp "$file_path" "$schema_test_location"
  done
  echo "Running error-checking test for your gschema-overrides. If test fails, build also fails."
  glib-compile-schemas --strict "$schema_test_location"
  echo "Compiling gschema to include your changes with gschema-override"
  for file in "${INCLUDE[@]}"; do
    file_path="${schema_test_location}/${file}"
    cp "$file_path" "$schema_location"
  done  
  glib-compile-schemas "$schema_location" &>/dev/null
fi
