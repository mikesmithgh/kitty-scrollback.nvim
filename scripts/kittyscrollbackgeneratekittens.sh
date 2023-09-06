#!/usr/bin/env bash
nvim --headless +'KittyScrollbackGenerateKittens!' +'set nonumber' +'set norelativenumber' +'%print' +'quit!' 2>&1
printf '\n'
