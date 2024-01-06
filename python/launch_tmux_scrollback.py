#!/usr/bin/env python3

import json
import os
import inspect
import subprocess
import shlex

ksb_dir = os.path.dirname(
    os.path.dirname(os.path.abspath(inspect.getfile(lambda: None))))


# Compare to the pipe_data fn in `kitty_scrollback_nvim.py`
def pipe_data(target_window_id, window_title, pane_height, pane_width):
    return {
        'scrolled_by': 0,
        'cursor_x': int(tmux_opt("cursor_x")) + 1,
        'cursor_y': int(tmux_opt("cursor_y")) + 1,
        'lines': pane_height,
        'columns': pane_width,
        'window_id': int(target_window_id),
        'window_title': window_title,
        'ksb_dir': ksb_dir,
    }


def tmux_opt(option):
    output = subprocess.run([
        "tmux",
        "display-message",
        "-p",
        f"#{{{option}}}"
    ], stdout=subprocess.PIPE, stderr=subprocess.PIPE).stdout.decode("utf-8")
    return output.strip()


def main():
    target_window_id = tmux_opt("window_index")
    window_title = tmux_opt("pane_title")
    pane_height = int(tmux_opt("pane_height"))
    pane_width = int(tmux_opt(("pane_width")))
    kitty_data_str = pipe_data(target_window_id, window_title, pane_height, pane_width)
    kitty_data = json.dumps(kitty_data_str)

    if window_title.startswith('kitty-scrollback.nvim'):
        print(
            f'[Warning] kitty-scrollback.nvim: skipping action, window {target_window_id} has title that '
            'starts with "kitty-scrollback.nvim"')
        print(json.dumps(kitty_data_str, indent=2))
        return

    nvim_args = (
        'nvim',
        '--clean',
        '--noplugin',
        '-n',
        '--cmd',
        ' lua'
        ' vim.api.nvim_create_autocmd([[VimEnter]], {'
        '  group = vim.api.nvim_create_augroup([[KittyScrollBackNvimVimEnter]], { clear = true }),'
        '  pattern = [[*]],'
        '  callback = function()'
        f'  vim.opt.runtimepath:append([[{ksb_dir}]])'
        '   vim.api.nvim_exec_autocmds([[User]], { pattern = [[KittyScrollbackLaunch]], modeline = false })'
        f'  require([[kitty-scrollback.launch]]).setup_and_launch([[{kitty_data}]])'
        ' end,'
        ' })')

    subprocess.run([
        'tmux',
        'display-popup',
        '-E',
        '-B',
        '-x', 'P',
        '-y', 'P',
        '-w', str(pane_width),
        '-h', str(pane_height),
        shlex.join(nvim_args)
    ])


main()
