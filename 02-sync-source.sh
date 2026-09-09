#!/usr/bin/env bash
# Long-running (repo sync of a full AOSP-based tree). Run this inside tmux:
#   tmux new -s derpfest
#   bash scripts/02-sync-source.sh spes
# then detach with Ctrl+B, D and reattach later with: tmux attach -t derpfest
set -euo pipefail

export PATH="$HOME/bin:$PATH"

DEVICE_CODENAME="${1:-spes}"
WORKDIR="$HOME/derpfest"

mkdir -p "$WORKDIR"
cd "$WORKDIR"

echo "==> repo init (DerpFest, Android 17 branch)..."
repo init -u https://github.com/DerpFest-AOSP/android_manifest.git -b 17 --git-lfs

mkdir -p .repo/local_manifests
LOCAL_MANIFEST=".repo/local_manifests/local_manifest.xml"

if [ ! -f "$LOCAL_MANIFEST" ]; then
cat > "$LOCAL_MANIFEST" << EOF
<manifest>
  <!-- Replace YOUR_GH_USER and the revisions with your actual device/kernel/vendor repos -->
  <project name="YOUR_GH_USER/android_device_xiaomi_${DEVICE_CODENAME}" path="device/xiaomi/${DEVICE_CODENAME}" remote="github" revision="lineage-22.2" />
  <project name="YOUR_GH_USER/android_kernel_xiaomi_sm6225" path="kernel/xiaomi/sm6225" remote="github" revision="derpfest-17" />
  <project name="YOUR_GH_USER/android_vendor_xiaomi_${DEVICE_CODENAME}" path="vendor/xiaomi/${DEVICE_CODENAME}" remote="github" revision="lineage-22.2" />
</manifest>
EOF
  echo "==> Wrote a template to $LOCAL_MANIFEST — edit it with your real repo URLs, then re-run this script."
  exit 0
fi

echo "==> repo sync (this is the slow, disk-heavy part)..."
repo sync -c -j"$(nproc --all)" --force-sync --no-clone-bundle --no-tags

echo "==> Sync complete. Next: bash scripts/03-build.sh ${DEVICE_CODENAME}"
