#!/bin/sh

APP=clipman
APPDIR="$APP".AppDir

# CREATE DIRECTORIES
if [ -z "$APP" ]; then exit 1; fi
mkdir -p ./"$APP" && cd ./"$APP" || exit 1

# DOWNLOAD AND BUILD CLIPMAN STATICALLY
CURRENTDIR="$(readlink -f "$(dirname "$0")")" # DO NOT MOVE THIS
CFLAGS='-static -O3'
LDFLAGS='-static'
git clone --recursive https://github.com/Samueru-sama/xfce4-clipman-plugin.git \
&& cd ./xfce4-clipman* && ./autogen.sh && make && make install DESTDIR="$CURRENTDIR" || exit 1
cd .. && rm -rf ./xfce4-clipman-plugin && mv ./usr/local ./"$APPDIR" && rmdir ./usr || exit 1

# PREPARE APPIMAGE
cd ./"$APPDIR" && cp ./share/applications/xfce4-clipman.desktop ./xfce4-clipman-plugin.desktop \
&& cp ./share/icons/hicolor/scalable/apps/*svg ./xfce4-clipman-plugin.svg \
&& ln -s ./*.svg ./.DirIcon || exit 1

# THIS IS A HACK
LIBSPATH=$(ldd ./bin/xfce4-clipman | awk '{print $3}')
mkdir ./lib 
cp $LIBSPATH ./lib
rm -f ./lib/libc.so* ./lib/libcrypto.so* ./lib/libstdc++.so* ./lib/libgnutls.so* ./lib/ld-linux* \
./lib/libgio* ./lib/libglib* ./lib/libX11* ./lib/libmvec* ./lib/libm.* ./lib/libsl.* ./lib/libresolv* \
./lib/libnss* ./lib/libc.so* ./lib/libm.so* ./lib/libBroken* ./lib/libc_malloc*

# AppRun
cat >> ./AppRun << 'EOF'
#!/bin/bash
CURRENTDIR="$(dirname "$(readlink -f "$0")")"
export PATH="$PATH:$CURRENTDIR/bin"
export LD_LIBRARY_PATH="/lib:/lib64:/usr/lib:/usr/lib64:$CURRENTDIR/lib:$LD_LIBRARY_PATH"

if [ "$1" = "history" ]; then
	"$CURRENTDIR"/bin/xfce4-clipman-history "${@:2}"
elif [ "$1" = "settings" ]; then
	"$CURRENTDIR"/bin/xfce4-clipman-settings "${@:2}"
elif [ "$1" = "popup" ]; then
	"$CURRENTDIR"/bin/xfce4-popup-clipman "${@:2}"
elif [ "$1" = "start" ]; then
	 "$CURRENTDIR"/bin/xfce4-clipman "${@:2}"
else
	echo "Options are: 'history' 'settings' 'popup' and 'start'"
	echo "Use 'start' to start clipman daemon in the backgroud"
fi
EOF
chmod a+x ./AppRun
APPVERSION=notray

# Do the thing!
cd ..
APPIMAGETOOL=$(wget -q https://api.github.com/repos/probonopd/go-appimage/releases -O - | sed 's/"/ /g; s/ /\n/g' | grep -o 'https.*continuous.*tool.*86_64.*mage$')
wget -q "$APPIMAGETOOL" -O ./appimagetool && chmod a+x ./appimagetool
ARCH=x86_64 VERSION="$APPVERSION" ./appimagetool -s ./"$APPDIR"
ls ./*.AppImage || { echo "appimagetool failed to make the appimage"; exit 1; }
if [ -z "$APP" ]; then exit 1; fi # Being extra safe lol
mv ./*.AppImage .. && cd .. && rm -rf ./"$APP"
echo "All Done!"
