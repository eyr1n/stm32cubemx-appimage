#!/bin/bash

set -e

HERE="$(dirname "$(readlink -f "$0")")"
TMP_PATH="$(mktemp -d)"
MX_VERSION="${1//./}"

cp -R AppDir/ "$TMP_PATH/"
pushd "$TMP_PATH"
wget https://github.com/AppImage/appimagetool/releases/download/1.9.0/appimagetool-x86_64.AppImage
wget "https://sw-center.st.com/packs/resource/library/stm32cube_mx_v${MX_VERSION}-lin.zip"
chmod +x appimagetool-x86_64.AppImage
unzip stm32cube_mx_v${MX_VERSION}-lin.zip
mv MX/ AppDir/usr/share/
unzip JavaJre.zip
rsync -av jre/ AppDir/usr/
popd

ARCH=x86_64 "$TMP_PATH/appimagetool-x86_64.AppImage" "$TMP_PATH/AppDir/"

rm -rf "$TMP_PATH"
