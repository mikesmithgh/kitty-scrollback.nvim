from typing import List
from kitty.boss import Boss
from kittens.tui.handler import result_handler
from kitty.fast_data_types import click_mouse_cmd_output


def main():
    raise SystemExit('Must be run as kitten kitty_scroll_prompt')


@result_handler(type_of_input=None, no_ui=True, has_ready_notification=False)
def handle_result(args: List[str],
                  result: str,
                  target_window_id: int,
                  boss: Boss) -> None:
    del args[0]
    direction = -1  # default to one previous
    if len(args) > 0:
        direction = int(args[0])
    select_cmd_output = False
    if len(args) > 1:
        select_cmd_output = (args[1].lower() == 'true')
    w = boss.window_id_map.get(target_window_id)
    if w is not None:
        if direction == 0:
            click_mouse_cmd_output(w.os_window_id,
                                   w.tab_id,
                                   w.id,
                                   select_cmd_output)
            w.mouse_handle_click('prompt')
        else:
            w.scroll_to_prompt(direction)
            w.mouse_handle_click('prompt')
