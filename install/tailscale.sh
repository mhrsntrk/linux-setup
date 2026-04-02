#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"

source "${SCRIPT_DIR}/../setupLibrary.sh"

main() {
  local -a tailscale_args

  load_config
  [[ -n "$TAILSCALE_AUTH_KEY" ]] || die 'TAILSCALE_AUTH_KEY is required to install Tailscale headlessly.'

  ensure_packages curl gnupg
  curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/noble.noarmor.gpg | sudo tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null
  curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/noble.tailscale-keyring.list | sudo tee /etc/apt/sources.list.d/tailscale.list >/dev/null

  APT_UPDATED=false
  run_apt_update_once
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y tailscale
  sudo systemctl enable --now tailscaled

  tailscale_args=(--auth-key "$TAILSCALE_AUTH_KEY" --ssh)
  if [[ -n "$TAILSCALE_HOSTNAME" ]]; then
    tailscale_args+=(--hostname "$TAILSCALE_HOSTNAME")
  fi

  sudo tailscale up "${tailscale_args[@]}"
  sudo tailscale set --ssh
  log 'Tailscale is installed. Disable node key expiry from the Tailscale admin console after first login.'
}

main "$@"
