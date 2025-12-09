#!/usr/bin/env bash
set -euo pipefail

# Back up Waybar configuration directory into ./waybar
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
dest_dir="$script_dir/waybar"
mkdir -p "$dest_dir"

echo "[backup_waybar.sh] Backing up Waybar configuration to $dest_dir"

sources=("$HOME/.config/waybar" "$HOME/.config/waybar/config" )
found=false
for src in "${sources[@]}"; do
  if [ -d "$src" ]; then
    echo "[backup_waybar.sh] Found directory: $src"
    cp -a -- "$src/." "$dest_dir/"
    found=true
    break
  elif [ -f "$src" ]; then
    echo "[backup_waybar.sh] Found file: $src"
    cp -a -- "$src" "$dest_dir/$(basename "$src")"
    found=true
    break
  fi
done

if [ "$found" = false ]; then
  echo "[backup_waybar.sh] Warning: No Waybar configuration found in the usual locations."
fi

echo "[backup_waybar.sh] Done."

exit 0
