#!/bin/bash

set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -z "${DOTFILES_UPGRADED:-}" ] && git -C "$DOTFILES" rev-parse --abbrev-ref '@{upstream}' >/dev/null 2>&1; then
  echo "pulling the dotfiles..."
  git -C "$DOTFILES" pull --ff-only
  exec env DOTFILES_UPGRADED=1 "$DOTFILES/upgrade.sh" "$@"
fi

"$DOTFILES/install.sh"

omarchy update

echo
echo "the machine is upgraded"
