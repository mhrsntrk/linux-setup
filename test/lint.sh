#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
REPO_ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd -P)"

cd "$REPO_ROOT"

command -v shellcheck >/dev/null 2>&1 || {
  printf 'shellcheck is required. Install it first.\n' >&2
  exit 1
}

shellcheck setup.sh setupLibrary.sh userSetup.sh docker.sh backup-config.sh install/*.sh
