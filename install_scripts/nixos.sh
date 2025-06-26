#!/usr/bin/env bash

set -euo pipefail

# === Config ===
REPO_URL="https://github.com/yourusername/your-nixos-config.git"
CLONE_DIR="/home/nixos"
HOSTNAME="$(hostname)"  # Assumes your flake uses the machine's hostname as the flake host
SYSTEM_NIX_DIR="/etc/nixos"

# === Step 0: Ensure git is installed ===
if ! command -v git &>/dev/null; then
  echo "Git not found. Installing git..."
  sudo nix-env -iA nixpkgs.git
fi

# === Step 1: Enable flakes ===
echo "Enabling flakes in /etc/nix/nix.conf..."

sudo mkdir -p /etc/nix
if ! grep -q "experimental-features" /etc/nix/nix.conf 2>/dev/null; then
  echo "Adding flakes support to /etc/nix/nix.conf"
  echo "experimental-features = nix-command flakes" | sudo tee -a /etc/nix/nix.conf >/dev/null
else
  echo "Flakes already enabled or partially configured."
fi

# === Step 2: Clone flake repo ===
echo "Cloning flake config to $CLONE_DIR..."

if [ -d "$CLONE_DIR" ]; then
  echo "Directory $CLONE_DIR already exists. Backing up to ${CLONE_DIR}.bak"
  mv "$CLONE_DIR" "${CLONE_DIR}.bak"
fi

git clone "$REPO_URL" "$CLONE_DIR"

# === Step 3: Move existing configuration ===
echo "Moving current NixOS configuration into flake..."

mkdir -p "$CLONE_DIR/hosts/$HOSTNAME"

# Move hardware-configuration.nix
if [ -f "$SYSTEM_NIX_DIR/hardware-configuration.nix" ]; then
  sudo mv "$SYSTEM_NIX_DIR/hardware-configuration.nix" "$CLONE_DIR/hosts/$HOSTNAME/"
else
  echo "Warning: hardware-configuration.nix not found in $SYSTEM_NIX_DIR"
fi

# Move configuration.nix
if [ -f "$SYSTEM_NIX_DIR/configuration.nix" ]; then
  sudo mv "$SYSTEM_NIX_DIR/configuration.nix" "$CLONE_DIR/hosts/$HOSTNAME/"
else
  echo "Warning: configuration.nix not found in $SYSTEM_NIX_DIR"
fi

# === Step 4: Rebuild ===
echo "Rebuilding system from flake..."

sudo nixos-rebuild switch --flake "$CLONE_DIR#$HOSTNAME"

echo "✅ Migration to flake-based setup complete!"
