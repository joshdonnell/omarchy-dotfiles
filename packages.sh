#!/bin/bash

set -euo pipefail

if pacman -Q helium-browser-bin >/dev/null 2>&1; then
  echo "helium already installed"
else
  echo "installing helium..."
  omarchy-pkg-aur-add helium-browser-bin
fi

if [ "$(env -u BROWSER xdg-settings get default-web-browser)" = "helium.desktop" ]; then
  echo "helium already the default browser"
else
  echo "setting helium as the default browser..."
  env -u BROWSER xdg-settings set default-web-browser helium.desktop
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

echo "opening text files in zed..."
xdg-mime default dev.zed.Zed.desktop \
  text/plain text/english text/x-makefile text/x-c++hdr text/x-c++src text/x-chdr text/x-csrc \
  text/x-java text/x-moc text/x-pascal text/x-tcl text/x-tex application/x-shellscript \
  text/x-c text/x-c++ application/xml text/xml

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if pacman -Q logiops >/dev/null 2>&1; then
  echo "logiops already installed"
else
  echo "installing logiops for the mx master gestures..."
  omarchy-pkg-aur-add logiops
fi

if cmp -s "$DOTFILES/etc/logid.cfg" /etc/logid.cfg; then
  echo "logid config already up to date"
else
  echo "writing the logid config..."
  sudo install -m 0644 "$DOTFILES/etc/logid.cfg" /etc/logid.cfg
  sudo systemctl restart logid.service 2>/dev/null || true
fi

if systemctl is-enabled logid.service >/dev/null 2>&1; then
  echo "logid already enabled"
else
  echo "enabling logid..."
  sudo systemctl enable --now logid.service
fi

FONT="Dank Mono"
FONT_DIR="$HOME/.local/share/fonts/DankMono"

if fc-list : family | grep -Fq "$FONT"; then
  echo "$FONT already installed"
elif compgen -G "$DOTFILES/fonts/*.[ot]tf" >/dev/null; then
  echo "installing $FONT..."
  mkdir -p "$FONT_DIR"
  cp "$DOTFILES"/fonts/*.[ot]tf "$FONT_DIR/"
  fc-cache -f "$FONT_DIR"
else
  echo "skipping $FONT: put its .otf or .ttf files in $DOTFILES/fonts/ and run ./install.sh again"
fi

if fc-list : family | grep -Fq "$FONT"; then
  if [ "$(omarchy font current)" = "$FONT" ]; then
    echo "$FONT already the system monospace font"
  else
    echo "setting $FONT as the system monospace font..."
    omarchy font set "$FONT"
  fi
fi

THEME="catppuccin-frappe"

if [ "$(cat "$HOME/.local/state/omarchy/current/theme.name" 2>/dev/null)" = "$THEME" ]; then
  echo "$THEME already the omarchy theme"
else
  echo "setting $THEME as the omarchy theme..."
  omarchy theme set "$THEME"
fi
