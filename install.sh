#!/usr/bin/env bash
set -euo pipefail

REPO_URL="https://github.com/Mikkelsej/wsl-nix.git"
CLONE_DIR="$HOME/home-manager"

echo "Installing Nix..."
curl -fsSL https://install.determinate.systems/nix | sh -s -- install --determinate

echo "Loading Nix environment..."
. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

echo "Cloning config..."
git clone "$REPO_URL" "$CLONE_DIR"

echo "Switching config..."
nix run nixpkgs#home-manager -- switch -b backup --flake ~/home-manager#mikke

if command -v zsh >/dev/null; then
  echo "Setting Zsh as the default shell..."
  chsh -s "$(command -v zsh)"
else
  echo "Zsh is not installed — skipping chsh"
fi

echo "Done!"
