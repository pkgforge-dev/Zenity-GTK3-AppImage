#!/bin/sh

set -eu

export ARCH="$(uname -m)"
export APPIMAGE_EXTRACT_AND_RUN=1

REPO="https://gitlab.gnome.org/GNOME/zenity.git"
APPIMAGETOOL="https://github.com/AppImage/appimagetool/releases/download/continuous/appimagetool-$ARCH.AppImage"
UPINFO="gh-releases-zsync|$(echo $GITHUB_REPOSITORY | tr '/' '|')|latest|*$ARCH.AppImage.zsync"
LIB4BIN="https://raw.githubusercontent.com/VHSgunzo/sharun/refs/heads/main/lib4bin"

# Prepare AppDir
mkdir -p ./AppDir
cd ./AppDir

git clone "$REPO" ./zenity && (
	cd ./zenity
	git checkout "zenity-3-44"
	meson setup build  --prefix=/usr
	meson compile -C build
	DESTDIR=../../ meson install --no-rebuild -C build
)

mv ./usr/share ./
mv ./usr ./shared
rm -rf ./zenity ./share/help

# zenity is hardcoded to look for files in /usr/share
# we will fix it with binary patching
sed -i 's|/usr/share|././/share|g' ./shared/bin/zenity
echo 'SHARUN_WORKING_DIR=${SHARUN_DIR}' > ./.env

# bundle dependencies
wget "$LIB4BIN" -O ./lib4bin
chmod +x ./lib4bin
xvfb-run -a -- ./lib4bin -p -v -s -k -e \
	./shared/bin/zenity -- --question --text "English or Spanish?"
./lib4bin -p -v -s -k \
	/usr/lib/gdk-pixbuf-*/*/*/* \
	/usr/lib/gio/modules/libgvfsdbus*

ln ./sharun ./AppRun
./sharun -g

echo '[Desktop Entry]
Name=Zenity
Comment=Display dialog boxes from the command line
Exec=zenity
Terminal=false
Type=Application
NoDisplay=true
StartupNotify=true
Categories=Utility
Icon=zenity' > ./zenity.desktop
touch ./zenity.png

export VERSION="$(xvfb-run -a -- ./AppRun --version)"
echo "$VERSION" > ~/version

# MAKE APPIAMGE WITH FUSE3 COMPATIBLE APPIMAGETOOL
cd ..
wget "$APPIMAGETOOL" -O ./appimagetool
chmod +x ./appimagetool
./appimagetool -n -u "$UPINFO" \
	"$PWD"/AppDir "$PWD"/zenity-"$VERSION"-anylinux-"$ARCH".AppImage

wget -qO ./pelf "https://github.com/xplshn/pelf/releases/latest/download/pelf_$ARCH"
chmod +x ./pelf
echo "Generating [dwfs]AppBundle..."
UPINFO="gh-releases-zsync|$(echo $GITHUB_REPOSITORY | tr '/' '|')|latest|*$ARCH.dwfs.AppBundle.zsync"
./pelf --add-appdir ./AppDir \
	--appimage-compat                         \
	--add-updinfo "$UPINFO"                   \
	--appbundle-id="zenity#github.com/$GITHUB_REPOSITORY:$VERSION@$(date +%d_%m_%Y)" \
	--compression "-C zstd:level=22 -S26 -B8" \
	--output-to "zenity-${VERSION}-anylinux-${ARCH}.dwfs.AppBundle"

echo "All Done!"
