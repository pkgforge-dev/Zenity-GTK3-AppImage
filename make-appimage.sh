#!/bin/sh

set -eu

ARCH="$(uname -m)"
VERSION="$(cat ~/version)"
export ARCH VERSION
export OUTPATH=./dist
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export DESKTOP=DUMMY
export ICON=DUMMY
export URUNTIME_PRELOAD=1

# Deploy dependencies
quick-sharun /usr/bin/zenity

# Additional changes can be done in between here

# Turn AppDir into AppImage
quick-sharun --make-appimage
