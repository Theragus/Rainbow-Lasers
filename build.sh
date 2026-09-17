#!/usr/bin/env bash
# Packages the mod as <name>_<version>.zip, ready for the mod portal or for
# dropping straight into Factorio's mods folder.
set -euo pipefail

cd "$(dirname "$0")"

VERSION=$(python3 -c 'import json; print(json.load(open("RainbowLasers-2-1/info.json"))["version"])')
NAME=$(python3 -c 'import json; print(json.load(open("RainbowLasers-2-1/info.json"))["name"])')
MOD_DIR="$NAME"
ARCHIVE="${NAME}_${VERSION}"

rm -rf build
mkdir -p "build/${ARCHIVE}"
cp -r "${MOD_DIR}/." "build/${ARCHIVE}/"

(cd build && zip -r -q "${ARCHIVE}.zip" "${ARCHIVE}" -x '*.DS_Store' && rm -rf "${ARCHIVE}")

echo "build/${ARCHIVE}.zip"
unzip -l "build/${ARCHIVE}.zip"
