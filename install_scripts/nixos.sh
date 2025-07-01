#!/usr/bin/env bash
set -euo pipefail

echo "[INFO] Cloning Repo ..."
nix-shell -p git --run '
  git clone https://github.com/Mikkelsej/nixos.git
'

echo "[INFO] Copying hardware-configuration.nix..."
cp /etc/nixos/hardware-configuration.nix nixos/hosts/galaxybook/

echo "[INFO] Removing old configuration files ..."
sudo rm -rf /etc/nixos/

echo "[INFO] Running nixos-rebuild with flake..."
sudo nixos-rebuild switch --flake "path:nixos/#galaxybook" --install-bootloader

echo "[DONE]"

reboot