#!/bin/sh
# Run this script to update XML files for the backgrounds
set -euo pipefail

function titlecase {
    set ${*,,} 
    printf "%s" "${*^}"
}

# Returns a list of main colors of an image with the format "<ammount of pixels w/ color>,<#HEXVALUE>", decreasing in color importance for each line
function get_dominant_color {
    convert ${1} -scale 50x50! -depth 8 +dither -colors 8 -format "%c" histogram:info: \
        | sed -n 's/^[ ]*\(.*\):.*[#]\([0-9a-fA-F]*\) .*$/\1,#\2/p' \
        | sort -r -n -k 1 -t ","
}

BACKGROUNDDIR="/usr/share/backgrounds"
VENDOR="ublue-os"

if ! command -v convert &> /dev/null ; then
    printf '%c' "Error! This script requires ImageMagick to generate these XML files."
    exit 1
fi

for FILE in $(realpath $(dirname $0))/src/*/* ; do
    FILE_COLOR_GRADIENT=$(get_dominant_color ${FILE})
    tee xml/$(basename ${FILE%.*}.xml) <<EOF
<?xml version="1.0"?>
<!DOCTYPE wallpapers SYSTEM "gnome-wp-list.dtd">
<wallpapers>
  <wallpaper deleted="false">
    <name>$(titlecase $(basename ${FILE%.*} | sed 's/\-/ /g'))</name>
    <filename>$BACKGROUNDDIR/$VENDOR/$(basename $(dirname ${FILE}))/$(basename ${FILE})</filename>
    <options>zoom</options>
    <shade_type>solid</shade_type>
    <pcolor>$(echo -e "${FILE_COLOR_GRADIENT}" | head -n 1 | cut -d',' -f 2)</pcolor>
    <scolor>$(echo -e "${FILE_COLOR_GRADIENT}" | head -2 | tail -1 | cut -d',' -f 2)</scolor>
  </wallpaper>
</wallpapers>
EOF
done