#!/bin/sh

set -eux
EXTRA_PACKAGES="https://raw.githubusercontent.com/pkgforge-dev/Anylinux-AppImages/refs/heads/main/useful-tools/get-debloated-pkgs.sh"

echo "Installing build dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm    \
	base-devel        \
	curl              \
	git               \
	libxtst           \
	meson             \
	pulseaudio        \
	wget              \
	xorg-server-xvfb  \
	zsync

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
wget --retry-connrefused --tries=30 "$EXTRA_PACKAGES" -O ./get-debloated-pkgs.sh
chmod +x ./get-debloated-pkgs.sh
./get-debloated-pkgs.sh gtk3-mini libxml2-mini

# Build zenity
git clone "https://gitlab.gnome.org/GNOME/zenity.git" ./zenity 
cd ./zenity
git checkout "zenity-3-44"
meson setup build --prefix=/usr
meson compile -C build
meson install --no-rebuild -C build
awk -F":|'" '/version:/{print $3; exit}' ./meson.build > ~/version
