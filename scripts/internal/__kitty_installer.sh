#!/bin/sh
# copied and modified from kitty https://github.com/kovidgoyal/kitty/blob/master/docs/installer.sh
# modified to allow passing a version number

# Copyright (C) 2018 Kovid Goyal <kovid at kovidgoyal.net>
#
# Distributed under terms of the GPLv3 license.

{ \unalias command; \unset -f command; } >/dev/null 2>&1
tdir=''
cleanup() {
    [ -n "$tdir" ] && {
        command rm -rf "$tdir"
        tdir=''
    }
}

die() {
    cleanup
    printf "\033[31m%s\033[m\n\r" "$*" > /dev/stderr;
    exit 1;
}

detect_network_tool() {
    if command -v curl 2> /dev/null > /dev/null; then
        fetch() {
            command curl -fL "$1"
        }
        fetch_quiet() {
            command curl -fsSL "$1"
        }
    elif command -v wget 2> /dev/null > /dev/null; then
        fetch() {
            command wget -O- "$1"
        }
        fetch_quiet() {
            command wget --quiet -O- "$1"
        }
    else
        die "Neither curl nor wget available, cannot download kitty"
    fi
}


detect_os() {
    arch=""
    case "$(command uname)" in
        'Darwin') OS="macos";;
        'Linux')
            OS="linux"
            case "$(command uname -m)" in
                amd64|x86_64) arch="x86_64";;
                aarch64*) arch="arm64";;
                armv8*) arch="arm64";;
                i386) arch="i686";;
                i686) arch="i686";;
                *) die "Unknown CPU architecture $(command uname -m)";;
            esac
            ;;
        *) die "kitty binaries are not available for $(command uname)"
    esac
}

expand_tilde() {
    tilde_less="${1#\~/}"
    [ "$1" != "$tilde_less" ] && tilde_less="$HOME/$tilde_less"
    printf '%s' "$tilde_less"
}

parse_args() {
    dest='~/.local'
    [ "$OS" = "macos" ] && dest="/Applications"
    launch='y'
    installer=''
    version='stable'
    while :; do
        case "$1" in
            dest=*) dest="${1#*=}";;
            launch=*) launch="${1#*=}";;
            installer=*) installer="${1#*=}";;
            version=*) version="${1#*=}";;
            "") break;;
            *) die "Unrecognized command line option: $1";;
        esac
        shift
    done
    dest=$(expand_tilde "${dest}")
    [ "$launch" != "y" -a "$launch" != "n" ] && die "Unrecognized command line option: launch=$launch"
    dest="$dest/kitty.app"
}


get_file_url() {
    url="https://github.com/kovidgoyal/kitty/releases/download/$1/kitty-$2"
    if [ "$OS" = "macos" ]; then
        url="$url.dmg"
    else
        url="$url-$arch.txz"
    fi
}

get_release_url() {
    if [ "$version" = 'stable' ]; then
      release_version=$(fetch_quiet "https://sw.kovidgoyal.net/kitty/current-version.txt")
    else
      release_version="$version"
    fi
    [ -z "$release_version" ] && die "Could not get kitty release version"
    get_file_url "v$release_version" "$release_version"
}


get_nightly_url() {
    get_file_url "nightly" "nightly"
}

get_download_url() {
    installer_is_file="n"
    case "$version" in
        "nightly") get_nightly_url ;;
        *) get_release_url ;;
    esac
}

download_installer() {
    tdir=$(command mktemp -d "/tmp/kitty-install-XXXXXXXXXXXX")
    [ "$installer_is_file" != "y" ] && {
        printf '%s\n\n' "Downloading from: $url"
        if [ "$OS" = "macos" ]; then
            installer="$tdir/kitty.dmg"
        else
            installer="$tdir/kitty.txz"
        fi
        fetch "$url" > "$installer" || die "Failed to download: $url"
        installer_is_file="y"
    }
}

linux_install() {
    command mkdir "$tdir/mp"
    command tar -C "$tdir/mp" "-xJof" "$installer" || die "Failed to extract kitty tarball"
    printf "%s\n" "Installing to $dest"
    command rm -rf "$dest" || die "Failed to delete $dest"
    command mv "$tdir/mp" "$dest" || die "Failed to move kitty.app to $dest"
}

macos_install() {
    command mkdir "$tdir/mp"
    command hdiutil attach "$installer" "-mountpoint" "$tdir/mp" || die "Failed to mount kitty.dmg"
    printf "%s\n" "Installing to $dest"
    command rm -rf "$dest"
    command mkdir -p "$dest" || die "Failed to create the directory: $dest"
    command ditto -v "$tdir/mp/kitty.app" "$dest"
    rc="$?"
    command hdiutil detach "$tdir/mp"
    [ "$rc" != "0" ] && die "Failed to copy kitty.app from mounted dmg"
}

exec_kitty() {
    if [ "$OS" = "macos" ]; then
        exec "open" "$dest"
    else
        exec "$dest/bin/kitty" "--detach"
    fi
    die "Failed to launch kitty"
}

main() {
    detect_os
    parse_args "$@"
    detect_network_tool
    get_download_url
    download_installer
    if [ "$OS" = "macos" ]; then
        macos_install
    else
        linux_install
    fi
    cleanup
    [ "$launch" = "y" ] && exec_kitty
    exit 0
}

main "$@"
