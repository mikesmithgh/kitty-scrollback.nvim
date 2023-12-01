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

