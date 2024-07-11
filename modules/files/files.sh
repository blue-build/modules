#!/usr/bin/env bash

# Tell build process to exit if there are any errors.
set -oue pipefail

get_yaml_array ADD_FILES '.add[]' "$1"
get_yaml_array RMV_FILES '.remove[]' "$1"

shopt -s dotglob

if [[ ${#ADD_FILES[@]} -gt 0 ]]; then
	cd "$CONFIG_DIRECTORY/files"

	echo "Adding files to image"
	for pair in "${ADD_FILES[@]}"; do
		FILE="$PWD/$(echo $pair | yq 'to_entries | .[0].key')"
		DEST=$(echo $pair | yq 'to_entries | .[0].value')
		if [ -d "$FILE" ]; then
			if [ ! -d "$DEST" ]; then
				mkdir -p "$DEST"
			fi
			echo "Copying $FILE to $DEST"
			cp -rf "$FILE"/* $DEST
			rm -f "$DEST"/.gitkeep
		elif [ -f "$FILE" ]; then
			DEST_DIR=$(dirname "$DEST")
			if [ ! -d "$DEST_DIR" ]; then
				mkdir -p "$DEST_DIR"
			fi
			echo "Copying $FILE to $DEST"
			cp -f $FILE $DEST
			rm -f "$DEST"/.gitkeep
		else
			echo "File or Directory $FILE Does Not Exist in $CONFIG_DIRECTORY/files"
			exit 1
		fi
	done
fi

if [[ ${#RMV_FILES[@]} -gt 0 ]]; then
	echo "Removing files from image"
	for TARGET in "${RMV_FILES[@]}"; do
		TARGET=$(echo $TARGET | xargs)
		if ! [ -e "$TARGET" ]; then
			echo "File or Directory $TARGET Already Does Not Exist"
			continue
		fi

		rm -rf $TARGET
		echo "Removing $TARGET"
	done
fi

shopt -u dotglob
