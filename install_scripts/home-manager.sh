#!/usr/bin/env bash
set -euo pipefail

REPO_URL="https://github.com/Mikkelsej/home-manager.git"
CLONE_DIR="$HOME/home-manager"

echo "Installing Nix..."
curl -fsSL https://install.determinate.systems/nix | sh -s -- install --determinate

echo "Loading Nix environment..."
. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh

echo "Cloning config..."
git clone "$REPO_URL" "$CLONE_DIR"

echo "Switching config..."
nix run nixpkgs#home-manager -- switch -b backup --flake ~/home-manager#mikke

ZSH_PATH="$HOME/.nix-profile/bin/zsh"

if [ -x "$ZSH_PATH" ]; then
  # Ensure Zsh path is listed in /etc/shells
  if ! grep -Fxq "$ZSH_PATH" /etc/shells; then
    echo "Adding $ZSH_PATH to /etc/shells (needs sudo)..."
    echo "$ZSH_PATH" | sudo tee -a /etc/shells
  fi

  echo "Setting default shell to Zsh..."
  chsh -s "$ZSH_PATH"
else
  echo "Zsh not found at $ZSH_PATH"
fi


echo "Done!"
