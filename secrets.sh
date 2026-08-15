#!/usr/bin/env bash
# Encrypted-secrets workflow for these dotfiles (completes the design the
# provisioning phase 03 built: plaintext `shell/.config/shell/config.d/secrets`
# stays ignored; `secrets.encrypted` beside it is the committed, ansible-vault-
# encrypted copy — sourced by .zshrc via ~/.config/shell/config.d/secrets).
# NOTE: secrets.encrypted was created 2026-07-19 with the password you chose
# THEN — if `pull` fails, re-run `init` after deleting the pass file, using
# the July password.
#
#   ./secrets.sh init     one-time per machine: create the vault password file
#   ./secrets.sh push     encrypt plaintext -> secrets.encrypted (then commit)
#   ./secrets.sh pull     decrypt secrets.encrypted -> plaintext (new machine)
#   ./secrets.sh edit     edit the ENCRYPTED file in $EDITOR (auto re-encrypts),
#                         then refreshes the local plaintext copy
#   ./secrets.sh diff     show what plaintext has that the encrypted copy lacks
#
# The vault password (~/.config/dotfiles-vault-pass, mode 600) is the ONE
# secret you move to a new machine by hand (or from a password manager) —
# everything else then comes from git. The plaintext file is sourced by
# .zshrc line 100, so anything exported there (VAULT_ADDR, VAULT_TOKEN, API
# keys, …) is in every shell automatically.
set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
PLAIN="$DIR/shell/.config/shell/config.d/secrets"
ENC="$DIR/shell/.config/shell/config.d/secrets.encrypted"
PASS="${DOTFILES_VAULT_PASS:-$HOME/.config/dotfiles-vault-pass}"

need_pass() {
  [[ -f "$PASS" ]] || { echo "No vault password at $PASS — run: ./secrets.sh init" >&2; exit 1; }
}

case "${1:-}" in
  init)
    if [[ -f "$PASS" ]]; then echo "Password file already exists: $PASS"; exit 0; fi
    mkdir -p "$(dirname "$PASS")"
    read -r -s -p "Choose a dotfiles vault password: " pw; echo
    printf '%s\n' "$pw" > "$PASS"
    chmod 600 "$PASS"
    echo "Wrote $PASS (mode 600). Keep a copy in your password manager."
    ;;
  push)
    need_pass
    [[ -f "$PLAIN" ]] || { echo "No plaintext at $PLAIN" >&2; exit 1; }
    ansible-vault encrypt --vault-password-file "$PASS" --output "$ENC" "$PLAIN"
    echo "Encrypted -> ${ENC#"$DIR"/}. Commit it: git add ${ENC#"$DIR"/} && git commit"
    ;;
  pull)
    need_pass
    [[ -f "$ENC" ]] || { echo "No encrypted file at $ENC" >&2; exit 1; }
    if [[ -f "$PLAIN" ]] && [[ $(stat -c%s "$PLAIN") -gt 0 ]]; then
      cp "$PLAIN" "$PLAIN.bak-$(date +%Y%m%d-%H%M%S)"
      echo "Backed up existing plaintext to $(ls -t "$PLAIN".bak-* | head -1)"
    fi
    ansible-vault decrypt --vault-password-file "$PASS" --output "$PLAIN" "$ENC"
    chmod 600 "$PLAIN"
    echo "Decrypted -> ${PLAIN#"$DIR"/} (mode 600). Open a new shell to load it."
    ;;
  edit)
    need_pass
    ansible-vault edit --vault-password-file "$PASS" "$ENC"
    ansible-vault decrypt --vault-password-file "$PASS" --output "$PLAIN" "$ENC"
    chmod 600 "$PLAIN"
    echo "Edited + refreshed local plaintext. Commit the encrypted file if changed."
    ;;
  diff)
    need_pass
    diff <(ansible-vault view --vault-password-file "$PASS" "$ENC" 2>/dev/null || true) "$PLAIN" \
      && echo "in sync" || true
    ;;
  *)
    grep '^#   ' "$0" | sed 's/^#   //'
    exit 1
    ;;
esac
