#!/usr/bin/env bash
set -euo pipefail

nix-shell -p git python3Full

curl -O https://raw.githubusercontent.com/Mikkelsej/Mikkelsej.github.io/refs/heads/master/install_scripts/python.py

python3 python.py

rm python.py

exit

git clone https://github.com/Mikkelsej/nixos.git

cp /etc/nixos/hardware-configuration.nix nixos/hosts/galaxybook/

sudo rm -rf /etc/nixos/

sudo nixos-rebuild switch --flake "path:nixos/#galaxybook" --install-bootloader