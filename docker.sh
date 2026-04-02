#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"

source "${SCRIPT_DIR}/setupLibrary.sh"

main() {
  load_config
  ensure_packages ca-certificates curl gnupg lsb-release
  sudo install -m 0755 -d /etc/apt/keyrings

  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.asc
  sudo chmod a+r /etc/apt/keyrings/docker.asc

  printf '%s\n' 'deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu noble stable' | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

  # Force apt update after adding new repository
  APT_UPDATED=false
  run_apt_update_once
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  sudo systemctl enable --now docker

  sudo groupadd -f docker
  if [[ -n "$SETUP_USERNAME" ]] && user_exists "$SETUP_USERNAME"; then
    sudo usermod -aG docker "$SETUP_USERNAME"
  fi

  sudo docker version >/dev/null
  sudo docker compose version >/dev/null
  log 'Docker Engine, Buildx, and Compose plugin are ready.'
}

main "$@"
