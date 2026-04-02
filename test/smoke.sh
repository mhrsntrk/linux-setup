#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd -P)"

cd "$REPO_ROOT"

bash -n setup.sh
bash -n setupLibrary.sh
bash -n userSetup.sh
bash -n docker.sh
bash -n backup-config.sh

for script in install/*.sh; do
  bash -n "$script"
done

test -f config.sh
test -f backups/restic-excludes.txt
test -f systemd/restic-backup.service
test -f systemd/restic-backup.timer

printf 'Smoke tests completed successfully.\n'
