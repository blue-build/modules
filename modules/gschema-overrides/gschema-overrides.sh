#!/usr/bin/env bash

set -euo pipefail

get_json_array INCLUDE 'try .["include"][]' "$1"

SCHEMA_INCLUDE_LOCATION="${CONFIG_DIRECTORY}/gschema-overrides"
SCHEMA_TEST_LOCATION="/tmp/bluebuild-schema-test"
SCHEMA_LOCATION="/usr/share/glib-2.0/schemas"
readarray -t MODULE_FILES < <(find "${SCHEMA_INCLUDE_LOCATION}" -type f)
readarray -t SCHEMA_MODULE_FILES < <(find "${SCHEMA_INCLUDE_LOCATION}" -type f -name "*.gschema.override" -printf "%f\n")

# Abort the build if no files are found in ${SCHEMA_INCLUDE_LOCATION}
if [[ ${#MODULE_FILES[@]} -eq 0 ]]; then
  echo "ERROR: You don't have any files in '${SCHEMA_INCLUDE_LOCATION/#\/tmp/}/' location inside the repo"
  echo "       Please make sure that you put at least 1 file in that location before using this module"
  exit 1
fi

# Abort the build if no gschema.override files are found in ${SCHEMA_INCLUDE_LOCATION}
if [[ ${#SCHEMA_MODULE_FILES[@]} -eq 0 ]]; then
  echo "ERROR: Files found, but you don't have any '.gschema.override' files in '${SCHEMA_INCLUDE_LOCATION/#\/tmp/}/' location inside the repo"
  echo "       Please make sure that you named the files correctly"
  exit 1
fi

# Abort the build if recipe input does not match any of the included files
if [[ ${#INCLUDE[@]} -gt 0 ]]; then
  for input in "${INCLUDE[@]}"; do
    match_found=false
    for file in "${SCHEMA_MODULE_FILES[@]}"; do
      if [[ "${input}" == "${file}" ]]; then
        match_found=true
        break
      fi
    done
    if [[ "${match_found}" == false ]]; then
      echo "ERROR: Module failed because '${input}' file specified in module recipe doesn't match any of the included files in '${SCHEMA_INCLUDE_LOCATION/#\/tmp/}/' location inside the repo"
      exit 1
    fi
  done
fi

# Apply gschema-override when all conditions above are satisfied

printf "Applying the following gschema-overrides:\n"

if [[ ${#INCLUDE[@]} -gt 0 ]]; then
  for file in "${INCLUDE[@]}"; do
    printf "%s\n" "${file}"
  done
else
  for file in "${SCHEMA_MODULE_FILES[@]}"; do
    printf "%s\n" "${file}"
  done
fi

mkdir -p "${SCHEMA_TEST_LOCATION}" "${SCHEMA_LOCATION}"
find "${SCHEMA_LOCATION}" -type f ! -name "*.gschema.override" -exec cp {} "${SCHEMA_TEST_LOCATION}" \;

if [[ ${#INCLUDE[@]} -gt 0 ]]; then
  for file in "${INCLUDE[@]}"; do
    file_path="${SCHEMA_INCLUDE_LOCATION}/${file}"
    cp "${file_path}" "${SCHEMA_TEST_LOCATION}"
  done
else
  for file in "${SCHEMA_MODULE_FILES[@]}"; do
    file_path="${SCHEMA_INCLUDE_LOCATION}/${file}"
    cp "${file_path}" "${SCHEMA_TEST_LOCATION}"
  done
fi

echo "Running error-checking test for your gschema-overrides. If test fails, build also fails."
glib-compile-schemas --strict "${SCHEMA_TEST_LOCATION}"

echo "Compiling gschema to include your changes with gschema-override"

if [[ ${#INCLUDE[@]} -gt 0 ]]; then
  for file in "${INCLUDE[@]}"; do
    file_path="${SCHEMA_TEST_LOCATION}/${file}"
    cp "${file_path}" "${SCHEMA_LOCATION}"
  done
else
  for file in "${SCHEMA_MODULE_FILES[@]}"; do
    file_path="${SCHEMA_TEST_LOCATION}/${file}"
    cp "${file_path}" "${SCHEMA_LOCATION}"
  done
fi

glib-compile-schemas "${SCHEMA_LOCATION}" &>/dev/null
