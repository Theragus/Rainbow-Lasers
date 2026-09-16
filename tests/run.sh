#!/usr/bin/env bash
# Loads the mod on top of the real base-game prototypes and checks the result.
# Needs lua5.4, python3, git.
set -euo pipefail

cd "$(dirname "$0")/.."

DATA_DIR="tests/factorio-data"
if [[ ! -d "$DATA_DIR" ]]; then
  echo "==> fetching base prototypes from wube/factorio-data"
  git clone --depth 1 https://github.com/wube/factorio-data.git "$DATA_DIR"
fi
echo "==> base version: $(python3 -c 'import json;print(json.load(open("'"$DATA_DIR"'/base/info.json"))["version"])')"

# Record the real pixel size of every shipped sheet, so the checks compare the
# prototype's frame grid against the actual images.
for f in RainbowLasers/graphics/*.png; do
  python3 - "$f" <<'PY'
import struct, sys, os
d = open(sys.argv[1], 'rb').read(33)
w, h = struct.unpack('>II', d[16:24])
print(w, h, os.path.basename(sys.argv[1]))
PY
done > tests/png-dims.txt

echo "==> syntax"
luac5.4 -p RainbowLasers/data-updates.lua && echo "  OK data-updates.lua"
python3 -m json.tool RainbowLasers/info.json > /dev/null && echo "  OK info.json"

echo "==> against real base prototypes"
lua5.4 tests/verify.lua

echo "==> edge cases"
lua5.4 tests/edge.lua

echo
echo "all checks passed"
