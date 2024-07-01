#!/usr/bin/env bash
    
set -euo pipefail    
    
############################### VARIABLE FUNCTIONS ###################################

get_yaml_array() {
    # Workaround for trimming newlines until this is implemented in build.sh
    readarray -t "$1" < <(echo "$3" | yq -I=0 "$2")
}

sanitize_file_names() {
    if [ -z "$1" ]; then
        return 0  # Exit the function if the variable is empty
    fi
    # If file-name has whitespace, convert it to _ character.
    declare -n arr=$1
    for i in "${!arr[@]}"; do
        arr[$i]=${arr[$i]// /_}
    done
}

extract_default_wallpaper_light() {
    # Extract default light theme wallpaper from light/dark recipe input.
    # It always assumes that light wallpaper is set as 1st in light.jpg + dark.jpg recipe format.
    if [[ ${#DEFAULT_WALLPAPER_LIGHT_DARK[@]} -eq 1 ]]; then
      readarray -t "$1" < <(awk -F '_\\+_' '{printf "%s", $1}' <<< "$DEFAULT_WALLPAPER_LIGHT_DARK")
    fi  
}

extract_default_wallpaper_dark() {
    # Extract default dark theme wallpaper from light/dark recipe input.
    # It always assumes that dark wallpaper is set as 2nd in light.jpg + dark.jpg recipe format.
    if [[ ${#DEFAULT_WALLPAPER_LIGHT_DARK[@]} -eq 1 ]]; then
      readarray -t "$1" < <(awk -F '_\\+_' '{printf "%s", $NF}' <<< "$DEFAULT_WALLPAPER_LIGHT_DARK")
    fi  
}

extract_wallpaper_light_dark() {
    # Extract included light/dark wallpapers from default light/dark wallpapers which are inputted into recipe file.
    # Exclude default light/dark wallpaper from the list.
    # Also don't include ./ prefix in files & include filenames only for `find` command.
    if [[ ${#DEFAULT_WALLPAPER_LIGHT_DARK[@]} -eq 1 ]] && [[ -n $(find "$wallpaper_light_dark_dir" -type f) ]]; then    
      readarray -t "$1" < <(find "$wallpaper_light_dark_dir" -type f ! -name "$DEFAULT_WALLPAPER_LIGHT" ! -name  "$DEFAULT_WALLPAPER_DARK" -exec basename {} \;)
    elif [[ -n $(find "$wallpaper_light_dark_dir" -type f) ]]; then
      readarray -t "$1" < <(find "$wallpaper_light_dark_dir" -type f -exec basename {} \;)
    else
      # Avoid unbound variable if value should be empty
      readarray -t "$1" <<< ""
    fi
}

extract_wallpaper_light() {
    # Extract included light wallpaper from default light/dark wallpapers which are inputted into recipe file.
    # Light wallpaper must contain "-bb-light" word in filename.
    if [[ ${#WALLPAPER_LIGHT_DARK[@]} -gt 0 ]]; then
      readarray -t "$1" < <(awk '/-bb-light/' <<< "${WALLPAPER_LIGHT_DARK[@]}")
    else
      # Avoid unbound variable if value should be empty
      readarray -t "$1" <<< ""
    fi
}

extract_wallpaper_dark() {
    # Extract included dark wallpaper from default light/dark wallpapers which are inputted into recipe file.
    # Dark wallpaper must contain "-bb-dark" word in filename.
    if [[ ${#WALLPAPER_LIGHT_DARK[@]} -gt 0 ]]; then
      readarray -t "$1" < <(awk '/-bb-dark/' <<< "${WALLPAPER_LIGHT_DARK[@]}")
    else
      # Avoid unbound variable if value should be empty
      readarray -t "$1" <<< ""
    fi
}

extract_wallpaper() {
    # Extract regular included wallpaper.
    # Exclude directory for light/dark wallpapers inclusion.
    # Exclude default wallpaper from the list.
    if [[ ${#DEFAULT_WALLPAPER[@]} -eq 1 ]] && [[ -n $(find "$wallpaper_light_dark_dir" -type f) ]]; then            
      readarray -t "$1" < <(find "$wallpaper_include_dir" -type f ! -path "$wallpaper_light_dark_dir/*" ! -name "$DEFAULT_WALLPAPER" -exec basename {} \;)
    elif  [[ ${#DEFAULT_WALLPAPER[@]} -eq 1 ]] && [[ -z $(find "$wallpaper_light_dark_dir" -type f) ]]; then
      readarray -t "$1" < <(find "$wallpaper_include_dir" -type f -not -name "$DEFAULT_WALLPAPER" -exec basename {} \;)
    elif  [[ -n $(find "$wallpaper_light_dark_dir" -type f) ]]; then
      readarray -t "$1" < <(find "$wallpaper_include_dir" -type f -not -path "$wallpaper_light_dark_dir/*" -exec basename {} \;)
    elif  [[ -z $(find "$wallpaper_light_dark_dir" -type f) ]]; then
      readarray -t "$1" < <(find "$wallpaper_include_dir" -type f -exec basename {} \;)
    else
      # Avoid unbound variable if value should be empty
      readarray -t "$1" <<< ""
    fi    
}

############################### VARIABLES ###################################

# File & folder location variables

MODULE_DIRECTORY="${MODULE_DIRECTORY:-"/tmp/modules"}"
wallpapers_module_dir="$MODULE_DIRECTORY"/wallpapers
wallpaper_include_dir="$CONFIG_DIRECTORY"/wallpapers
wallpaper_destination="/usr/share/backgrounds/bluebuild"
# Gnome file & folder locations
wallpaper_light_dark_dir="$wallpaper_include_dir"/gnome-light-dark
xml_default_template="$wallpapers_module_dir"/template.xml
xml_modified_template="$wallpapers_module_dir"/bluebuild-template.xml
xml_destination="/usr/share/gnome-background-properties"
gschema_override="$wallpapers_module_dir"/zz2-bluebuild-wallpapers.gschema.override
gschema_override_test_dir="/tmp/bluebuild-schema-test-wallpapers"
gschema_override_test="$gschema_override_test_dir"/zz2-bluebuild-wallpapers.gschema.override
gschema_override_destination="/usr/share/glib-2.0/schemas"

# Wallpaper variables (for Gnome)

# Default wallpapers
get_yaml_array DEFAULT_WALLPAPER '.default.wallpaper[]' "$1"
sanitize_file_names DEFAULT_WALLPAPER
#
get_yaml_array DEFAULT_WALLPAPER_LIGHT_DARK '.default.wallpaper-light-dark[]' "$1"
sanitize_file_names DEFAULT_WALLPAPER_LIGHT_DARK
#
extract_default_wallpaper_light DEFAULT_WALLPAPER_LIGHT
extract_default_wallpaper_dark DEFAULT_WALLPAPER_DARK
# Included wallpapers
extract_wallpaper_light_dark WALLPAPER_LIGHT_DARK
sanitize_file_names WALLPAPER_LIGHT_DARK
#
extract_wallpaper_light WALLPAPER_LIGHT
extract_wallpaper_dark WALLPAPER_DARK
#
extract_wallpaper WALLPAPER
sanitize_file_names WALLPAPER

# Scaling variables
scaling_options=("none" "scaled" "stretched" "zoom" "centered" "spanned" "wallpaper")

# Automatically generate global & per-wallpaper scaling variable based on available options above as
# SCALING_$option_ALL
# SCALING_$option_WALLPAPER

# Declare associative arrays for global and per-wallpaper scaling variables
declare -A SCALING_ALL
declare -A SCALING_WALLPAPER

# Generate global and per-wallpaper scaling variables
for option in "${scaling_options[@]}"; do
    variable_name="SCALING_${option^^}_ALL"
    variable_value=$(echo "$1" | yq -I=0 ".scaling.$option")
    SCALING_ALL["$variable_name"]=$variable_value
    
    array_variable_name="SCALING_${option^^}_WALLPAPER"
    array_variable_value=$(echo "$1" | yq -I=0 ".scaling.$option[]" | tr ' ' '_')
    SCALING_WALLPAPER["$array_variable_name"]=$array_variable_value
done

############################### INSTALLATION CHECKS ###################################

# Fail if no wallpapers are detected in `config/wallpapers` directory.
if [ ! -d "$wallpaper_include_dir" ] || [[ ! $(find "$wallpaper_include_dir" -type f) ]]; then
  echo "Module failed because wallpapers aren't included in config/wallpapers directory"
  exit 1
fi

# Fail if more than 1 default wallpaper is included.
if [[ ${#DEFAULT_WALLPAPER[@]} -gt 1 ]]; then
  echo "Module failed because you included more than 1 regular wallpaper to be set as default, which is not allowed"
  exit 1
fi
if [[ ${#DEFAULT_WALLPAPER_LIGHT_DARK[@]} -gt 1 ]]; then
  echo "Module failed because you included more than 1 light & dark wallpaper to be set as default for light/dark theme, which is not allowed"
  exit 1
fi

# Fail if default light+dark wallpaper does not contain '-bb-light' or '-bb-dark' suffix.
if [[ ${#DEFAULT_WALLPAPER_LIGHT_DARK[@]} -eq 1 ]]; then
  if [[ ! "$DEFAULT_WALLPAPER_LIGHT" =~ "-bb-light" ]]; then
    echo "Module failed because default light wallpaper does not contain '-bb-light' suffix"
    exit 1
  fi
  if [[ ! "$DEFAULT_WALLPAPER_DARK" =~ "-bb-dark" ]]; then
    echo "Module failed because default dark wallpaper does not contain '-bb-dark' suffix"
    exit 1
  fi
fi

# Stop the script after copying wallpapers if non-Gnome DE is detected
gnome_section () {
if ! command -v gnome-shell &> /dev/null; then
  echo "Wallpapers module installed successfully!"
  exit 0
fi
}

############################### INSTALLATION PROCESS ###################################

echo "Installing wallpapers module"

echo "Copying wallpapers into system backgrounds directory"
# If file-names & wallpaper folders have whitespaces, convert them to _ character.
find "$wallpaper_include_dir" -depth -name "* *" -execdir bash -c 'mv "$0" "${0// /_}"' {} \;
mkdir -p "$wallpaper_destination"
find "$wallpaper_include_dir" -type f -exec cp {} "$wallpaper_destination" \;

############################### GNOME-SPECIFIC CODE ###################################
####################################################################################
############################### WALLPAPER XML ###################################

gnome_section

# Included wallpapers XML section
# Write XMLs to make included wallpapers appear in Gnome settings.
# Remove filename-dark field, as it's not needed for classic wallpapers
# Set name of the XML to bluebuild-nameofthewallpaper.jpg.xml
if [[ ${#WALLPAPER[@]} -gt 0 ]]; then
echo "Writing XMLs for included wallpapers to appear in Gnome settings"
  for wallpaper in "${WALLPAPER[@]}"; do
      cp "$xml_default_template" "$xml_modified_template"
      yq -i '.wallpapers.wallpaper.name = "BlueBuild-'"$wallpaper"'"' "$xml_modified_template"
      yq -i ".wallpapers.wallpaper.filename = \"$wallpaper_destination/$wallpaper\"" "$xml_modified_template"
      yq 'del(.wallpapers.wallpaper.filename-dark)' "$xml_modified_template" -i
      cp "$xml_modified_template" "$xml_destination"/bluebuild-"$wallpaper".xml
      rm "$xml_modified_template"
  done
fi

# Included light+dark wallpapers XML section
# Write XMLs to make included light+dark wallpapers appear in Gnome settings.
# Set name of the XML to bluebuild-wallpaper-bb-light.jpg_+_bluebuild-wallpaper-bb-dark.jpg.xml
if [[ ${#WALLPAPER_LIGHT_DARK[@]} -gt 0 ]]; then
  echo "Writing XMLs for included light+dark wallpapers to appear in Gnome settings"
  for ((i=0; i<${#WALLPAPER_LIGHT_DARK[@]}; i+=2)); do
    wallpaper_light="${WALLPAPER_LIGHT_DARK[i]}"
    wallpaper_dark="${WALLPAPER_LIGHT_DARK[i+1]}"
    cp "$xml_default_template" "$xml_modified_template"
    yq -i '.wallpapers.wallpaper.name = "BlueBuild-'"$wallpaper_light"_+_"$wallpaper_dark"'"' "$xml_modified_template"
    yq -i ".wallpapers.wallpaper.filename = \"$wallpaper_destination/$wallpaper_light\"" "$xml_modified_template"
    yq -i ".wallpapers.wallpaper.filename-dark = \"$wallpaper_destination/$wallpaper_dark\"" "$xml_modified_template"
    cp "$xml_modified_template" "$xml_destination"/bluebuild-"$wallpaper_light"_+_"$wallpaper_dark".xml
    rm "$xml_modified_template"
  done
fi

# Default wallpaper XML section
# Write XML to make default wallpaper appear in Gnome settings.
# Remove filename-dark field, as it's not needed for the default wallpaper
# Set name of the XML to bluebuild-nameofthewallpaper.jpg.xml
if [[ ${#DEFAULT_WALLPAPER[@]} -eq 1 ]]; then
echo "Writing XML for default wallpaper to appear in Gnome settings"
  for default_wallpaper in "${DEFAULT_WALLPAPER[@]}"; do
      cp "$xml_default_template" "$xml_modified_template"
      yq -i '.wallpapers.wallpaper.name = "BlueBuild-'"$default_wallpaper"'"' "$xml_modified_template"
      yq -i ".wallpapers.wallpaper.filename = \"$wallpaper_destination/$default_wallpaper\"" "$xml_modified_template"
      yq 'del(.wallpapers.wallpaper.filename-dark)' "$xml_modified_template" -i
      cp "$xml_modified_template" "$xml_destination"/bluebuild-"$default_wallpaper".xml
      rm "$xml_modified_template"    
  done
fi

# Default light+dark wallpaper XML section
# Write XMLs to make default light+dark wallpaper appear in Gnome settings.
# Set name of the XML to bluebuild-wallpaper-bb-light.jpg_+_bluebuild-wallpaper-bb-dark.jpg.xml
if [[ ${#DEFAULT_WALLPAPER_LIGHT_DARK[@]} -eq 1 ]]; then
echo "Writing XML for default light+dark wallpaper to appear in Gnome settings"
  for default_wallpaper_light_dark in "${DEFAULT_WALLPAPER_LIGHT_DARK[@]}"; do
        cp "$xml_default_template" "$xml_modified_template"
        yq -i '.wallpapers.wallpaper.name = "BlueBuild-'"$default_wallpaper_light_dark"'"' "$xml_modified_template"
        yq -i ".wallpapers.wallpaper.filename = \"$wallpaper_destination/$DEFAULT_WALLPAPER_LIGHT\"" "$xml_modified_template"
        yq -i ".wallpapers.wallpaper.filename-dark = \"$wallpaper_destination/$DEFAULT_WALLPAPER_DARK\"" "$xml_modified_template"
        cp "$xml_modified_template" "$xml_destination"/bluebuild-"$default_wallpaper_light_dark".xml
        rm "$xml_modified_template"
  done
fi

# Write global scaling value to XML file(s)
for scaling_option in "${scaling_options[@]}"; do
    scaling_variable="SCALING_${scaling_option^^}_ALL"
    scaling_all="${SCALING_ALL[$scaling_variable]}"
    if [[ $scaling_all == "all" ]]; then
        echo "Writing global scaling value to XML file(s)"
        for xml_file in "${WALLPAPER[@]}" "${DEFAULT_WALLPAPER[@]}" "${DEFAULT_WALLPAPER_LIGHT_DARK[@]}"; do
            yq -i '.wallpapers.wallpaper.options = "'"$scaling_option"'"' "$xml_destination"/bluebuild-"$xml_file".xml
        done
        for ((i=0; i<${#WALLPAPER_LIGHT_DARK[@]}; i+=2)); do
            wallpaper_light="${WALLPAPER_LIGHT_DARK[i]}"
            wallpaper_dark="${WALLPAPER_LIGHT_DARK[i+1]}"
            yq -i '.wallpapers.wallpaper.options = "'"$scaling_option"'"' "$xml_destination"/bluebuild-"$wallpaper_light"_+_"$wallpaper_dark".xml
        done    
    fi
done

# Write per-wallpaper scaling settings to XML
message_displayed=false
for scaling_option in "${scaling_options[@]}"; do
    scaling_variable="SCALING_${scaling_option^^}_WALLPAPER"
    scaling_specific="${SCALING_WALLPAPER[$scaling_variable]}"
    # Only display this echo message once
    if [[ -n $scaling_specific && $message_displayed == false ]]; then
      echo "Writing per-wallpaper scaling value to XML file(s)"
      message_displayed=true
    fi
    if [[ -n $scaling_specific ]]; then
        for scaling_per_wallpaper in $scaling_specific; do
            yq -i '.wallpapers.wallpaper.options = "'"$scaling_option"'"' "$xml_destination"/bluebuild-"$scaling_per_wallpaper".xml
        done
    fi
done

############################### GSCHEMA OVERRIDE ###################################

# Write default wallpaper to gschema override
if [[ ${#DEFAULT_WALLPAPER[@]} -eq 1 ]]; then
  printf "%s\n" "Setting $DEFAULT_WALLPAPER as the default wallpaper in gschema override"
  printf "%s\n" "picture-uri='file://$wallpaper_destination/$DEFAULT_WALLPAPER'" >> "$gschema_override"
fi

# Write default light/dark theme wallpaper to gschema override
if [[ ${#DEFAULT_WALLPAPER_LIGHT_DARK[@]} -eq 1 ]]; then
  printf "%s\n" "Setting $DEFAULT_WALLPAPER_LIGHT_DARK as the default light+dark wallpaper in gschema override"
  printf "%s\n" "picture-uri='file://$wallpaper_destination/$DEFAULT_WALLPAPER_LIGHT'" >> "$gschema_override"
  printf "%s\n" "picture-uri-dark='file://$wallpaper_destination/$DEFAULT_WALLPAPER_DARK'" >> "$gschema_override"
fi

# Global scaling value (overwrites default zoom value)
for scaling_option in "${scaling_options[@]}"; do
    scaling_variable="SCALING_${scaling_option^^}_ALL"
    scaling_all="${SCALING_ALL[$scaling_variable]}"
    if [[ $scaling_all == "all" ]]; then
      echo "Writing global scaling value to gschema override"
      sed -i "s/picture-options=.*/picture-options='$scaling_option'/" "$gschema_override"
    fi
done

# Per-wallpaper scaling value (overwrites default zoom value)
for scaling_option in "${scaling_options[@]}"; do
    scaling_variable="SCALING_${scaling_option^^}_WALLPAPER"
    scaling_specific="${SCALING_WALLPAPER[$scaling_variable]}"
    if [[ ${#DEFAULT_WALLPAPER_LIGHT_DARK[@]} -eq 1 ]]; then
      if [[ "$scaling_specific" == "$DEFAULT_WALLPAPER_LIGHT_DARK" ]]; then
        echo "Writing per-wallpaper scaling value of default light+dark wallpaper to gschema override"
        sed -i "s/picture-options=.*/picture-options='$scaling_option'/" "$gschema_override"
      fi
    fi  
    if [[ ${#DEFAULT_WALLPAPER[@]} -eq 1 ]]; then
      if [[ "$scaling_specific" == "$DEFAULT_WALLPAPER" ]]; then
        echo "Writing per-wallpaper scaling value of default wallpaper to gschema override"
        sed -i "s/picture-options=.*/picture-options='$scaling_option'/" "$gschema_override"
      fi
    fi  
done

if [[ ${#DEFAULT_WALLPAPER[@]} -eq 1 ]] || [[ ${#DEFAULT_WALLPAPER_LIGHT_DARK[@]} -eq 1 ]]; then
  echo "Copying gschema override to system & building it to include wallpaper defaults"
  mkdir -p "$gschema_override_test_dir"
  cp "$gschema_override" "$gschema_override_test_dir"
  find "$gschema_override_destination" -type f ! -name "*.gschema.override" -exec cp {} "$gschema_override_test_dir" \;  
  glib-compile-schemas --strict "$gschema_override_test_dir"
  cp "$gschema_override_test" "$gschema_override_destination"
  glib-compile-schemas "$gschema_override_destination" &>/dev/null
fi

echo "Wallpapers module installed successfully!"
