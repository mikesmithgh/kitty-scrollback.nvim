#!/usr/bin/env python3
from typing import List
from kitty.boss import Boss
from kittens.tui.loop import debug
import sys
import time
from kittens.tui.handler import result_handler
import subprocess
import tempfile

import json
import socket
from typing import Any, Dict
import os
import inspect

# use pure python implementation to avoid macos code signature conflict
os.environ['MSGPACK_PUREPYTHON'] = '1'
ksb_dir = os.path.dirname(
    os.path.dirname(os.path.abspath(inspect.getfile(lambda: None))))
sys.path.append(f'{ksb_dir}/python/lib/site-packages')
import msgpack  # noqa: E402

socket_connect_timeout = 60
msgpack_unicode_errors = 'surrogateescape'  # copied from pynvim


def random_unix_socket():
    tdir = tempfile.mkdtemp(prefix='ksbnvim-')
    return os.path.join(tdir, 'nvim.pipe')


def start_nvim_server(socket_path):
    try:
        os.unlink(socket_path)
    except OSError:
        if os.path.exists(socket_path):
            raise
    return int(
        subprocess.check_output([
            'kitty', '@', 'launch', '--type', 'overlay-main', '--copy-env',
            '--env', f'KSB_DIR={ksb_dir}', '--title',
            'kitty-scrollback.nvim :: loading...', 'nvim', '--listen',
            socket_path, '--clean', '--noplugin', '-n', '--cmd',
            f'lua ksbnvim=dofile("{ksb_dir}/lua/scrollback/launch.lua");' +
            'ksbnvim.setup()'
        ]).decode())


def screen_without_scrollback():
    return int(
        subprocess.check_output([
            'kitty', '@', 'launch', '--type', 'overlay', '--copy-env',
            '--stdin-source', '@screen', '--stdin-add-formatting', 'tail', '-f'
        ]))


def connect_to_nvim_server(client, socket_path):
    connected = False
    connect_timeout = time.time() + socket_connect_timeout
    while not connected and time.time() < connect_timeout:
        try:
            client.connect(socket_path)
            connected = True
        except Exception:
            time.sleep(0.05)
            pass
    return connected


def nvim_remote_ui(socket_path):
    subprocess.call([
        'kitty', '@', 'launch', '--type', 'overlay', 'nvim', '--server',
        socket_path, '--remote-ui'
    ])


def rreplace(s, old, new, occurrence):
    li = s.rsplit(old, occurrence)
    return new.join(li)


# in main, STDIN is for the kitten process and will contain
# the contents of the screen
def main(args: List[str]):
    request_id = 0
    socket_path = random_unix_socket()
    scrollback_winid = start_nvim_server(socket_path)
    loading_winid = subprocess.check_output([
        'kitty',
        '@',
        'launch',
        '--type',
        'overlay',
        '--title',
        'kitty-scrollback.nvim :: loading...',
        f'{ksb_dir}/python/loading.py',
    ]).decode()
    with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as client:
        if not connect_to_nvim_server(client, socket_path):
            debug('could not connect to nvim')
            return None

        # for line in sys.stdin.buffer:
        for raw in sys.stdin:
            request_id += 1
            client.send(
                msgpack.packb([
                    0, request_id, 'nvim_execute_lua',
                    ('return ksbnvim.term_chan_send(...)', [raw])
                ],
                              unicode_errors=msgpack_unicode_errors))
            client.recv(1024)

    return {
        'loading_winid': int(loading_winid),
        'lines': request_id,
        'request_id': request_id,
        'socket_path': socket_path,
        'scrollback_winid': int(scrollback_winid),
    }


# copied from kitty source window.py
def pipe_data(w, target_window_id, total_lines):
    return {
        'scrolled_by': w.screen.scrolled_by,
        'cursor_x': w.screen.cursor.x + 1,
        'cursor_y': w.screen.cursor.y + 1,
        'lines': w.screen.lines,
        'columns': w.screen.columns,
        'window_id': int(target_window_id),
        'total_lines': int(total_lines)
    }


# in handle_result, STDIN is for the kitty process itself, rather
# than the kitten process and should not be read from.
@result_handler(
    type_of_input='screen-ansi-history',
    has_ready_notification=False,  # TODO: confirm this should be False
    no_ui=False)
def handle_result(args: List[str], result: Dict[str, Any],
                  target_window_id: int, boss: Boss) -> None:
    w = boss.window_id_map.get(target_window_id)
    request_id = int(result['request_id'])
    socket_path = result['socket_path']
    scrollback_winid = result['scrollback_winid']
    loading_winid = result['loading_winid']
    total_lines = result['lines']
    if w is not None:
        pd = json.dumps(pipe_data(w, target_window_id, total_lines))
        with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as client:
            if not connect_to_nvim_server(client, socket_path):
                debug('could not connect to nvim')
                return
            request_id += 1
            client.send(
                msgpack.packb([
                    0, request_id, 'nvim_execute_lua',
                    ('return ksbnvim.set_cursor_position(...)', [pd])
                ],
                              unicode_errors=msgpack_unicode_errors))
            client.recv(1024)
            request_id += 1
            kitty_data = {
                'kitty_winid': target_window_id,
                'scrollback_winid': scrollback_winid,
                'loading_winid': loading_winid,
                'total_lines': total_lines
            }
            client.send(
                msgpack.packb([
                    0, request_id, 'nvim_execute_lua',
                    ('return ksbnvim.finalize(...)', [kitty_data])
                ],
                              unicode_errors=msgpack_unicode_errors))
            client.recv(1024)
