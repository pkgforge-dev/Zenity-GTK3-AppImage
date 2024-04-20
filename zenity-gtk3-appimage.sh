#!/bin/sh

APP=zenity-gtk3
#SITE="https://gitlab.gnome.org/GNOME/zenity/-/archive/zenity-3-44/zenity-zenity-3-44.tar.gz"

# CREATE DIRECTORIES
if [ -z "$APP" ]; then exit 1; fi
mkdir -p "./$APP" "./$APP/$APP.AppDir/usr/bin" "./$APP/$APP.AppDir/usr/share/zenity" && cd "./$APP" || exit 1

# DOWNLOAD AND BUILD ZENITY
#wget $SITE && tar fx ./*tar*
git clone https://github.com/aferrero2707/zenity.git && cd ./zenity && ./autogen.sh && make || exit 1

# PREPARE APPIMAGE
cd ..
mv ./zenity/src/zenity "./$APP.AppDir/usr/bin"
mv ./zenity/src/zenity.ui "./$APP.AppDir/usr/share/zenity" && mv ./zenity/data/* "./$APP.AppDir/usr/share/zenity"

# AppRun
cd "./$APP.AppDir" || exit 1
cat >> ./AppRun << 'EOF'
#!/bin/sh
CURRENTDIR="$(readlink -f "$(dirname "$0")")"
export XDG_DATA_DIRS="${CURRENTDIR}/usr/share/:${XDG_DATA_DIRS}"
export ZENITY_DATA_DIR="$CURRENTDIR/usr/share/zenity"
exec "$CURRENTDIR/usr/bin/zenity" "$@"
EOF
chmod a+x ./AppRun

# DESKTOP & ICON
#DESKTOP="https://gitlab.gnome.org/GNOME/zenity/-/raw/master/data/org.gnome.Zenity.desktop.in?ref_type=heads"  #wget "$DESKTOP" -O ./$APP.desktop # appimagetool complains with this .desktop file
cat >> ./$APP.desktop << 'EOF'
[Desktop Entry]
Name=Zenity
Comment=Display dialog boxes from the command line
Exec=zenity
Icon=zenity
Terminal=false
Type=Application
NoDisplay=true
StartupNotify=true
Categories=Utility;
X-GNOME-UsesNotifications=true
EOF
cp ./usr/share/zenity/zenity.png ./ || exit 1
ln -s ./zenity.png ./.DirIcon

# MAKE APPIMAGE
cd ..
APPIMAGETOOL=$(wget -q https://api.github.com/repos/probonopd/go-appimage/releases -O - | grep -v zsync | grep -i continuous | grep -i appimagetool | grep -i x86_64 | grep browser_download_url | cut -d '"' -f 4 | head -1)
wget -q "$APPIMAGETOOL" -O ./appimagetool && chmod a+x ./appimagetool

# Do the thing!
ARCH=x86_64 VERSION=$(./appimagetool -v | grep -o '[[:digit:]]*') ./appimagetool -s ./$APP.AppDir
ls ./*.AppImage || { echo "appimagetool failed to make the appimage"; exit 1; }

APPNAME=$(ls *AppImage)
APPVERSION=3.44
mv ./*AppImage ./"$APPVERSION"-"$APPNAME"
if [ -z "$APP" ]; then exit 1; fi # Being extra safe lol
mv ./*.AppImage .. && cd .. && rm -rf "./$APP"
echo "All Done!"
