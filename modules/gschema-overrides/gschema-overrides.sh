#!/usr/bin/env bash

set -euo pipefail

get_yaml_array INCLUDE '.include[]' "$1"

schema_test_location="/tmp/bluebuild-schema-test"
schema_location="/usr/share/glib-2.0/schemas"
gschema_extension=false
most_preferred_override=$(find "$schema_location" -type f -name "*.gschema.override" | tail -n1 | xargs -I {} basename {})

echo "Installing gschema-overrides module"

# Abort build if file in module is not included
if [[ ${#INCLUDE[@]} == 0 ]]; then
  echo "Module failed because gschema-overrides aren't included into the module."
  exit 1
fi

# Abort build if included file does not have .gschema.override extension
if [[ ${#INCLUDE[@]} -gt 0 ]]; then
  for file in "${INCLUDE[@]}"; do
    file="${file//$'\n'/}"
    if [[ $file == *.gschema.override ]]; then
      gschema_extension=true
    else  
      echo "Module failed because included files in module don't have .gschema.override extension."
      exit 1
    fi  
  done
fi

printf "Most preferred gschema-override is:\n" "%s\n" "$most_preferred_override"
echo "If your gschema-override is not listed as most preferred, you should adjust filename prefix"

# Apply gschema-override when all conditions above are satisfied
if [[ ${#INCLUDE[@]} -gt 0 ]] && $gschema_extension; then
  printf "Applying the following gschema-overrides:\n"
  for file in "${INCLUDE[@]}"; do
    file="${file//$'\n'/}"
    printf "%s\n" "$file"
  done
  mkdir -p "$schema_test_location" "$schema_location"
  find "$schema_location" -type f ! -name "*.gschema.override" -exec cp {} "$schema_test_location" \;
  for file in "${INCLUDE[@]}"; do
    file_path="${schema_location}/${file//$'\n'/}"
    cp "$file_path" "$schema_test_location"
  done
  echo "Running error-checking test for your gschema-overrides. If test fails, build also fails."
  glib-compile-schemas --strict "$schema_test_location"
  echo "Compiling gschema to include your changes with gschema-override"
  glib-compile-schemas "$schema_location" &>/dev/null
fi
