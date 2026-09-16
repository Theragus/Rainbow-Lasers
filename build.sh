#!/usr/bin/env bash
# Packages the mod as RainbowLasers_<version>.zip, ready for the mod portal or for
# dropping straight into Factorio's mods folder.
set -euo pipefail

cd "$(dirname "$0")"

VERSION=$(python3 -c 'import json; print(json.load(open("RainbowLasers/info.json"))["version"])')
NAME="RainbowLasers_${VERSION}"

rm -rf build
mkdir -p "build/${NAME}"
cp -r RainbowLasers/. "build/${NAME}/"

(cd build && zip -r -q "${NAME}.zip" "${NAME}" -x '*.DS_Store' && rm -rf "${NAME}")

echo "build/${NAME}.zip"
unzip -l "build/${NAME}.zip"
