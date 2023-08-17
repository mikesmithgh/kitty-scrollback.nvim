#!/usr/bin/env python3
from typing import List
from kitty.boss import Boss
from kittens.tui.handler import result_handler

import json
import os
import inspect

ksb_dir = os.path.dirname(
    os.path.dirname(os.path.abspath(inspect.getfile(lambda: None))))


def main():
    raise SystemExit('Must be run as kitten kitty_scrollback_nvim')


# based on kitty source window.py
def pipe_data(w, target_window_id, ksb_dir, config_file):
    data = {
        'scrolled_by': w.screen.scrolled_by,
        'cursor_x': w.screen.cursor.x + 1,
        'cursor_y': w.screen.cursor.y + 1,
        'lines': w.screen.lines,
        'columns': w.screen.columns,
        'window_id': int(target_window_id),
        'ksb_dir': ksb_dir,
    }
    if config_file:
        data['config_file'] = config_file
    return data


def parse_kitty_launch_args(args):
    for idx, arg in enumerate(args):
        if arg.startswith('--kitty-launch-args') and (idx + 1 < len(args)):
            kitty_args = args[idx + 1]
            if kitty_args:
                return eval(f'({kitty_args.rstrip(",")},)')
            return ()
    return (
        '--copy-env',
        '--type',
        'overlay',
        '--title',
        'kitty-scrollback.nvim',
    )


def parse_nvim_args(args):
    for idx, arg in enumerate(args):
        if arg.startswith('--nvim-args') and (idx + 1 < len(args)):
            nvim_args = args[idx + 1]
            if nvim_args:
                return eval(f'({nvim_args.rstrip(",")},)')
            return ()
    return (
        '--clean',
        '--noplugin',
        '-n',
    )


def parse_config_file(args):
    for idx, arg in enumerate(args):
        if arg.startswith('--config-file') and (idx + 1 < len(args)):
            config_args = args[idx + 1]
            return config_args
    return None


@result_handler(type_of_input=None, no_ui=True, has_ready_notification=False)
def handle_result(args: List[str],
                  result: str,
                  target_window_id: int,
                  boss: Boss) -> None:
    w = boss.window_id_map.get(target_window_id)
    if w is not None:
        kitty_args = parse_kitty_launch_args(args[1:])
        nvim_args = parse_nvim_args(args[1:])
        config_file = parse_config_file(args[1:])
        kitty_data = json.dumps(
            pipe_data(w,
                      target_window_id,
                      ksb_dir,
                      config_file))
        cmd = (
            'launch',
        ) + kitty_args + (
            'nvim',
        ) + nvim_args + (
            '-c',
            f'lua ksbnvim=dofile([[{ksb_dir}/lua/kitty-scrollback/init.lua]])'
            + f'ksbnvim.setup([[{kitty_data}]])' +
            f'ksbnvim.launch([[{kitty_data}]])',
        )
        boss.call_remote_control(w, cmd)
    else:
        raise Exception(f'Failed to get window with id: {target_window_id}')
