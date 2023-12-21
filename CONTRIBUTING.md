# kitty-scrollback.nvim

## Runnings tests
kitty-scrollback.nvim uses [plenary.nvim](https://github.com/nvim-lua/plenary.nvim)'s [plenary.tests_harness](https://github.com/nvim-lua/plenary.nvim?tab=readme-ov-file#plenarytest_harness) as its
testing harness.

- Execute tests from the command line (preferred)
```sh
make test
```

- Execute tests from Neovim
```vim
:PlenaryBustedDirectory tests
```

## Generating demos and wiki content (requires MacOS)

- `git clone git@github.com/mikesmithgh/kitty-scrollback.nvim.wiki.git`
- `cd kitty-scrollback.nvim.wiki`
- `./scripts/record_main_demo.lua`
- `./scripts/record_demo_videos.lua`
- `ls -1 assets/*.mov | xargs -I {} scripts/mov_to_gif.sh {}`
- Upload all `mov` files in the `assets` directory to Github by dragging them to a markdown file in the browser
- Copy all the generated embedded video urls and paste in `uploaded_movs` array in the `make_video_markdown_files.sh` script
- `./scripts/make_video_markdown_files.sh`
- `./scripts/make_adv_config_markdown_file.lua &> Advanced-Configuration.md`

## Troubleshooting

### Github Actions

#### Interactive debugging 

- Run the worklow [tests](https://github.com/mikesmithgh/kitty-scrollback.nvim/actions/workflows/tests.yml)
  - Check `enable_debug_vnc` to enable TurboVNC, ngrok, and tmate debugging
    - This allows you to connect to the Github runner via vnc (for GUI) and ssh
    - Troubleshooting:
      - If the Github runner timers out and requires a login, you can ssh into the tmate session and restart VNC.
      ```sh
      export PATH="/opt/TurboVNC/bin:$PATH"
      vncserver -kill :1
      vncserver -geometry 2560x1080 -SecurityTypes None
      ```
  - Check `enable_debug_tmate` to enable tmate debugging
    - This allows you to connect to the Github runner via ssh

#### Verbose logging 

- Enable verbose logging by running the action with [debug logging](https://docs.github.com/en/actions/monitoring-and-troubleshooting-workflows/enabling-debug-logging) enabled.
  - This can also be achieved by setting `RUNNER_DEBUG` to `1`, `RUNNER_DEBUG=1 make test`

