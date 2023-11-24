#!/usr/bin/env bash

# dev utility to generate vimdoc from README

# preformat README.md
mkdir -p tmp_vimdoc_workdir
cp README.md tmp_vimdoc_workdir/README.md
# shellcheck disable=SC2016
sed -E -e's/\[!(NOTE|WARNING|IMPORTANT)\].*/[!\1]\n>/Ig' -e 's/.*<summary>(.+)<\/summary>/- VIMDOC_SUMMARY_HEADER `\1`\n/g' \
	-e 's/<a.*href.*"(.+)".*>(.+)<\/a>/\2 <\1>/g' <README.md >tmp_vimdoc_workdir/README.md

# panvimdoc
~/gitrepos/panvimdoc/panvimdoc.sh --project-name kitty-scrollback.nvim --input-file tmp_vimdoc_workdir/README.md --demojify true --vim-version 'NVIM v0.9+' --toc true --dedup-subheadings false --treesitter true

# postformat kitty-scrollback.nvim.txt

cp doc/kitty-scrollback.nvim.txt tmp_vimdoc_workdir/kitty-scrollback.nvim.txt
# shellcheck disable=SC2016
sed -E \
	-e 's/\[!(IMPORTANT)\]/|‼| |\1|/Ig' \
	-e 's/\[!(NOTE)\]/`ℹ` `\1` /Ig' \
	-e 's/\[!(WARNING)\]/*⚠* *\1* /Ig' \
	-e 's/^- VIMDOC_SUMMARY_HEADER(.*)/\n`-`\1/g' \
	-e 's/^[[:space:]]+(>.*)/\n\1/g' \
	-e 's/^[[:space:]]+(<.*)/\1/g' \
	<tmp_vimdoc_workdir/kitty-scrollback.nvim.txt >doc/kitty-scrollback.nvim.txt

# cleanup preformat README.md
rm -rf tmp_vimdoc_workdir
