#!/bin/sh

set -eu
ARCH=$(uname -m)

echo "Installing build dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm \
	base-devel        \
	itstool           \
	libxtst           \
	meson             \
	pulseaudio        \
	zsync

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs gtk3-mini libxml2-mini gdk-pixbuf2-mini librsvg-mini

# Build zenity
git clone "https://gitlab.gnome.org/GNOME/zenity.git" ./zenity 
cd ./zenity
git checkout "zenity-3-44"
meson setup build --prefix=/usr
meson compile -C build
meson install --no-rebuild -C build
awk -F":|'" '/version:/{print $3; exit}' ./meson.build > ~/version
