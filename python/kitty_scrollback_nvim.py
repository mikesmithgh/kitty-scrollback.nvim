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
    pass


# based on kitty source window.py
def pipe_data(w, target_window_id):
    return {
        'scrolled_by': w.screen.scrolled_by,
        'cursor_x': w.screen.cursor.x + 1,
        'cursor_y': w.screen.cursor.y + 1,
        'lines': w.screen.lines,
        'columns': w.screen.columns,
        'window_id': int(target_window_id),
    }


@result_handler(type_of_input=None, no_ui=True, has_ready_notification=False)
def handle_result(args: List[str],
                  result: str,
                  target_window_id: int,
                  boss: Boss) -> None:

    w = boss.window_id_map.get(target_window_id)
    if w is not None:
        kitty_data = json.dumps(pipe_data(w, target_window_id))
        boss.call_remote_control(w, (
            'launch',
            '--copy-env',
            '--type',
            'overlay',
            '--title',
            'kitty-scrollback.nvim',
            'nvim',
            '--clean',
            '--noplugin',
            '-n',
            '--cmd',
            (''
             f'lua ksbnvim=dofile([[{ksb_dir}/lua/kitty-scrollback/init.lua]])'
             f'ksbnvim.setup([[{ksb_dir}]])'
             f'ksbnvim.launch([[{kitty_data}]])'
             '')
            )
        )
    else:
        raise Exception(f'Failed to get window with id: {target_window_id}')
