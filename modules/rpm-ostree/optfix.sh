#!/usr/bin/env bash

set -euo pipefail

SOURCE_DIR="/usr/lib/opt/"
TARGET_DIR="/var/opt/"

# Ensure the target directory exists
mkdir -p "$TARGET_DIR"

# Loop through directories in the source directory
for dir in "$SOURCE_DIR"*/; do
  if [ -d "$dir" ]; then
    # Get the base name of the directory
    dir_name=$(basename "$dir")
    
    # Check if the symlink already exists in the target directory
    if [ -L "$TARGET_DIR/$dir_name" ]; then
      echo "Symlink already exists for $dir_name, skipping."
      continue
    fi
    
    # Create the symlink
    ln -s "$dir" "$TARGET_DIR/$dir_name"
    echo "Created symlink for $dir_name"
  fi
done
