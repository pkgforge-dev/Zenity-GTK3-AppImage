#!/bin/sh

APP=Zenity-gtk3
APPDIR=Zenity.AppDir
SITE="https://github.com/Samueru-sama/zenity.git"

# CREATE DIRECTORIES
if [ -z "$APP" ]; then exit 1; fi
mkdir -p ./"$APP/$APPDIR" && cd ./"$APP/$APPDIR" || exit 1

# DOWNLOAD AND MAKE ZENITY
CURRENTDIR="$(readlink -f "$(dirname "$0")")" # DO NOT MOVE THIS
git clone "$SITE" && cd ./zenity && meson --prefix "$CURRENTDIR" . build && meson compile -C build && meson install -C build # NORMAL ERROR HERE, HAVEN'T FIXED
cd .. && find ./bin/* -type f -executable -exec sed -i -e "s|/usr|././|g" {} \; && echo "binary patched" && rm -rf ./zenity # Patch binary

# AppRun
cat >> ./AppRun << 'EOF'
#!/bin/sh
CURRENTDIR="$(readlink -f "$(dirname "$0")")"
export PATH="$CURRENTDIR/bin:$PATH"
export XDG_DATA_DIRS="$CURRENTDIR/share:$XDG_DATA_DIRS"
export ZENITY_DATA_DIR="$CURRENTDIR/share/zenity"
exec "$CURRENTDIR/bin/zenity" "$@"
EOF
chmod a+x ./AppRun
#APPVERSION=$(./AppRun --version) # This fails here because zenity needs a display to give you the version lol
APPVERSION=3.44
if [ -z "$APPVERSION" ]; then echo "Failed to get version from zenity"; exit 1; fi

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
cp ./share/zenity/zenity.png ./ && ln -s ./zenity.png ./.DirIcon || exit 1

# MAKE APPIMAGE
cd ..
APPIMAGETOOL=$(wget -q https://api.github.com/repos/probonopd/go-appimage/releases -O - | sed 's/"/ /g; s/ /\n/g' | grep -o 'https.*continuous.*tool.*86_64.*mage$')
wget -q "$APPIMAGETOOL" -O ./appimagetool && chmod a+x ./appimagetool

# Do the thing!
ARCH=x86_64 VERSION="$APPVERSION" ./appimagetool -s ./"$APPDIR"
ls ./*.AppImage || { echo "appimagetool failed to make the appimage"; exit 1; }
if [ -z "$APP" ]; then exit 1; fi # Being extra safe lol
mv ./*.AppImage .. && cd .. && rm -rf "./$APP"
echo "All Done!"
