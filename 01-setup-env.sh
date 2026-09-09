#!/usr/bin/env bash
# Runs automatically when the Codespace is created (see .devcontainer/devcontainer.json).
# Fast step only: system packages + repo tool. Sync/build are separate, manual, long-running scripts.
set -euo pipefail

echo "==> Installing build dependencies..."
sudo apt-get update
sudo apt-get install -y \
  git git-lfs gnupg flex bison build-essential zip curl \
  zlib1g-dev libc6-dev-i386 x11proto-core-dev libx11-dev \
  lib32z1-dev libgl1-mesa-dev libxml2-utils xsltproc unzip \
  fontconfig openjdk-17-jdk python3 rsync bc ccache tmux

git lfs install

echo "==> Installing repo tool..."
mkdir -p "$HOME/bin"
curl -s https://storage.googleapis.com/git-repo-downloads/repo > "$HOME/bin/repo"
chmod a+x "$HOME/bin/repo"
if ! grep -q 'HOME/bin' "$HOME/.bashrc" 2>/dev/null; then
  echo 'export PATH="$HOME/bin:$PATH"' >> "$HOME/.bashrc"
fi
export PATH="$HOME/bin:$PATH"

echo "==> Setting git identity (edit these or export before rebuild)..."
git config --global user.name "${GIT_USER_NAME:-Артём}"
git config --global user.email "${GIT_USER_EMAIL:-you@example.com}"
git config --global color.ui auto

echo "==> Configuring ccache..."
export USE_CCACHE=1
ccache -M 30G || true

cat <<'EOF'

==> Environment ready.

Next steps (run manually, ideally inside tmux so they survive disconnects):
  tmux new -s derpfest
  bash scripts/02-sync-source.sh <device_codename>
  bash scripts/03-build.sh <device_codename>

EOF
