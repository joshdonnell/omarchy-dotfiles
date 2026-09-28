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

echo "installing the mise tools..."
mise install

if claude plugins marketplace list 2>/dev/null | grep -F claude-plugins-official >/dev/null; then
  echo "claude plugin marketplace already added"
else
  echo "adding the claude plugin marketplace..."
  claude plugins marketplace add anthropics/claude-plugins-official
fi

for plugin in $(jq -r '.enabledPlugins | keys[]' "$DOTFILES/home/.claude/settings.json"); do
  if claude plugins list 2>/dev/null | grep -F "$plugin" >/dev/null; then
    echo "claude plugin $plugin already installed"
  else
    echo "installing claude plugin $plugin..."
    claude plugins install "$plugin"
  fi
done

if [ -d "$HOME/.agents/skills/setup-matt-pocock-skills" ]; then
  echo "matt pocock skills already installed for cursor and codex"
else
  echo "installing matt pocock skills for cursor and codex..."
  npx -y skills@latest add mattpocock/skills -g -a cursor -a codex --skill '*' -y
fi

if command -v cursor-agent >/dev/null 2>&1; then
  echo "cursor cli already installed"
else
  echo "installing cursor cli..."
  curl https://cursor.com/install -fsS | bash
fi

if pacman -Q php-sqlite php-pgsql >/dev/null 2>&1; then
  echo "php-sqlite and php-pgsql already installed"
else
  echo "installing php-sqlite and php-pgsql..."
  omarchy-pkg-add php-sqlite php-pgsql
fi

if pacman -Q php-pcov >/dev/null 2>&1; then
  echo "php-pcov already installed"
else
  echo "installing php-pcov for code coverage..."
  yay -S --needed --noconfirm --mflags=--ignorearch php-pcov
fi

for ini in "$DOTFILES"/etc/php/conf.d/*.ini; do
  name="$(basename "$ini" .ini)"

  if cmp -s "$ini" "/etc/php/conf.d/$name.ini"; then
    echo "php $name.ini already up to date"
  else
    echo "writing php $name.ini..."
    sudo install -D -m 0644 "$ini" "/etc/php/conf.d/$name.ini"
  fi
done

if pacman -Q postgresql >/dev/null 2>&1; then
  echo "postgres already installed"
else
  echo "installing postgres..."
  omarchy-pkg-add postgresql
fi

if sudo test -f /var/lib/postgres/data/PG_VERSION; then
  echo "postgres already initialised"
else
  echo "initialising postgres..."
  sudo -iu postgres initdb --locale=C.UTF-8 --encoding=UTF8 -D /var/lib/postgres/data
fi

if systemctl is-enabled postgresql.service >/dev/null 2>&1 && systemctl is-active postgresql.service >/dev/null 2>&1; then
  echo "postgres already enabled"
else
  echo "enabling postgres..."
  sudo systemctl enable --now postgresql.service
fi

echo "setting up the postgres root user and database..."
sudo -iu postgres psql -q -v ON_ERROR_STOP=1 -d postgres <"$DOTFILES/etc/postgres/setup.sql"

if pacman -Q tableplus >/dev/null 2>&1; then
  echo "tableplus already installed"
else
  echo "installing tableplus..."
  omarchy-pkg-aur-add tableplus || echo "skipping tableplus: the aur build failed, usually because the package lags a tableplus release"
fi

if [ -x "$HOME/.config/composer/vendor/bin/pint" ]; then
  echo "pint already installed globally"
else
  echo "installing pint globally for php-format..."
  composer global require laravel/pint
fi

FONT="Dank Mono"
FONT_DIR="$HOME/.local/share/fonts/DankMono"

if fc-list : family | grep -F "$FONT" >/dev/null; then
  echo "$FONT already installed"
elif compgen -G "$DOTFILES/fonts/*.[ot]tf" >/dev/null; then
  echo "installing $FONT..."
  mkdir -p "$FONT_DIR"
  cp "$DOTFILES"/fonts/*.[ot]tf "$FONT_DIR/"
  fc-cache -f "$FONT_DIR"
else
  echo "skipping $FONT: put its .otf or .ttf files in $DOTFILES/fonts/ and run ./install.sh again"
fi

if fc-list : family | grep -F "$FONT" >/dev/null; then
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
