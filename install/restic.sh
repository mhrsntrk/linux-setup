#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"

source "${SCRIPT_DIR}/../setupLibrary.sh"

main() {
  load_config
  ensure_packages restic
  sudo install -d -m 700 /var/backups/restic
  sudo install -d -m 700 /etc/restic
  log 'Restic package and backup directories are ready.'
}

main "$@"
