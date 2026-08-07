#!/usr/bin/env bash
# Download official macOS app installers for manual click-through install.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
APPS_TSV="${ROOT}/apps.tsv"
OUT="${MAC_APPS_DIR:-${HOME}/Downloads/mac-setup-apps}"
ARCH="$(uname -m)"

mkdir -p "${OUT}"

if [[ "${ARCH}" != "arm64" ]]; then
  echo "warn: this catalog defaults to Apple Silicon URLs (arch=${ARCH})" >&2
fi

downloaded=0
manual=0
failed=0

resolve_github_asset() {
  local repo="$1" pattern="$2"
  local api="https://api.github.com/repos/${repo}/releases/latest"
  local json
  json="$(curl -fsSL -H 'Accept: application/vnd.github+json' "${api}")" || return 1
  python3 -c '
import json, re, sys
data = json.load(sys.stdin)
pat = re.compile(sys.argv[1])
for asset in data.get("assets", []):
    name = asset.get("name") or ""
    if pat.search(name):
        print(asset["browser_download_url"])
        print(name)
        raise SystemExit(0)
raise SystemExit(1)
' "${pattern}" <<<"${json}"
}

download_url() {
  local url="$1" dest="$2"
  echo "→ ${dest##*/}"
  curl -fL --retry 3 --retry-delay 2 -o "${dest}.partial" "${url}"
  mv "${dest}.partial" "${dest}"
}

while IFS=$'\t' read -r id name kind source hint; do
  [[ -z "${id}" || "${id}" == \#* ]] && continue

  case "${kind}" in
    direct)
      ext="${hint##*.}"
      [[ "${hint}" == *.* ]] || ext="dmg"
      dest="${OUT}/${hint}"
      if [[ -f "${dest}" ]]; then
        echo "skip (exists): ${name}"
        continue
      fi
      if download_url "${source}" "${dest}"; then
        downloaded=$((downloaded + 1))
      else
        echo "FAIL direct: ${name} — open ${source}" >&2
        failed=$((failed + 1))
        rm -f "${dest}.partial"
      fi
      ;;
    github)
      dest_name=""
      url=""
      if read -r url dest_name < <(resolve_github_asset "${source}" "${hint}"); then
        dest="${OUT}/${dest_name}"
        if [[ -f "${dest}" ]]; then
          echo "skip (exists): ${name}"
          continue
        fi
        if download_url "${url}" "${dest}"; then
          downloaded=$((downloaded + 1))
        else
          echo "FAIL github: ${name} — https://github.com/${source}/releases/latest" >&2
          failed=$((failed + 1))
          rm -f "${dest}.partial"
        fi
      else
        echo "MANUAL: ${name} — https://github.com/${source}/releases/latest (${hint})"
        manual=$((manual + 1))
      fi
      ;;
    page)
      echo "MANUAL: ${name} — ${source}"
      [[ -n "${hint}" && "${hint}" != "-" ]] && echo "         ${hint}"
      manual=$((manual + 1))
      ;;
    *)
      echo "unknown kind '${kind}' for ${id}" >&2
      ;;
  esac
done < "${APPS_TSV}"

echo ""
echo "Downloads directory: ${OUT}"
echo "Downloaded: ${downloaded}  Manual: ${manual}  Failed: ${failed}"
echo "Open installers, drag to Applications / click through, then delete the folder if you want."
open "${OUT}" 2>/dev/null || true

if (( manual > 0 )); then
  echo ""
  echo "Manual list also in: ${ROOT}/apps.tsv (kind=page rows)"
fi
