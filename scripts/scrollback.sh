#!/usr/bin/env bash
tmpfile="$(mktemp)"
cat /dev/stdin > "$tmpfile"
# currently very basic, user may want to remove flags
SBNVIM_INPUT_FILE="$tmpfile" nvim --clean --noplugin -n -S 'lua/scrollback/launch.lua'
rm -rf "$tmpfile"

