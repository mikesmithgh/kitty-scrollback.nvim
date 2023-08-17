#!/usr/bin/env bash
base_dir=$(cd "$(dirname "$0")/.." || exit 1; pwd -P)
mapping=${1-ctrl+shift+h}
printf "map %s kitten %s\n" "$mapping" "$base_dir/python/kitty_scrollback_nvim.py"

