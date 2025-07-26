#!/bin/bash
# Don't source PATH for soar packages when it's not an interactive terminal session & when it's a root user
if [[ ${-} == *i* && "$(/bin/id -u)" != 0 ]]; then
  # shellcheck disable=SC2076
  if ! [[ "$PATH" =~ "${XDG_DATA_HOME:-$HOME/.local/share}/soar/bin:" ]]; then
    export PATH="${XDG_DATA_HOME:-$HOME/.local/share}/soar/bin:${PATH}"
  fi
fi
