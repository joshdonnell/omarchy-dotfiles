#!/bin/bash

set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ "$(omarchy-default-browser)" = "chromium" ]; then
  echo "chromium already the default browser"
else
  echo "setting chromium as the default browser..."
  omarchy-default-browser chromium
fi

if pacman -Q zed omazed >/dev/null 2>&1; then
  echo "zed already installed"
else
  echo "installing zed..."
  omarchy-pkg-add zed omazed
  omazed setup
fi

if [ "$(omarchy-default-editor)" = "zeditor" ]; then
  echo "zed already the default editor"
else
  echo "setting zed as the default editor..."
  omarchy-default-editor zed
fi

if [ -f "$HOME/.local/share/applications/NordPass.desktop" ]; then
  echo "nordpass web app already installed"
else
  # NordPass only ships an x86_64 Linux app, so on Apple Silicon it runs as a web app.
  echo "installing the nordpass web app..."
  omarchy-webapp-install "NordPass" "https://app.nordpass.com" "https://www.google.com/s2/favicons?domain=nordpass.com&sz=256"
fi

# home/.config/omarchy/keyboard-layouts sets the Mac UK layout for Hyprland. Fcitx keeps
# its own copy, so set it through Omarchy's keyboard picker code, which updates both.
if grep -qx "DefaultIM=keyboard-gb-mac" "$HOME/.config/fcitx5/profile" 2>/dev/null; then
  echo "mac keyboard layout already set"
else
  echo "setting the mac keyboard layout..."
  (cd "$OMARCHY_PATH/default/input-methods" && python3 -c 'import typing_setup; typing_setup.save_keyboard(["gb:mac"])')
fi

if [ -f "$HOME/.claude/hooks/herdr-agent-state.sh" ]; then
  echo "herdr claude hook already installed"
else
  echo "installing the herdr claude hook..."
  herdr integration install claude
  # home/.claude/settings.json already runs the hook, and herdr adds its own copy of
  # the entry. Drop the duplicate, writing through the link into the dotfiles.
  settings="$HOME/.claude/settings.json"
  deduped=$(jq '.hooks.SessionStart |= unique_by(.hooks[0].command | gsub("[\"'"'"']"; "") | gsub("\\$HOME"; env.HOME))' "$settings")
  printf '%s\n' "$deduped" >"$settings"
fi

if command -v bun >/dev/null 2>&1; then
  echo "bun already installed"
else
  echo "installing bun for the claude-hud status line..."
  omarchy-install-dev-env bun
fi

# The marketplaces are also in home/.claude/settings.json, so Claude offers any missing
# plugin on start. Installing them here means they work in the first session too.
for marketplace in pbakaus/impeccable jarrodwatts/claude-hud laravel/agent-skills vercel-labs/agent-browser kaankiziltug/logo-design-skill; do
  claude plugin marketplace add "$marketplace" >/dev/null 2>&1 || true
done

for plugin in $(jq -r '.enabledPlugins | keys[]' "$DOTFILES/home/.claude/settings.json"); do
  if claude plugin list 2>/dev/null | grep -F "$plugin" >/dev/null; then
    echo "claude plugin $plugin already installed"
  else
    echo "installing claude plugin $plugin..."
    claude plugin install "$plugin"
  fi
done

THEME="catppuccin-latte"

if [ "$(cat "$HOME/.local/state/omarchy/current/theme.name" 2>/dev/null)" = "$THEME" ]; then
  echo "$THEME already the omarchy theme"
else
  echo "setting $THEME as the omarchy theme..."
  omarchy theme set "$THEME"
fi

# Starship is rendered from home/.config/omarchy/themed/starship.toml.tpl with the theme's colours.
if [ ! -f "$HOME/.local/state/omarchy/current/theme/starship.toml" ]; then
  echo "rendering the themed starship config..."
  omarchy-theme-refresh
fi

if [ "$(readlink "$HOME/.config/starship.toml")" = "$HOME/.local/state/omarchy/current/theme/starship.toml" ]; then
  echo "starship already follows the omarchy theme"
else
  echo "linking starship to the omarchy theme..."
  if [ -e "$HOME/.config/starship.toml" ] && [ ! -L "$HOME/.config/starship.toml" ]; then
    mv "$HOME/.config/starship.toml" "$HOME/.config/starship.toml.bak.$(date +%s)"
  fi
  ln -sfn "$HOME/.local/state/omarchy/current/theme/starship.toml" "$HOME/.config/starship.toml"
fi
