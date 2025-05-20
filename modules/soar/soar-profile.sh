#!/usr/bin/env bash
# Alias 'soar', so it uses BlueBuild's config
# Using function, because I see mixed results on alias overriding an alias in case of local-user config
soar() {
  /usr/bin/soar -c "/usr/share/bluebuild/soar/config.toml" "${@}"
}
export -f soar
# Don't source PATH for soar packages when it's not an interactive terminal session & when it's a root user
if [[ ${-} == *i* && "$(/usr/bin/id -u)" != 0 ]]; then
  # Check if custom packages directory is specified for soar in config to source PATH from
  # If it is, export the PATH from that custom directory
  finished=false
  config_dir="${XDG_CONFIG_HOME:-$HOME/.config}" 
  if [[ -f "${config_dir}/soar/config.toml" ]]; then
    binpath="$(grep 'bin_path' "${config_dir}/soar/config.toml" | sed 's/.*=//; s/"//g; s/^[ \t]*//; s/[ \t]*$//')"
    if [[ -n "${binpath}" ]]; then
      export PATH="${binpath/#\~/$HOME}:${PATH}"
      finished=true
    fi
  fi  
  # If there's no config, export regular 'soar' packages directory to PATH
  if ! ${finished}; then
    share_dir="${XDG_DATA_HOME:-$HOME/.local/share}"    
    export PATH="${share_dir}/soar/bin:${PATH}"
  fi
fi