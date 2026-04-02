#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"

source "${SCRIPT_DIR}/../setupLibrary.sh"

main() {
  local batch_file key_id

  load_config
  ensure_packages gnupg pinentry-curses

  if gpg --list-secret-keys --keyid-format=long "$GPG_EMAIL" >/dev/null 2>&1; then
    key_id="$(gpg --list-secret-keys --keyid-format=long "$GPG_EMAIL" | awk '/sec/{print $2}' | awk -F'/' '{print $2}' | head -n1)"
  else
    batch_file="$(mktemp)"
    {
      printf 'Key-Type: eddsa\n'
      printf 'Key-Curve: ed25519\n'
      printf 'Subkey-Type: eddsa\n'
      printf 'Subkey-Curve: ed25519\n'
      printf 'Name-Real: %s\n' "$GPG_REAL_NAME"
      printf 'Name-Email: %s\n' "$GPG_EMAIL"
      if [[ -n "$GPG_PASSPHRASE" ]]; then
        printf 'Passphrase: %s\n' "$GPG_PASSPHRASE"
      else
        printf '%%no-protection\n'
      fi
      printf 'Expire-Date: 2y\n'
      printf '%%commit\n'
    } > "$batch_file"

    gpg --batch --generate-key "$batch_file"
    rm -f "$batch_file"
    key_id="$(gpg --list-secret-keys --keyid-format=long "$GPG_EMAIL" | awk '/sec/{print $2}' | awk -F'/' '{print $2}' | head -n1)"
  fi

  [[ -n "$key_id" ]] || die 'Failed to resolve generated GPG key id.'

  git config --global gpg.program gpg
  git config --global commit.gpgsign true
  git config --global tag.gpgSign true
  git config --global user.signingkey "$key_id"

  install -d -m 755 "$(dirname "$GPG_PUBLIC_KEY_OUTPUT")"
  gpg --armor --export "$key_id" > "$GPG_PUBLIC_KEY_OUTPUT"
  log "GPG signing key ready: ${key_id}. Public key exported to ${GPG_PUBLIC_KEY_OUTPUT}."
}

main "$@"
