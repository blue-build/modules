#!/usr/bin/env bash
set -oue pipefail

get_yaml_array NERD '.fonts.nerd-fonts[]' "$1"
get_yaml_array GOOGLE '.fonts.google-fonts[]' "$1"

COMPRESS_TYPES=("zip" "tar.gz")
DIR_FONTS=/usr/share/fonts

mkcd() {

    if [ -d "$1" ]; then

        rm -rf "$1"

    fi

    mkdir -p "$1"
    cd "$1" || exit 0

}

echo_with_pattern() {

    echo "---- $1 ----"

}

source_font_dir() {

    fc-cache -f "$1"

}

download() {

    local name=$1
    local url=$2
    local dir_principal=$3
    local add_name_and_extension_url=$4
    local downloaded
    local file

    mkcd "$name"

    echo "${COMPRESS_TYPES[@]}" | while IFS=$'\n' read -r -d ' ' type; do

        downloaded=$(ls | wc -l)
        file="$name.$type"

        if [[ $downloaded -eq 0 ]]; then

            echo_with_pattern "Downloading $file"

            if [[ "${add_name_and_extension_url}" == *"y"* ]]; then

                curl -o "$file" -OL "$url$file"

            else

                curl -o "$file" -OL "$url"

            fi

            if [[ -f "$file" ]]; then

                case $type in

                tar.xz) tar xvJf "$file" ;;
                zip) unzip "$file" ;;

                esac

                rm -rf "$file"

                echo_with_pattern "$file downloaded"

            else

                echo_with_pattern "Unable to download $file"

            fi

        fi

    done

    cd "$dir_principal" || exit 0

}

if [ ${#GOOGLE[@]} -gt 0 ]; then

    mkcd $DIR_FONTS/google-fonts

    echo_with_pattern "Installation of google-fonts started"

    for font in "${GOOGLE[@]}"; do

        font="$(echo "$font" | tr -d '\n')"

        download "$font" "https://fonts.google.com/download?family=${font// /%20}" $DIR_FONTS/google-fonts "n"

    done

    source_font_dir $DIR_FONTS/google-fonts

fi

if [ ${#NERD[@]} -gt 0 ]; then

    mkcd $DIR_FONTS/nerd-fonts

    echo_with_pattern "Installation of nerd-fonts started"

    for font in "${NERD[@]}"; do

        font="$(echo "$font" | tr -d '\n')"

        download "$font" "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/" $DIR_FONTS/nerd-fonts "y"

    done

    source_font_dir $DIR_FONTS/nerd-fonts

fi

cd /
