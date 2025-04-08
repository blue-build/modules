#!/bin/bash
# convert the output of dnf repoinfo into json

repo_id="$1"
repo_info=$(dnf repoinfo -q "$repo_id")

echo "["
echo "  {"

  repo_id_val=$(echo "$repo_info" | grep -oP "^Repo-id *: *\K.*")
  if [ -n "$repo_id_val" ]; then
    echo "    \"id\":\"$repo_id_val\","
  fi

  repo_name=$(echo "$repo_info" | grep -oP "^Repo-name *: *\K.*")
  if [ -n "$repo_name" ]; then
    echo "    \"name\":\"$repo_name\","
  fi

  repo_status=$(echo "$repo_info" | grep -oP "^Repo-status *: *\K.*")
  if [ -n "$repo_status" ]; then
    if [[ "$repo_status" == "enabled" ]]; then
      echo "    \"is_enabled\":true,"
    else
      echo "    \"is_enabled\":false,"
    fi
  fi

  repo_revision=$(echo "$repo_info" | grep -oP "^Repo-revision *: *\K.*")
  if [ -n "$repo_revision" ]; then
    echo "    \"revision\":\"$repo_revision\","
  fi

  repo_updated=$(echo "$repo_info" | grep -oP "^Repo-updated *: *\K.*")
  if [ -n "$repo_updated" ]; then
    echo "    \"updated\":\"$repo_updated\","
  fi

  repo_available_pkgs=$(echo "$repo_info" | grep -oP "^Repo-available-pkgs *: *\K.*")
  if [ -n "$repo_available_pkgs" ]; then
    echo "    \"available-pkgs\":$repo_available_pkgs,"
  fi

  repo_pkgs=$(echo "$repo_info" | grep -oP "^Repo-pkgs *: *\K.*")
  if [ -n "$repo_pkgs" ]; then
    echo "    \"pkgs\":$repo_pkgs,"
  fi

  repo_size=$(echo "$repo_info" | grep -oP "^Repo-size *: *\K.*")
  if [ -n "$repo_size" ]; then
    echo "    \"size\":\"$repo_size\","
  fi

  repo_metalink=$(echo "$repo_info" | grep -oP "^Repo-metalink *: *\K.*")
  if [ -n "$repo_metalink" ]; then
    echo "    \"metalink\":\"$repo_metalink\","
  fi

  updated=$(echo "$repo_info" | grep -oP "^Updated *: *\K.*")
  if [ -n "$updated" ]; then
    echo "    \"updated\":\"$updated\","
  fi

  repo_baseurl=$(echo "$repo_info" | grep -oP "^Repo-baseurl *: *\K.*")
  if [ -n "$repo_baseurl" ]; then
    echo "    \"baseurl\":\"$repo_baseurl\","
  fi

  repo_expire=$(echo "$repo_info" | grep -oP "^Repo-expire *: *\K.*")
  if [ -n "$repo_expire" ]; then
    echo "    \"expire\":\"$repo_expire\","
  fi

  repo_filename=$(echo "$repo_info" | grep -oP "^Repo-filename *: *\K.*")
  if [ -n "$repo_filename" ]; then
    echo "    \"repo_file_path\":\"$repo_filename\""
  fi

  if [[ "$(tail -c 2 <<< "$(echo "$repo_info")" | head -c 1)" == "," ]]; then
    sed -i '$ s/,$//'
  fi

  echo "  }"
echo "]"
