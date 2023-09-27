#!/usr/bin/env bash
set -oue pipefail

NERD_FONTS_DIR=/usr/share/fonts/nerd-fonts
COMPRESS_TYPES=("tar.xz" "zip")

mkcd() {

    if [ -d "$1" ]; then
        
        rm -rf "$1"

    fi
    
    mkdir -p "$1"
    cd "$1" || exit 0

}

download() {

    local downloaded
    local file

    mkcd "$1"

    echo "${COMPRESS_TYPES[@]}" | while IFS=$'\n' read -r -d ' ' type; do

        downloaded=$(ls | wc -l)
        file="$1.$type"

        if [[ $downloaded -eq 0 ]]; then

            echo "--- Downloading $file ---"

            curl -o "$file" -OL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/"$file"

            if [[ -f "$file" ]]; then

                case $type in

                tar.xz) tar xvJf "$file" ;;
                zip) unzip "$file" ;;

                esac

                rm -rf "$file"

                echo "--- $file downloaded ---"

            else

                echo "--- Unable to download $file ---"

            fi

        fi

    done

    cd $NERD_FONTS_DIR

}

mkcd $NERD_FONTS_DIR

echo "--- Downloading selected nerd-fonts ---"

get_yaml_array nerdfonts '.fonts[]' "$1"

for font in "${nerdfonts[@]}"; do

    download "$(echo "$font" | tr -d '\n')"

done

fc-cache -f $NERD_FONTS_DIR

echo "--- Nerd-fonts installed ---"

cd /

echo "----"
