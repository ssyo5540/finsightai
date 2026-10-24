#!/usr/bin/env bash
# Renders the FinSight icon and splash artwork from branding/src/*.html with
# headless Chrome, then regenerates the native icons and splash screens.
#   CHROME=/path/to/chrome branding/render.sh
set -euo pipefail
cd "$(dirname "$0")"
CHROME="${CHROME:-/Applications/Google Chrome.app/Contents/MacOS/Google Chrome}"
PROFILE="$(mktemp -d)"
trap 'rm -rf "$PROFILE"' EXIT

render() { # name width height
  "$CHROME" --headless=new --disable-gpu --no-first-run --hide-scrollbars \
    --user-data-dir="$PROFILE" --allow-file-access-from-files \
    --force-device-scale-factor=1 --default-background-color=00000000 \
    --window-size="$2,$3" --virtual-time-budget=2000 \
    --screenshot="$PWD/$1.png" "file://$PWD/src/$1.html" >/dev/null 2>&1
  echo "rendered $1.png ($2x$3)"
}

render icon 1024 1024
render icon_background 1024 1024
render icon_foreground 1024 1024
render splash_background 1290 2796
render splash_logo 960 640
render splash_android12 1152 1152

cd ..
dart run flutter_launcher_icons
dart run flutter_native_splash:create

# flutter_launcher_icons rewrites this unrelated Xcode setting; keep YES.
sed -i '' 's/ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = AppIcon;/ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = YES;/' \
  ios/Runner.xcodeproj/project.pbxproj
# Paint the launch view in the gradient's mid-tone (#8E2A0C) instead of white,
# so nothing flashes white before the background image draws.
sed -i '' 's/<color key="backgroundColor" red="1" green="1" blue="1" alpha="1" colorSpace="custom" customColorSpace="sRGB"\/>/<color key="backgroundColor" red="0.557" green="0.165" blue="0.047" alpha="1" colorSpace="custom" customColorSpace="sRGB"\/>/' \
  ios/Runner/Base.lproj/LaunchScreen.storyboard
