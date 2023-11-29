#!/usr/bin/env python3
from typing import List
from kitty.boss import Boss
from kittens.tui.handler import result_handler
from kitty.fast_data_types import get_options
from kitty.constants import config_dir, version

import json
import os
import inspect

ksb_dir = os.path.dirname(
    os.path.dirname(os.path.abspath(inspect.getfile(lambda: None))))


def main():
    raise SystemExit('Must be run as kitten kitty_scrollback_nvim')


def get_kitty_shell_integration(kitty_opts, w):
    # KITTY_SHELL_INTEGRATION env var takes precedence over opts
    # kitty v0.30.1 is returning empty window envs so fallback on opts
    # see https://github.com/kovidgoyal/kitty/issues/6749
    shell_integration_opts = kitty_opts.shell_integration or frozenset(
        {'enabled'})
    shell_integration = w.child.environ.get(
        'KITTY_SHELL_INTEGRATION',
        ' '.join(list(shell_integration_opts)))
    return shell_integration.split()


# based on kitty source window.py
def pipe_data(w, target_window_id, ksb_dir, config):
    kitty_opts = get_options()
    kitty_shell_integration = get_kitty_shell_integration(kitty_opts, w)
    return {
        'kitty_scrollback_config': config,
        'scrolled_by': w.screen.scrolled_by,
        'cursor_x': w.screen.cursor.x + 1,
        'cursor_y': w.screen.cursor.y + 1,
        'lines': w.screen.lines + 1,
        'columns': w.screen.columns,
        'window_id': int(target_window_id),
        'window_title': w.title,
        'ksb_dir': ksb_dir,
        'kitty_opts': {
            "shell_integration":
            kitty_shell_integration,
            "scrollback_fill_enlarged_window":
            kitty_opts.scrollback_fill_enlarged_window,
            "scrollback_lines":
            kitty_opts.scrollback_lines,
            "scrollback_pager":
            kitty_opts.scrollback_pager,
            "allow_remote_control":
            kitty_opts.allow_remote_control,
            "listen_on":
            kitty_opts.listen_on,
            "scrollback_pager_history_size":
            kitty_opts.scrollback_pager_history_size
        },
        'kitty_config_dir': config_dir,
        'kitty_version': version,
    }


def parse_nvim_args(args=[]):
    for idx, arg in enumerate(args):
        if arg.startswith('--nvim-args'):
            if idx + 1 < len(args):
                return tuple(filter(None, args[idx + 1:]))
            return ()
    return ()


def parse_env(args):
    env_args = []
    for idx, arg in reversed(list(enumerate(args))):
        if arg.startswith('--env') and (idx + 1 < len(args)):
            env_args.append('--env')
            env_args.append(args[idx + 1])
            del args[idx:idx + 2]
    return tuple(env_args)


def parse_config(args):
    config_args = []
    for idx, arg in reversed(list(enumerate(args))):
        if arg.startswith('--config-file'):
            return 'crying cat --config-file'
        if arg.startswith('--config') and (idx + 1 < len(args)):
            config_args = args[idx + 1]
            del args[idx:idx + 2]
            return config_args
    return 'default'


def parse_cwd(args):
    for idx, arg in reversed(list(enumerate(args))):
        if arg.startswith('--cwd') and (idx + 1 < len(args)):
            cwd_args = args[idx + 1]
            del args[idx:idx + 2]
            return ('--cwd', cwd_args)
    return ()


@result_handler(type_of_input=None, no_ui=True, has_ready_notification=False)
def handle_result(args: List[str],
                  result: str,
                  target_window_id: int,
                  boss: Boss) -> None:
    del args[0]
    w = boss.window_id_map.get(target_window_id)
    if w is not None:
        config = parse_config(args)
        if config == 'crying cat --config-file':
            err_cmd = (
                'launch',
                '--copy-env',
                '--type',
                'overlay',
                '--title',
                'kitty-scrollback.nvim',
                'nvim',
            ) + parse_nvim_args() + (
                '-c',
                'set laststatus=0',
                '-c',
                'set fillchars=eob:\\ ',
                '-c',
                'set filetype=checkhealth',
                f'{ksb_dir}/scripts/breaking_change_config_file.txt',
            )

            err_winid = boss.call_remote_control(w, err_cmd)

            set_logo_cmd = ('set-window-logo',
                            '--no-response',
                            '--alpha',
                            '0.5',
                            '--position',
                            'bottom-right',
                            f'{ksb_dir}/media/sad_kitty_thumbs_up.png')

            err_win = boss.window_id_map.get(err_winid)
            err_winid = boss.call_remote_control(err_win, set_logo_cmd)
            return

        cwd = parse_cwd(args)
        env = parse_env(args)
        kitty_data_str = pipe_data(w, target_window_id, ksb_dir, config)
        kitty_data = json.dumps(kitty_data_str)

        if w.title.startswith('kitty-scrollback.nvim'):
            print(
                f'[Warning] kitty-scrollback.nvim: skipping action, window {target_window_id} has title that '
                'starts with "kitty-scrollback.nvim"')
            print(json.dumps(kitty_data_str, indent=2))
            return

        kitty_args = (
            '--copy-env',
            '--type',
            'overlay',
            '--title',
            'kitty-scrollback.nvim',
        ) + env + cwd

        nvim_args = parse_nvim_args(args) + (
            '--cmd',
            ' lua vim.api.nvim_create_autocmd([[VimEnter]], { '
            '   group = vim.api.nvim_create_augroup([[KittyScrollBackNvimVimEnter]], { clear = true }), '
            '   pattern = [[*]], '
            '   callback = function() '
            f'   vim.opt.runtimepath:append([[{ksb_dir}]])'
            '    vim.api.nvim_exec_autocmds([[User]], { pattern = [[KittyScrollbackLaunch]], modeline = false })'
            f'   require([[kitty-scrollback.launch]]).setup_and_launch([[{kitty_data}]])'
            '  end, '
            ' })')

        cmd = ('launch', ) + kitty_args + ('nvim', ) + nvim_args
        boss.call_remote_control(w, cmd)
    else:
        raise Exception(f'Failed to get window with id: {target_window_id}')
