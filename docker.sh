#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"

source "${SCRIPT_DIR}/setupLibrary.sh"

main() {
  load_config
  ensure_packages ca-certificates curl gnupg lsb-release

  # Use Docker's official convenience script for reliable installation
  curl -fsSL https://get.docker.com | sudo sh

  sudo groupadd -f docker
  if [[ -n "$SETUP_USERNAME" ]] && user_exists "$SETUP_USERNAME" ]]; then
    sudo usermod -aG docker "$SETUP_USERNAME"
  fi

  sudo docker version >/dev/null
  sudo docker compose version >/dev/null
  log 'Docker Engine, Buildx, and Compose plugin are ready.'
}

main "$@"
