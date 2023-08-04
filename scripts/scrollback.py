from typing import Any, Dict

from kitty.boss import Boss
from kitty.window import Window


# def on_resize(b: Boss, w: Window, data: Dict[str, Any])->None:
#     f = open("/Users/mike/gitrepos/scrollback.nvim/scripts/resize.txt", "a")
#     f.write(f"resize boss: {b}\n")
#     f.write(f"resize window: {w}\n")
#     f.write(f"resize data: {d}\n")
#     f.close()
#
# def on_focus_change(b: Boss, w: Window, data: Dict[str, Any])->None:
#     f = open("/Users/mike/gitrepos/scrollback.nvim/scripts/focus.txt", "a")
#     f.write(f"focus boss: {b}\n")
#     f.write(f"focus window: {w}\n")
#     f.write(f"focus data: {d}\n")
#     f.close()

def on_close(b: Boss, w: Window, data: Dict[str, Any])->None:
    b.call_remote_control(w, ('send-text', '--all', 'printf "%s"', '"all"', '\n'))
    b.call_remote_control(w, ('send-text', '--match=state:focused', 'printf "%s"', '"overlay_parent"', '\n'))
    # f = open("/Users/mike/gitrepos/scrollback.nvim/scripts/close.txt", "a")
    # f.write(f"close boss: {b}\n")
    # f.write(f"close window: {w}\n")
    # f.write(f"close data: {d}\n")
    # f.close()

