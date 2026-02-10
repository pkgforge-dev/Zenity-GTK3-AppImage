#!/bin/sh

set -eu

ARCH="$(uname -m)"
export ARCH
export OUTPATH=./dist
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export DESKTOP=DUMMY
export ICON=DUMMY
export URUNTIME_PRELOAD=1
export ALWAYS_SOFTWARE=1

# Deploy dependencies
quick-sharun /usr/bin/zenity

# Additional changes can be done in between here

# Turn AppDir into AppImage
quick-sharun --make-appimage

# test the final app
quick-sharun --test ./dist/*.AppImage --info --text 'slophub' 
