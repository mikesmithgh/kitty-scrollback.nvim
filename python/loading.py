#!/usr/bin/env python3
import itertools
import sys
import time
import os

time_color = '\x1b[38;2;150;140;129m'
heart_color = '\x1b[38;2;255;105;97m'
spinner_color = '\x1b[38;2;211;134;155m'
kitty_color = '\x1b[38;2;117;75;51m'
vim_color = '\x1b[38;2;24;139;37m'
reset = '\x1b[0m'

kitty = kitty_color + '󰄛' + reset
heart = heart_color + '' + reset
vim = vim_color + '' + reset

spinner = itertools.cycle(['⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏'])

start = time.time()
while True:
    os.system('cls' if os.name == 'nt' else 'clear')
    size = os.get_terminal_size(sys.__stdout__.fileno())
    time_progress = time_color + "{:.2f}s".format(time.time() - start) + reset
    spin = spinner_color + next(spinner) + reset
    msg = f'{kitty} {heart} {vim}'
    line = f'{time_progress} {spin} {msg}'.rjust(size.columns +
                                                 (len(time_color + reset)) +
                                                 (len(spinner_color + reset)) +
                                                 (len(kitty_color + reset)) +
                                                 (len(heart_color + reset)) +
                                                 (len(vim_color + reset)))
    print(line)
    time.sleep(0.08)
