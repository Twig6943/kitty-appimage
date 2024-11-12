#!/bin/sh

set -x

mkdir -p kitty/AppDir/usr
cd kitty

# Fetch the latest release tag from GitHub
LATEST_VERSION=$(curl -s https://api.github.com/repos/kovidgoyal/kitty/releases/latest | grep -Po '"tag_name": "\K.*?(?=")')
LATEST_URL="https://github.com/kovidgoyal/kitty/releases/download/$LATEST_VERSION/kitty-${LATEST_VERSION#v}-arm64.txz"  # ARM64 version

# Download the latest version of kitty for ARM64
echo "Downloading Kitty ARM64 version..."
wget "$LATEST_URL" -O "kitty-latest-arm64.txz"
if [ $? -ne 0 ]; then
    echo "Failed to download Kitty ARM64 version."
    exit 1
fi

# Extract files
echo "Extracting Kitty..."
tar -xf "kitty-latest-arm64.txz" -C ./AppDir/usr

cd AppDir
KITTY_VERSION=$(./usr/bin/kitty --version | cut -d ' ' -f2)

# Move the desktop file
mv ./usr/share/applications/kitty.desktop .

# Create icon directories
mkdir -p ./usr/lib \
    ./usr/share/icons/hicolor/64x64/apps \
    ./usr/share/icons/hicolor/32x32/apps \
    ./usr/share/icons/hicolor/256x256/apps \
    ./usr/share/icons/hicolor/24x24/apps \
    ./usr/share/icons/hicolor/128x128/apps \
    ./usr/share/icons/hicolor/48x48/apps

# Copy the kitty icon
cp ./usr/share/icons/hicolor/256x256/apps/kitty.png .

# Modify the desktop entry file
echo "Modifying the desktop entry..."
sed -i -e 's|Exec=kitty|Exec=AppRun|g' kitty.desktop
echo "StartupWMClass=kitty" >> kitty.desktop
echo "X-AppImage-Version=$KITTY_VERSION" >> kitty.desktop

cd ..
cp ../AppRun ./AppDir

# Download appimagetool for ARM64
echo "Downloading AppImageTool ARM64 version..."
wget https://github.com/AppImage/AppImageKit/releases/download/13/appimagetool-aarch64.AppImage -O appimagetool-aarch64.AppImage
if [ $? -ne 0 ]; then
    echo "Failed to download appimagetool for ARM64."
    exit 1
fi

# Make appimagetool executable
chmod +x appimagetool-aarch64.AppImage

# Build the AppImage
echo "Building the ARM64 AppImage..."
./appimagetool-aarch64.AppImage AppDir -n -u "gh-releases-zsync|lucasscvvieira|kitty-appimage|stable|Kitty*.AppImage.zsync" "Kitty-$KITTY_VERSION-arm64.AppImage"

# Make the final AppImage executable
chmod +x Kitty*.AppImage

# Move the built AppImage to dist directory
mkdir dist
mv Kitty*.AppImage* ./dist

echo "Build completed successfully!"
