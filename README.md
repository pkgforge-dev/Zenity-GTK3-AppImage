# Zenity-GTK3-AppImage
Unofficial AppImage of Zenity [GTK3 Version](https://gitlab.gnome.org/GNOME/zenity/-/tree/zenity-3-44?ref_type=heads)

Useful for GTK3 users Xfce4 and WM users as the newer Zenity package uses GTK4 instead of GTK3 and as result you may run into this whole mess in trying to patch it to use the right theme: ![Gnome moment](https://github.com/Samueru-sama/Zenity-GTK3-AppImage/assets/36420837/3e5586a2-f21d-4e96-89c9-3becc1642fdc)

You can also run the `zenity-gtk3-appimage.sh` script in your machine to make the AppImage, provided it has all the dependencies needed to build Zenity (meson, gtk3, etc). 

It is possible that these appimages may fail to work with appimagelauncher, since appimagelauncher is pretty much dead I recommend this alternative: https://github.com/ivan-hc/AM

This appimage works without fuse2 as it can use fuse3 instead.
