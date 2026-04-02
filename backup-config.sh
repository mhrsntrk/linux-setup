#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"

source "${SCRIPT_DIR}/setupLibrary.sh"

main() {
  local password_file_content
  local env_file=/etc/restic/linux-setup.env

  load_config
  sudo install -d -m 700 "$(dirname "$RESTIC_PASSWORD_FILE")"
  sudo install -d -m 700 "$(dirname "$RESTIC_REPOSITORY")"
  sudo install -d -m 755 /etc/systemd/system

  if [[ ! -f "$RESTIC_PASSWORD_FILE" ]]; then
    password_file_content="$(openssl rand -base64 32)"
    printf '%s\n' "$password_file_content" | sudo tee "$RESTIC_PASSWORD_FILE" >/dev/null
    sudo chmod 600 "$RESTIC_PASSWORD_FILE"
  fi

  sudo cp "$SCRIPT_DIR/backups/restic-excludes.txt" "$RESTIC_EXCLUDES_FILE"
  sudo chmod 644 "$RESTIC_EXCLUDES_FILE"
  sudo tee "$env_file" >/dev/null <<EOF
RESTIC_REPOSITORY=${RESTIC_REPOSITORY}
RESTIC_PASSWORD_FILE=${RESTIC_PASSWORD_FILE}
RESTIC_EXCLUDES_FILE=${RESTIC_EXCLUDES_FILE}
RESTIC_BACKUP_PATHS=/home /etc /var/lib/docker
EOF
  sudo chmod 600 "$env_file"

  if ! sudo RESTIC_PASSWORD_FILE="$RESTIC_PASSWORD_FILE" restic -r "$RESTIC_REPOSITORY" snapshots >/dev/null 2>&1; then
    sudo RESTIC_PASSWORD_FILE="$RESTIC_PASSWORD_FILE" restic -r "$RESTIC_REPOSITORY" init
  fi

  sudo install -m 0644 "$SCRIPT_DIR/systemd/restic-backup.service" /etc/systemd/system/restic-backup.service
  sudo install -m 0644 "$SCRIPT_DIR/systemd/restic-backup.timer" /etc/systemd/system/restic-backup.timer
  sudo systemctl daemon-reload
  sudo systemctl enable --now restic-backup.timer
  log 'Restic repository and daily backup timer are configured.'
}

main "$@"
