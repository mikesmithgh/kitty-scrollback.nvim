#!/usr/bin/env python3
import itertools
import sys
import time
import os

heart_color = '\x1b[38;2;255;105;97m'
spinner_color = '\x1b[38;2;211;134;155m'
kitty_color = '\x1b[38;2;117;75;51m'
vim_color = '\x1b[38;2;24;139;37m'
reset = '\x1b[0m'

kitty = kitty_color + '󰄛' + reset
heart = heart_color + '' + reset
vim = vim_color + '' + reset

spinner = itertools.cycle(['⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏'])

while True:
    os.system('cls' if os.name == 'nt' else 'clear')
    size = os.get_terminal_size(sys.__stdout__.fileno())
    spin = spinner_color + next(spinner) + reset
    msg = f'{kitty} {heart} {vim}'
    line = f'{spin} {msg}'.rjust(size.columns + (len(spin) - 1) +
                                 (len(kitty) - 1) + (len(heart) - 1) +
                                 (len(vim) - 1))
    print(line)
    time.sleep(0.05)
