# kitty-scrollback.nvim

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
  - Check `enable_debug_tmate` to enable tmate debugging
    - This allows you to connect to the Github runner via ssh

#### Verbose logging 

- Enable verbose logging by running the action with [debug logging](https://docs.github.com/en/actions/monitoring-and-troubleshooting-workflows/enabling-debug-logging) enabled.
  - This can also be achieved by setting `RUNNER_DEBUG` to `1`, `RUNNER_DEBUG=1 make test`

