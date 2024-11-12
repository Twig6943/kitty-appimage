#!/bin/sh

set -x

mkdir -p kitty/AppDir/usr
cd kitty

# Fetch the latest release tag from GitHub
LATEST_VERSION=$(curl -s https://api.github.com/repos/kovidgoyal/kitty/releases/latest | grep -Po '"tag_name": "\K.*?(?=")')
LATEST_URL="https://github.com/kovidgoyal/kitty/releases/download/$LATEST_VERSION/kitty-${LATEST_VERSION#v}-arm64.txz"  # Change to arm64

# Download the latest version of kitty for arm64
wget "$LATEST_URL" -O "kitty-latest-arm64.txz"

# Extract files
tar -xf "kitty-latest-arm64.txz" -C ./AppDir/usr

cd AppDir
KITTY_VERSION=$(./usr/bin/kitty --version | cut -d ' ' -f2)

mv ./usr/share/applications/kitty.desktop .

mkdir -p ./usr/lib \
	./usr/share/icons/hicolor/64x64/apps \
	./usr/share/icons/hicolor/32x32/apps \
	./usr/share/icons/hicolor/256x256/apps \
	./usr/share/icons/hicolor/24x24/apps \
	./usr/share/icons/hicolor/128x128/apps \
	./usr/share/icons/hicolor/48x48/apps

# Patch icon files
cp ./usr/share/icons/hicolor/256x256/apps/kitty.png .

sed -i -e 's|Exec=kitty|Exec=AppRun|g' kitty.desktop
echo "StartupWMClass=kitty" >> kitty.desktop
echo "X-AppImage-Version=$KITTY_VERSION" >> kitty.desktop

cd ..
cp ../AppRun ./AppDir

wget https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-arm64.AppImage  # Change to arm64 version
chmod +x appimagetool-arm64.AppImage
./appimagetool-arm64.AppImage AppDir -n -u "gh-releases-zsync|lucasscvvieira|kitty-appimage|stable|Kitty*.AppImage.zsync" "Kitty-$KITTY_VERSION-arm64.AppImage"  # Change to arm64 version
chmod +x Kitty*.AppImage

mkdir dist
mv Kitty*.AppImage* ./dist
