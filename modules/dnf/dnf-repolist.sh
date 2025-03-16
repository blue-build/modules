#!/bin/bash

output=$(dnf repolist -q --all 2>/dev/null)
lines=$(echo "$output" | tail -n +3)
first_entry=true

echo "["

echo "$lines" | while read -r line; do
    	repo_id=$(echo "$line" | awk '{print $1}')
    	status=$(echo "$line" | awk '{print $NF}')
    	repo_name=$(echo "$line" | awk '{$1=""; $NF=""; print $0}' | sed -e 's/^ *//g' -e 's/ *$//g')

    	if [ "$status" = "enabled" ]; then
        	status=true
    	else
        	status=false
    	fi
    	if [ "$first_entry" = true ]; then
        	first_entry=false
    	fi

	cat <<EOF
  {
    "id":"$repo_id",
    "name":"$repo_name",
    "is_enabled":$status
  },
EOF
done

echo "]"
