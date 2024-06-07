#!/bin/sh
# Run directly from github with:
# sh -c "$(curl -s https://raw.githubusercontent.com/mikesmithgh/kitty-scrollback.nvim/main/scripts/mini.sh)"
# Other variants:
# sh -c "$(curl -s https://raw.githubusercontent.com/mikesmithgh/kitty-scrollback.nvim/main/scripts/mini.sh)" -- reset  # delete and reinstall
# env LIBGL_ALWAYS_SOFTWARE=1 sh -c "$(curl -s https://raw.githubusercontent.com/mikesmithgh/kitty-scrollback.nvim/main/scripts/mini.sh)" # useful in testing an a vm

set -eu
trap 'echo "EXIT detected with exit status $?"' EXIT

# OS temp dir & script working dir
TEMPDIR=$(dirname "$(mktemp -u)")
BASEDIR=$(
  cd "$(dirname "$0")"
  pwd -P
)

nvim_bin=${NVIM:-nvim}
plug_name=kitty-scrollback.nvim
plug_dir="${BASEDIR}/../../${plug_name}"
tmp_dir="${TEMPDIR}/${plug_name}.tmp"
tmp_rtp="${tmp_dir}/nvim/site/pack/vendor/start"
packpath="${tmp_dir}/nvim/site"

usage() {
  echo "Usage $0"
}

if [ "${1:-}" = "reset" ]; then
  rm -rf "${tmp_dir}"
fi

download_plugin() {
  repo="https://github.com/${1}/${2}"
  folder="${tmp_rtp}/${2}"
  if [ "${1:-}" = "reset" ]; then
    rm -rf "${folder}"
  fi
  if [ ! -d "$folder" ]; then
    printf "Downloading %s into %s..." "${repo}" "${folder}"
    git clone --depth 1 "${repo}" "${folder}"
  else
    echo "Updating '${repo}' in ${folder}..."
    git -C "${folder}" pull --rebase
  fi
}

mkdir -p "$tmp_rtp"

# if exists, link to local folder so we can test local changes
if [ -d "${plug_dir}" ]; then
  echo "Using local plugin ${plug_name} from '${plug_dir}'"
  ln -fs "${plug_dir}" "${tmp_rtp}"
else
  download_plugin "mikesmithgh" "$plug_name"
fi

tmp_plug_dir="${tmp_rtp}/${plug_name}"

printf "\n\t\033[38;2;167;192;128mctrl-c to quit\033[0m\n"

# run kitty
kitty --config="${tmp_rtp}/${plug_name}/scripts/kitty.conf" \
  --override "action_alias=kitty_scrollback_nvim kitten ${tmp_plug_dir}/python/kitty_scrollback_nvim.py --env HOME=${TEMPDIR} --env PACKPATH=${packpath} --nvim-args -u ${tmp_plug_dir}/scripts/init.lua" \
  --override "map kitty_mod+h kitty_scrollback_nvim" \
  --override "map kitty_mod+g kitty_scrollback_nvim --config ksb_builtin_last_cmd_output" \
  --override "mouse_map ctrl+shift+right press ungrabbed combine : mouse_select_command_output : kitty_scrollback_nvim --config ksb_builtin_last_visited_cmd_output" \
  kitten @ launch --cwd="${tmp_dir}" --hold printf "\n\t         \033[0m\033[38;2;167;192;128mkitty-scrollback.nvim\033[0m   \033[38;2;150;140;129mmini.sh                 \033[0m\n\t\033[38;2;150;140;129m🭽▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔🭾\033[0m\033[38;2;150;140;129m\n\t\033[38;2;150;140;129m▏\033[0m\033[38;2;167;192;128mkitty_mod+h\033[0m             \033[38;2;150;140;129mscrollback buffer      ▕\033[0m\n\t\033[38;2;150;140;129m▏\033[0m\033[38;2;167;192;128mkitty_mod+g \033[0m            \033[38;2;150;140;129mlast command output    ▕\033[0m\n\t\033[38;2;150;140;129m▏\033[0m\033[38;2;167;192;128mctrl+shift+right-click\033[0m  \033[38;2;150;140;129mselected command output▕\033[0m\n\t\033[38;2;150;140;129m🭼▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁🭿\033[0m\n"

cat <<EOF



	mini.sh was copied and modified from fzf-lua, https://github.com/ibhagwan/fzf-lua
	$plug_name $(printf '\033[0;31m')♥$(printf '\033[0m') fzf-lua


EOF
