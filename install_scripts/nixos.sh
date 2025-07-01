#!/usr/bin/env bash
set -euo pipefail

nix-shell --experimental-features 'nix-command flakes' -p git

git clone https://github.com/Mikkelsej/nixos.git

cp /etc/nixos/hardware-configuration.nix nixos/hosts/galaxybook/

sudo rm -rf /etc/nixos/

sudo nixos-rebuild switch --flake "path:nixos/#galaxybook"