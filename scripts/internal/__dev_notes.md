# Dev notes

## sed

```lua
  -- other sed filters that may come in handy
  -- .. [[-e 's/(.*)\x1b]8;.*;.*\x1b\\(.*)/\1\2/g' ]] -- remove url/files/hyperlinks
  -- .. [[-e 's/\x1b]133;[AC].*\x1b\\//g' ]] --replace shell integration prompt marks https://sw.kovidgoyal.net/kitty/shell-integration/#notes-for-shell-developers
  -- .. [[-e 's/(.*)\x1b\[\?25.\x1b\[.*;.*H\x1b\[(\?12.|.+ q)(.*)/\1\3/g' ]] -- remove control sequence added by --add-cursor flag see https://github.com/kovidgoyal/kitty/blob/ec8b7853c55897bfcee5997dbd7cea734bdc2982/kitty/window.py#L346
```

