#!/usr/bin/env python3
import itertools
import sys
import time
import os

default_color = '#ffffff'


def hex_to_fg_color(hex):
    h = hex.lstrip('#')
    (r, g, b) = tuple(int(h[i:i + 2], 16) for i in (0, 2, 4))
    return f'\x1b[38;2;{r};{g};{b}m'


def env_to_fg_color(name):
    hex_color = os.environ.get(name, default_color)
    return hex_to_fg_color(hex_color)


style_simple = os.environ.get('KITTY_SCROLLBACK_NVIM_STYLE_SIMPLE',
                              False).lower() == 'true'
status_window_enabled = os.environ.get(
    'KITTY_SCROLLBACK_NVIM_STATUS_WINDOW_ENABLED',
    False).lower() == 'true'
show_timer = os.environ.get('KITTY_SCROLLBACK_NVIM_SHOW_TIMER',
                            False).lower() == 'true'

timer_color = env_to_fg_color(
    'KITTY_SCROLLBACK_NVIM_STATUS_WIN_NORMAL_HIGHLIGHT')
heart_color = env_to_fg_color(
    'KITTY_SCROLLBACK_NVIM_STATUS_WIN_HEART_ICON_HIGHLIGHT')
spinner_color = env_to_fg_color(
    'KITTY_SCROLLBACK_NVIM_STATUS_WIN_SPINNER_ICON_HIGHLIGHT')
kitty_color = env_to_fg_color(
    'KITTY_SCROLLBACK_NVIM_STATUS_WIN_KITTY_ICON_HIGHLIGHT')
nvim_color = env_to_fg_color(
    'KITTY_SCROLLBACK_NVIM_STATUS_WIN_NVIM_ICON_HIGHLIGHT')
reset = '\x1b[0m'

kitty_icon = os.environ.get('KITTY_SCROLLBACK_NVIM_KITTY_ICON', '󰄛')
heart_icon = os.environ.get('KITTY_SCROLLBACK_NVIM_HEART_ICON', '󰣐')
nvim_icon = os.environ.get('KITTY_SCROLLBACK_NVIM_NVIM_ICON', '')

kitty = kitty_color + kitty_icon + reset
heart = heart_color + heart_icon + reset
vim = nvim_color + nvim_icon + reset

if style_simple:
    spinner = itertools.cycle(['-', '-', '\\', '\\', '|', '|', '/', '/'])
else:
    spinner = itertools.cycle(
        ['⠋',
         '⠙',
         '⠹',
         '⠸',
         '⠼',
         '⠴',
         '⠦',
         '⠧',
         '⠇',
         '⠏'])

start = time.time()
quit_msg = f'{timer_color}(ctrl+c to quit)'
time_elapsed = 0
close_threshold_seconds = 14.5
hide_timer_threshold_seconds = 4.5
while True and time_elapsed < close_threshold_seconds:
    if status_window_enabled:
        os.system('cls' if os.name == 'nt' else 'clear')
        size = os.get_terminal_size(sys.__stdout__.fileno())
        time_elapsed = time.time() - start
        time_elapsed_secs = '{:.1f}s'.format(time_elapsed)
        time_progress = f'{timer_color}{time_elapsed_secs}{reset}'
        if style_simple:
            actual_timer = time_progress if (show_timer and time_progress) or (
                time_elapsed
                and time_elapsed) > hide_timer_threshold_seconds else ''
            actual_timer_color = timer_color if actual_timer else ''
            spin = spinner_color + next(
                spinner
            ) + reset + timer_color + ' kitty-scrollback.nvim' + reset
            ll = f'{actual_timer} {spin} '
            line = ll.rjust(size.columns +
                            (len(actual_timer_color +
                                 reset if actual_timer_color else '')) +
                            (len(timer_color + reset)) +
                            (len(spinner_color + reset)))

        else:
            spin = spinner_color + next(spinner) + reset
            msg = f'{kitty} {heart} {vim} '
            actual_timer = time_progress if (show_timer and time_progress) or (
                time_elapsed
                and time_elapsed) > hide_timer_threshold_seconds else ''
            actual_timer_color = timer_color if actual_timer else ''
            line = f'{actual_timer} {spin} {msg}'.rjust(
                size.columns + (len(actual_timer_color +
                                    reset if actual_timer_color else '')) +
                (len(spinner_color + reset)) + (len(kitty_color + reset)) +
                (len(heart_color + reset)) + (len(nvim_color + reset)))
        print(line)
        if time_elapsed > 4.9:
            print(quit_msg.rjust(size.columns + len(timer_color)))
    time.sleep(0.08)
