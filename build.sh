#!/bin/bash

set -e

HERE="$(dirname "$(readlink -f "$0")")"
BUILD_DIR="$1"
MX_VERSION="$2"

function generate_desktop_entry() {
  mkdir -p AppDir/usr/share/applications/
  cat << EOS > AppDir/usr/share/applications/stm32cubemx.desktop
[Desktop Entry]
Name=STM32CubeMX $MX_VERSION
Exec=AppRun
Type=Application
Icon=stm32cubemx
Categories=Development;
EOS
}

function generate_apprun() {
  cat << EOS > AppDir/AppRun
#!/bin/bash

HERE="\$(dirname "\$(readlink -f "\$0")")"
export LD_LIBRARY_PATH="\$HERE/usr/lib:\$LD_LIBRARY_PATH"
MX_DATA_DIR="\${XDG_DATA_HOME:-\$HOME/.local/share}/stm32cubemx-$MX_VERSION"

mkdir -p "\$MX_DATA_DIR"
exec "\$HERE/usr/bin/java" -Duser.home="\$MX_DATA_DIR" -jar "\$HERE/usr/share/MX/STM32CubeMX" "\$@"
EOS
  chmod +x AppDir/AppRun
}

function download_prerequisites() {
  if command -v wget; then
    DOWNLOAD_CMD="wget"
    DOWNLOAD_ARGS=()
  elif command -v curl; then
    DOWNLOAD_CMD="curl"
    DOWNLOAD_ARGS=("-O" "-L")
  else
    return 1
  fi
  $DOWNLOAD_CMD $DOWNLOAD_ARGS "https://github.com/AppImage/appimagetool/releases/download/1.9.0/appimagetool-x86_64.AppImage"
  $DOWNLOAD_CMD $DOWNLOAD_ARGS "https://sw-center.st.com/packs/resource/library/stm32cube_mx_v${MX_VERSION//./}-lin.zip"
}

function build_appdir() {
  unzip stm32cube_mx_v${MX_VERSION//./}-lin.zip
  unzip JavaJre.zip
  rsync -av "$HERE/AppDir/" AppDir/
  rsync -av jre/ AppDir/usr/
  rsync -av MX/ AppDir/usr/share/MX/
  generate_desktop_entry
  generate_apprun
}

function build_appimage() {
  chmod +x appimagetool-x86_64.AppImage
  ARCH=x86_64 ./appimagetool-x86_64.AppImage AppDir/
}

rm -rf "$BUILD_DIR"
mkdir "$BUILD_DIR"

pushd "$BUILD_DIR"
download_prerequisites
build_appdir
build_appimage
popd
