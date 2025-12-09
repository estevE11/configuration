#!/usr/bin/env bash
set -euo pipefail

# Back up tmux configuration to the project root as `.tmux.conf`
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
dest_file="$script_dir/.tmux.conf"

echo "[backup_tmux.sh] Searching for tmux config to copy to $dest_file"

candidates=("$HOME/.tmux.conf" "$HOME/.config/tmux/tmux.conf")
found=false
for f in "${candidates[@]}"; do
  if [ -f "$f" ]; then
    cp -a -- "$f" "$dest_file"
    echo "[backup_tmux.sh] Copied $f -> $dest_file"
    found=true
    break
  fi
done

if [ "$found" = false ]; then
  echo "[backup_tmux.sh] Warning: No tmux config found in $HOME"
fi

echo "[backup_tmux.sh] Done."

exit 0
