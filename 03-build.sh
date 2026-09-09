#!/usr/bin/env bash
# Long-running (the actual ROM build). Also run inside tmux:
#   tmux new -s derpfest
#   bash scripts/03-build.sh spes
set -euo pipefail

DEVICE_CODENAME="${1:-spes}"
WORKDIR="$HOME/derpfest"
cd "$WORKDIR"

export USE_CCACHE=1

# shellcheck disable=SC1091
source build/envsetup.sh
lunch "lineage_${DEVICE_CODENAME}-cp2a-user"
m derp -j"$(nproc --all)"

echo "==> Build finished. Output in out/target/product/${DEVICE_CODENAME}/"
