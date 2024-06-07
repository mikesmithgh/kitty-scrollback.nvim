#!/bin/sh

if [ -z "$1" ]; then
  printf 'missing input file\n'
  exit 2
fi

# set input_file to the last argument
# the last argument is used because in the case of zsh, commands maybe be passed before the filename e.g., (-c)
for input_file; do true; done

# after exiting this script and before it has been read by kitty-scrollback.nvim
# the contents of the original input_file may be altered
# avoid this by copying the input_file to a new file that will be referenced
ksb_input_dir=$(mktemp -d)
ksb_input_file="$ksb_input_dir/input.ksb_editcommand"
cp "$input_file" "$ksb_input_file"

script_dir=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
ksb_dir=$(dirname "$script_dir")
# shellcheck disable=SC2086
kitty @ kitten "$ksb_dir/python/kitty_scrollback_nvim.py" --env "KITTY_SCROLLBACK_NVIM_MODE=command_line_editing" --env "KITTY_SCROLLBACK_NVIM_EDIT_INPUT=$ksb_input_file" $KITTY_SCROLLBACK_NVIM_EDIT_ARGS

# small delay before to avoid adding an extra prompt after
# this command has exited and before kitty-scrollback.nvim
# has had time to get the scrollback buffer from kitty
sleep 1

# exit non-zero so that the command is not executed in bash
exit 1
