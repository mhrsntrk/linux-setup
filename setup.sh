#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
LOG_FILE="${LOG_FILE:-${SCRIPT_DIR}/output.log}"

mkdir -p "$(dirname "$LOG_FILE")"
touch "$LOG_FILE"
exec > >(tee -a "$LOG_FILE") 2>&1

source "${SCRIPT_DIR}/setupLibrary.sh"

main() {
  load_config
  ensure_required_inputs

  log 'Starting Ubuntu 24.04 server bootstrap.'
  addUserAccount "$SETUP_USERNAME" "$SETUP_PASSWORD"
  disableSudoPassword "$SETUP_USERNAME"
  addSSHKey "$SETUP_USERNAME" "$SETUP_SSH_KEY"
  changeSSHConfig
  setupUfw

  if ! swap_exists; then
    createSwap
  fi
  mountSwap
  saveSwapSettings 10 50

  setTimezone "$SETUP_TIMEZONE"
  configureLocale
  configureNTP

  if is_true "$INSTALL_UNATTENDED_UPGRADES"; then
    installUnattendedUpgrades
  fi

  if is_true "$INSTALL_FAIL2BAN"; then
    installFail2ban
  fi

  if [[ -n "$TAILSCALE_AUTH_KEY" ]]; then
    log 'Installing Tailscale integration.'
    "${SCRIPT_DIR}/install/tailscale.sh"
  fi

  if is_true "$INSTALL_DOCKER"; then
    log 'Installing Docker engine and compose plugin.'
    "${SCRIPT_DIR}/docker.sh"
  fi

  if is_true "$INSTALL_RESTIC"; then
    log 'Installing Restic and backup automation.'
    "${SCRIPT_DIR}/install/restic.sh"
    "${SCRIPT_DIR}/backup-config.sh"
  fi

  remove_direct_ssh_access_if_verified
  restart_ssh_service
  log "System bootstrap completed. Log saved to ${LOG_FILE}."
}

main "$@"
