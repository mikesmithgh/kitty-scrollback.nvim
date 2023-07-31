#!/usr/bin/env bash
base_dir=$(cd "$(dirname "$0")/.." || exit 1; pwd -P)
mapping=${1-ctrl+shift+h}
printf "map %s launch --type overlay --stdin-source=@screen_scrollback --stdin-add-formatting --cwd %s %s\n" "$mapping" "$base_dir" "$base_dir/scripts/scrollback.sh"

