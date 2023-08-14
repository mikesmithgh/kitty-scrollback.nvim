#!/usr/bin/env python3
import itertools
import sys
import time
import os

default_color = '#ffffff'


def hex_to_fg_color(hex):
    h = hex.lstrip('#')
    (r, g, b) = tuple(int(h[i:i+2], 16) for i in (0, 2, 4))
    return f'\x1b[38;2;{r};{g};{b}m'


def env_to_fg_color(name):
    hex_color = os.environ.get(name, default_color)
    return hex_to_fg_color(hex_color)


style_simple = os.environ.get('KITTY_SCROLLBACK_NVIM_STYLE_SIMPLE', False).lower() == 'true'
status_window_enabled = os.environ.get('KITTY_SCROLLBACK_NVIM_STATUS_WINDOW_ENABLED', False).lower() == 'true'

time_color = env_to_fg_color('KITTY_SCROLLBACK_NVIM_NORMAL')
heart_color = env_to_fg_color('KITTY_SCROLLBACK_NVIM_HEART')
spinner_color = env_to_fg_color('KITTY_SCROLLBACK_NVIM_SPINNER')
kitty_color = env_to_fg_color('KITTY_SCROLLBACK_NVIM_KITTY')
vim_color = env_to_fg_color('KITTY_SCROLLBACK_NVIM_VIM')
reset = '\x1b[0m'

kitty = kitty_color + '󰄛' + reset
heart = heart_color + '' + reset
vim = vim_color + '' + reset

if style_simple:
    spinner = itertools.cycle(['-', '-', '\\', '\\', '|', '|', '/', '/'])
else:
    spinner = itertools.cycle(['⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏'])

start = time.time()
while True:
    os.system('cls' if os.name == 'nt' else 'clear')
    size = os.get_terminal_size(sys.__stdout__.fileno())
    time_progress = time_color + "{:.1f}s".format(time.time() - start) + reset
    if style_simple:
        spin = spinner_color + next(spinner) + ' kitty-scrollback.nvim' + reset
        ll = f'{time_progress} {spin}'
        line = ll.rjust(size.columns +
                        (len(time_color + reset)) +
                        (len(spinner_color + reset)))

    else:
        spin = spinner_color + next(spinner) + reset
        msg = f'{kitty} {heart} {vim}'
        line = f'{time_progress} {spin} {msg}'.rjust(size.columns +
                                                     (len(time_color + reset)) +
                                                     (len(spinner_color + reset)) +
                                                     (len(kitty_color + reset)) +
                                                     (len(heart_color + reset)) +
                                                     (len(vim_color + reset)))
    if status_window_enabled:
        print(line)
    time.sleep(0.08)
