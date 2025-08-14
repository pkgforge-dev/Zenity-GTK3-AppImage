#!/bin/sh

set -eux

ARCH="$(uname -m)"

# Build zenity
git clone "https://gitlab.gnome.org/GNOME/zenity.git" ./zenity && (
	cd ./zenity
	git checkout "zenity-3-44"
	meson setup build --prefix=/usr
	meson compile -C build
	meson install --no-rebuild -C build
)

# Prepare AppDir
VERSION="$(awk -F":|'" '/version:/{print $3; exit}' ./zenity/meson.build)"
[ -n "$VERSION" ] && echo "$VERSION" > ~/version

URUNTIME="https://raw.githubusercontent.com/pkgforge-dev/Anylinux-AppImages/refs/heads/main/useful-tools/uruntime2appimage.sh"
SHARUN="https://raw.githubusercontent.com/pkgforge-dev/Anylinux-AppImages/refs/heads/main/useful-tools/quick-sharun.sh"

export OUTNAME=zenity-"$VERSION"-anylinux-"$ARCH".AppImage
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export DESKTOP=DUMMY
export ICONs=DUMMY
export PATH_MAPPING_RELATIVE=1 # zenity is hardcoded to look for files in /usr/share

wget --retry-connrefused --tries=30 "$SHARUN" -O ./quick-sharun
chmod +x ./quick-sharun
./quick-sharun /usr/bin/zenity

# MAKE APPIMAGE WITH URUNTIME
wget --retry-connrefused --tries=30 "$URUNTIME" -O ./uruntime2appimage
chmod +x ./uruntime2appimage
./uruntime2appimage


# make appbundle
wget --retry-connrefused --tries=30 \
	"https://github.com/xplshn/pelf/releases/latest/download/pelf_$ARCH" -O ./pelf
chmod +x ./pelf
echo "Generating [dwfs]AppBundle..."
UPINFO="$(echo "$UPINFO" | sed 's#.AppImage.zsync#*.AppBundle.zsync#g')"
./pelf --add-appdir ./AppDir \
	--appimage-compat                         \
	--add-updinfo "$UPINFO"                   \
	--appbundle-id="zenity#github.com/$GITHUB_REPOSITORY:$VERSION@$(date +%d_%m_%Y)" \
	--compression "-C zstd:level=22 -S26 -B8" \
	--output-to "zenity-${VERSION}-anylinux-${ARCH}.dwfs.AppBundle"
zsyncmake ./*.AppBundle -u ./*.AppBundle

mkdir -p ./dist
mv -v ./*.AppImage*  ./dist
mv -v ./*.AppBundle* ./dist

echo "All Done!"
