#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
force=false

usage() {
  cat <<EOF
Usage: $0 [-f|--force]
  -f, --force   Overwrite without prompting (existing files will be moved to backups with timestamp)

This script restores backups created in the project root:
  - ./hypr/    -> ~/.config/hypr/
  - ./waybar/  -> ~/.config/waybar/
  - ./.tmux.conf -> ~/.tmux.conf
EOF
}

while [[ ${1:-} != "" ]]; do
  case "$1" in
    -f|--force)
      force=true
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown arg: $1" >&2
      usage
      exit 2
      ;;
  esac
done

timestamp="$(date +%Y%m%d_%H%M%S)"

confirm_or_backup() {
  # args: src_name dest_path
  local name="$1" dest="$2"
  if [ -e "$dest" ]; then
    if [ "$force" = true ]; then
      backup_dest="${dest}.backup.$timestamp"
      echo "[restore] Moving existing $dest -> $backup_dest"
      mv -- "$dest" "$backup_dest"
      return 0
    else
      printf "Target exists at %s. Move it to %s.backup.%s and restore %s? [y/N]: " "$dest" "$dest" "$timestamp" "$name"
      read -r ans
      if [[ "$ans" =~ ^[Yy]$ ]]; then
        backup_dest="${dest}.backup.$timestamp"
        mv -- "$dest" "$backup_dest"
        echo "[restore] Moved $dest -> $backup_dest"
        return 0
      else
        echo "[restore] Skipping restore of $name (user declined)"
        return 1
      fi
    fi
  fi
  return 0
}

echo "[restore] Starting restore (force=$force)"

# Restore .tmux.conf
src_tmux="$script_dir/.tmux.conf"
if [ -f "$src_tmux" ]; then
  dest_tmux="$HOME/.tmux.conf"
  if confirm_or_backup ".tmux.conf" "$dest_tmux"; then
    cp -a -- "$src_tmux" "$dest_tmux"
    echo "[restore] Restored .tmux.conf -> $dest_tmux"
  fi
else
  echo "[restore] No .tmux.conf backup found at $src_tmux -- skipping"
fi

# Restore hypr directory
src_hypr_dir="$script_dir/hypr"
if [ -d "$src_hypr_dir" ]; then
  dest_hypr_dir="$HOME/.config/hypr"
  if confirm_or_backup "hypr/" "$dest_hypr_dir"; then
    mkdir -p "$(dirname "$dest_hypr_dir")"
    mkdir -p "$dest_hypr_dir"
    # copy contents
    cp -a -- "$src_hypr_dir/." "$dest_hypr_dir/"
    echo "[restore] Restored hypr/ -> $dest_hypr_dir"
  fi
else
  echo "[restore] No hypr/ folder found at $src_hypr_dir -- skipping"
fi

# Restore waybar directory
src_waybar_dir="$script_dir/waybar"
if [ -d "$src_waybar_dir" ]; then
  dest_waybar_dir="$HOME/.config/waybar"
  if confirm_or_backup "waybar/" "$dest_waybar_dir"; then
    mkdir -p "$(dirname "$dest_waybar_dir")"
    mkdir -p "$dest_waybar_dir"
    cp -a -- "$src_waybar_dir/." "$dest_waybar_dir/"
    echo "[restore] Restored waybar/ -> $dest_waybar_dir"
  fi
else
  echo "[restore] No waybar/ folder found at $src_waybar_dir -- skipping"
fi

echo "[restore] Done."

exit 0
