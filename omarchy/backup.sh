#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

echo "[backup.sh] Running backup scripts in $script_dir"

scripts=("backup_hypr_conf.sh" "backup_tmux.sh" "backup_waybar.sh")
for s in "${scripts[@]}"; do
  if [ -f "$script_dir/$s" ]; then
    echo "[backup.sh] Executing $s"
    if [ -x "$script_dir/$s" ]; then
      "$script_dir/$s"
    else
      bash "$script_dir/$s"
    fi
  else
    echo "[backup.sh] Warning: $s not found in $script_dir"
  fi
done

echo "[backup.sh] Completed. Expected output locations:"
echo "  - Hypr files: $script_dir/hypr/"
echo "  - Waybar files: $script_dir/waybar/"
echo "  - Tmux config: $script_dir/.tmux.conf"

exit 0
