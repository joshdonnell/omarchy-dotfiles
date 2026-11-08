#!/bin/bash

set -euo pipefail

if pacman -Q helium-browser-bin >/dev/null 2>&1; then
  echo "helium already installed"
else
  echo "installing helium..."
  omarchy-pkg-aur-add helium-browser-bin
fi

if [ "$(env -u BROWSER XDG_CURRENT_DESKTOP= xdg-settings get default-web-browser)" = "helium.desktop" ]; then
  echo "helium already the default browser"
else
  echo "setting helium as the default browser..."
  # Same call omarchy-default-browser makes; it has no helium option.
  env -u BROWSER XDG_CURRENT_DESKTOP= xdg-settings set default-web-browser helium.desktop
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

if command -v cargo >/dev/null 2>&1; then
  echo "rust already installed"
else
  echo "installing rust to build herdr-ade..."
  omarchy-install-dev-env rust
fi

if herdr plugin list 2>/dev/null | grep -F shire-studio.ade >/dev/null; then
  echo "herdr-ade already installed"
else
  # The sidebar, changes, git, workspace and file keys in home/.config/herdr/config.toml.
  echo "installing herdr-ade..."
  herdr plugin install shire-studio/herdr-ade --yes
fi

THEME="catppuccin-latte"

if [ "$(cat "$HOME/.local/state/omarchy/current/theme.name" 2>/dev/null)" = "$THEME" ]; then
  echo "$THEME already the omarchy theme"
else
  echo "setting $THEME as the omarchy theme..."
  omarchy theme set "$THEME"
fi
