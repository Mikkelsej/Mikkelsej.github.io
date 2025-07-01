#!/usr/bin/env python3

import os
import subprocess

CONFIG_PATH = "/etc/nixos/configuration.nix"
TEMP_NIX_PATH = "/etc/nixos/temp.nix"

TEMP_NIX_CONTENT = """\
{ config, pkgs, ... }:

{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  environment.systemPackages = with pkgs; [
    git
  ];
}
"""

def file_contains(path, text):
    with open(path, "r") as f:
        return text in f.read()

def insert_import_after_hardware_config(config_path, import_path):
    with open(config_path, "r") as f:
        lines = f.readlines()

    for i, line in enumerate(lines):
        if "hardware-configuration.nix" in line:
            # Insert the new import on the next line
            indent = line[:len(line) - len(line.lstrip())]
            lines.insert(i + 1, f"{indent}  {import_path}\n")
            break
    else:
        raise Exception("hardware-configuration.nix import not found in configuration.nix")

    with open(config_path, "w") as f:
        f.writelines(lines)

def main():
    print(f"[INFO] Writing {TEMP_NIX_PATH}")
    with open(TEMP_NIX_PATH, "w") as f:
        f.write(TEMP_NIX_CONTENT)

    if not file_contains(CONFIG_PATH, "temp.nix"):
        print(f"[INFO] Patching {CONFIG_PATH} to import temp.nix")
        insert_import_after_hardware_config(CONFIG_PATH, "./temp.nix")
    else:
        print(f"[INFO] temp.nix already imported in {CONFIG_PATH}")

    print("[INFO] Running nixos-rebuild switch...")
    subprocess.run(["sudo", "nixos-rebuild", "switch"], check=True)

    print("[SUCCESS] System rebuilt with flake support and Git installed.")

if __name__ == "__main__":
    if os.geteuid() != 0:
        print("This script must be run as root (sudo).")
        exit(1)
    main()
