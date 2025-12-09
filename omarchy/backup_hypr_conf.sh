#!/usr/bin/env bash
set -euo pipefail

# Back up the entire Hypr/Hyprland config directory (all files) into ./hypr
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
dest_dir="$script_dir/hypr"
mkdir -p "$dest_dir"

echo "[backup_hypr_conf.sh] Backing up Hypr/Hyprland configuration to $dest_dir"

# Candidate source locations (directories or single-file configs)
sources=( 
    "$HOME/.config/hypr"
    "$HOME/.config/hyprland"
    "$HOME/.config/hypr/hyprland.conf"
    "$HOME/.config/hyprland/hyprland.conf"
)

found=false
for src in "${sources[@]}"; do
    if [ -d "$src" ]; then
        echo "[backup_hypr_conf.sh] Found directory: $src"
        cp -a -- "$src/." "$dest_dir/"
        found=true
        break
    elif [ -f "$src" ]; then
        echo "[backup_hypr_conf.sh] Found file: $src"
        cp -a -- "$src" "$dest_dir/$(basename "$src")"
        found=true
        break
    fi
done

if [ "$found" = false ]; then
    echo "[backup_hypr_conf.sh] Warning: No Hypr/Hyprland configuration found in the usual locations."
fi

echo "[backup_hypr_conf.sh] Done."
