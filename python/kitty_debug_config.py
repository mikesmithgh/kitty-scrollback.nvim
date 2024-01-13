from typing import List
from kitty.boss import Boss
from kitty.fast_data_types import get_options
from kitty.debug_config import debug_config
from kittens.tui.handler import result_handler
import re
import os


def main():
    raise SystemExit('Must be run as kitten kitty_debug_config')


@result_handler(type_of_input=None, no_ui=True, has_ready_notification=False)
def handle_result(args: List[str],
                  result: str,
                  target_window_id: int,
                  boss: Boss) -> None:
    del args[0]
    if len(args) != 1:
        raise Exception('Invalid number of arguments, expected filename')
    debug_info = debug_config(get_options())
    ansi_escape = re.compile(r'\x1b(?:[@-Z\\-_]|\[[0-?]*[ -/]*[@-~])')
    blank_block = re.compile(r'`\s+`')
    formatted_info = blank_block.sub('', ansi_escape.sub('`', debug_info))
    output = args[0]
    os.makedirs(os.path.dirname(output), exist_ok=True)
    with open(output, 'w') as f:
        f.write(formatted_info)
