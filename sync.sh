#!/usr/bin/env bash
# Pull, then re-link every stow package. Run on each machine after changing
# anything, or after a tool update: installers and apps sometimes replace a
# symlink with a real file, and edits there silently stop reaching the repo.
#
# Identical real files are re-linked automatically. Files that differ are never
# touched: they are listed so you can merge them into the repo, then re-run.
set -euo pipefail
cd "$(dirname "$0")"
eval "$(grep '^PACKAGES=' install.sh)"

git pull --rebase --autostash

drift=0
for pkg in "${PACKAGES[@]}"; do
  conflicts=$(stow -n --no-folding "$pkg" 2>&1 | sed -n 's/.*over existing target \(.*\) since.*/\1/p' || true)
  for target in $conflicts; do
    if cmp -s "$pkg/$target" "$HOME/$target"; then
      rm "$HOME/$target"
    else
      echo "drifted: ~/$target  (diff $pkg/$target ~/$target)"
      drift=1
    fi
  done
  stow --no-folding "$pkg" 2>/dev/null || true
done

[ "$drift" -eq 0 ] && echo "All packages linked." || exit 1
