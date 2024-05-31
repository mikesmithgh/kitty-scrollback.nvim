#!/usr/bin/env bash

if [[ "$1" == *bash-fc* ]]; then
  script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
  "$script_dir/edit_command_line.sh" "$@"
else
  "${KITTY_SCROLLBACK_VISUAL:-nvim}" "$@"
fi
