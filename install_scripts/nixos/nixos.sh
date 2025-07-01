#!/usr/bin/env bash
set -euo pipefail

nix-shell -p git python3Full --run '
  echo "[INFO] Downloading and running Python setup script..."
  curl -sL https://raw.githubusercontent.com/Mikkelsej/Mikkelsej.github.io/refs/heads/master/install_scripts/nixos/install.py -o install.py
  sudo python3 install.py
  rm install.py
'

echo "[INFO] Cloning NixOS configuration repo..."
git clone https://github.com/Mikkelsej/nixos.git

echo "[INFO] Copying hardware-configuration.nix..."
cp /etc/nixos/hardware-configuration.nix nixos/hosts/galaxybook/

echo "[INFO] Removing old configuration files ..."
sudo rm -rf /etc/nixos/

echo "[INFO] Running nixos-rebuild with flake..."
sudo nixos-rebuild switch --flake "path:nixos/#galaxybook" --install-bootloader

echo "[SUCCESS] Flake-based system activated and will persist on reboot."

reboot