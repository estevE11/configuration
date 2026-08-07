# New Mac setup

One script for plumbing + toolchains + DMG downloads. You click through GUI installers.

## Quick start

```bash
git clone <this-repo> ~/dev/configuration
cd ~/dev/configuration
./setup-mac.sh
```

Safe to re-run. App downloads land in `~/Downloads/mac-setup-apps`.

Download apps only:

```bash
./mac/download-apps.sh
```

## Install policy

| Kind | How |
|------|-----|
| GUI apps | Official DMG/PKG/ZIP (`mac/apps.tsv`) — script downloads; you install |
| System/dev plumbing | Homebrew formulae (`mac/Brewfile`) — no app casks |
| Node | nvm (`curl …/nvm/v0.40.6/install.sh \| bash`) then LTS |
| Python | uv (Astral installer) |
| Rust | rustup |
| Go | Official macOS `.pkg` from https://go.dev/dl/ |
| AI CLIs | Official / npx (Claude, Codex, …) — not brew |

## Layout

- `setup-mac.sh` — full bootstrap
- `mac/Brewfile` — brew formulae only
- `mac/apps.tsv` — app catalog (`direct` / `github` / `page`)
- `mac/download-apps.sh` — fetch installers + print manual list
- `mac/dotfiles/` — bash profile/rc linked by setup

## Manual after setup

- Click through files in `~/Downloads/mac-setup-apps` (includes ClaudeBar)
- Page-only rows in `apps.tsv`: Cursor, WhatsApp, Spark, Notion Calendar, The Unarchiver, T3 Code, Xcode
- Accessibility for Rectangle / LinearMouse / MiddleClick / Instant Space Switcher
- Logins + `gh auth login` + SSH keys

## Intentionally skipped

barrier, betterdisplay, claude-code, codexbar, gimp, hyprspace, insomnia, macfuse, slicer, scrcpy, zig, gource, media-info, perl, disk inventory x, localsend, excel, powerpoint, onyx, tailscale, Claude.app, obsidian, telegram, steam, DaVinci Resolve, Adobe Acrobat, Arduino, gifski, LongoMatch, Open Handball Video, UniConvert, CodeMeter, Bosca Ceoil, Antigravity, LM Studio
