#!/usr/bin/env bash
tmpfile="$(mktemp)"
cat /dev/stdin > "$tmpfile"
SBNVIM_INPUT_FILE="$tmpfile" nvim --clean --noplugin -n -M -S 'lua/scrollback/launch.lua'
# currently very basic, user may want to remove flags

