#!/usr/bin/env bash

set -euo pipefail

APT_UPDATED=false

log() {
  printf '[INFO] %s\n' "$*"
}

warn() {
  printf '[WARN] %s\n' "$*" >&2
}

die() {
  printf '[ERROR] %s\n' "$*" >&2
  exit 1
}

is_true() {
  case "${1:-}" in
    1|true|TRUE|yes|YES|on|ON) return 0 ;;
    *) return 1 ;;
  esac
}

repo_root() {
  local source_dir
  source_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
  printf '%s\n' "$source_dir"
}

load_config() {
  local root
  root="$(repo_root)"

  # Load base config first (defaults)
  if [[ -f "${root}/config.sh" ]]; then
    # shellcheck source=./config.sh
    source "${root}/config.sh"
  fi

  # Load local config overrides if present (gitignored)
  if [[ -f "${root}/config.local.sh" ]]; then
    # shellcheck source=./config.local.sh
    source "${root}/config.local.sh"
  fi

  # Allow environment variable to specify custom config
  if [[ -n "${LINUX_SETUP_CONFIG:-}" && -f "$LINUX_SETUP_CONFIG" ]]; then
    # shellcheck source=./config.sh
    source "$LINUX_SETUP_CONFIG"
  fi

  export SETUP_TIMEZONE="${SETUP_TIMEZONE:-Europe/Istanbul}"
  export SETUP_USERNAME="${SETUP_USERNAME:-}"
  export SETUP_PASSWORD="${SETUP_PASSWORD:-}"
  export SETUP_SSH_KEY="${SETUP_SSH_KEY:-}"
  export TAILSCALE_AUTH_KEY="${TAILSCALE_AUTH_KEY:-}"
  export TAILSCALE_HOSTNAME="${TAILSCALE_HOSTNAME:-}"
  export TAILSCALE_LOCKDOWN_SSH="${TAILSCALE_LOCKDOWN_SSH:-false}"
  export NONINTERACTIVE="${NONINTERACTIVE:-false}"
  export INSTALL_DOCKER="${INSTALL_DOCKER:-true}"
  export INSTALL_MISE="${INSTALL_MISE:-true}"
  export INSTALL_GPG="${INSTALL_GPG:-true}"
  export INSTALL_RESTIC="${INSTALL_RESTIC:-true}"
  export INSTALL_FAIL2BAN="${INSTALL_FAIL2BAN:-true}"
  export INSTALL_UNATTENDED_UPGRADES="${INSTALL_UNATTENDED_UPGRADES:-true}"
  export RESTIC_REPOSITORY="${RESTIC_REPOSITORY:-/var/backups/restic/repository}"
  export RESTIC_PASSWORD_FILE="${RESTIC_PASSWORD_FILE:-/etc/restic/password}"
  export RESTIC_EXCLUDES_FILE="${RESTIC_EXCLUDES_FILE:-/etc/restic/excludes.txt}"
  export SETUP_USER_HOME="${SETUP_USER_HOME:-}"
  export GPG_REAL_NAME="${GPG_REAL_NAME:-mhrsntrk}"
  export GPG_EMAIL="${GPG_EMAIL:-m@mhrsntrk.com}"
  export GPG_PASSPHRASE="${GPG_PASSPHRASE:-}"
  export GPG_PUBLIC_KEY_OUTPUT="${GPG_PUBLIC_KEY_OUTPUT:-$HOME/.local/share/linux-setup/git-signing-public.asc}"
}

ensure_tty_or_noninteractive() {
  local variable_name=${1}
  local prompt_text=${2}
  local secret=${3:-false}
  local value

  if [[ -n "${!variable_name:-}" ]]; then
    return 0
  fi

  if is_true "$NONINTERACTIVE" || [[ ! -t 0 ]]; then
    die "Missing required value for ${variable_name}. Set it via env vars or config.sh."
  fi

  if is_true "$secret"; then
    read -rs -p "$prompt_text" value
    printf '\n'
  else
    read -r -p "$prompt_text" value
  fi
  printf -v "$variable_name" '%s' "$value"
  export "$variable_name=${value}"
}

ensure_required_inputs() {
  ensure_tty_or_noninteractive SETUP_USERNAME 'Enter the username of the new user account: '
  ensure_tty_or_noninteractive SETUP_PASSWORD 'Enter the password for the new user account: ' true
  ensure_tty_or_noninteractive SETUP_SSH_KEY 'Paste the public SSH key for the new user: '
}

run_apt_update_once() {
  if [[ "$APT_UPDATED" == false ]]; then
    sudo apt-get update
    APT_UPDATED=true
  fi
}

ensure_packages() {
  run_apt_update_once
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y "$@"
}

append_line_if_missing() {
  local file=${1}
  local line=${2}

  sudo touch "$file"
  if ! sudo grep -Fqx "$line" "$file"; then
    printf '%s\n' "$line" | sudo tee -a "$file" >/dev/null
  fi
}

ensure_file_contains() {
  local file=${1}
  local content=${2}

  sudo mkdir -p "$(dirname "$file")"
  printf '%s' "$content" | sudo tee "$file" >/dev/null
}

set_sshd_option() {
  local key=${1}
  local value=${2}
  local file=/etc/ssh/sshd_config

  if sudo grep -Eq "^[#[:space:]]*${key}[[:space:]]+" "$file"; then
    sudo sed -i -E "s|^[#[:space:]]*${key}[[:space:]].*|${key} ${value}|" "$file"
  else
    printf '%s %s\n' "$key" "$value" | sudo tee -a "$file" >/dev/null
  fi
}

restart_ssh_service() {
  sudo systemctl restart ssh
}

user_exists() {
  id -u "$1" >/dev/null 2>&1
}

user_home() {
  getent passwd "$1" | cut -d: -f6
}

addUserAccount() {
  local username=${1}
  local password=${2}

  if user_exists "$username"; then
    log "User ${username} already exists; ensuring password and sudo group membership."
  else
    sudo adduser --disabled-password --gecos '' "$username"
  fi

  printf '%s:%s\n' "$username" "$password" | sudo chpasswd
  sudo usermod -aG sudo "$username"
}

addSSHKey() {
  local username=${1}
  local ssh_key=${2}
  local home_dir

  home_dir="$(user_home "$username")"
  sudo install -d -m 700 -o "$username" -g "$username" "${home_dir}/.ssh"
  sudo touch "${home_dir}/.ssh/authorized_keys"
  sudo chown "$username:$username" "${home_dir}/.ssh/authorized_keys"
  sudo chmod 600 "${home_dir}/.ssh/authorized_keys"

  if ! sudo grep -Fqx "$ssh_key" "${home_dir}/.ssh/authorized_keys"; then
    printf '%s\n' "$ssh_key" | sudo tee -a "${home_dir}/.ssh/authorized_keys" >/dev/null
    sudo chown "$username:$username" "${home_dir}/.ssh/authorized_keys"
  fi
}

disableSudoPassword() {
  local username=${1}
  local sudoers_file="/etc/sudoers.d/90-${username}-linux-setup"

  printf '%s ALL=(ALL) NOPASSWD: ALL\n' "$username" | sudo tee "$sudoers_file" >/dev/null
  sudo chmod 0440 "$sudoers_file"
}

changeSSHConfig() {
  set_sshd_option PermitRootLogin no
  set_sshd_option PasswordAuthentication no
  set_sshd_option KbdInteractiveAuthentication no
  set_sshd_option ChallengeResponseAuthentication no
  set_sshd_option PubkeyAuthentication yes
  set_sshd_option PermitEmptyPasswords no
  set_sshd_option X11Forwarding no
  set_sshd_option MaxAuthTries 3
}

setupUfw() {
  ensure_packages ufw
  sudo ufw default deny incoming
  sudo ufw default allow outgoing
  sudo ufw allow OpenSSH

  # Allow mosh (mobile shell) UDP ports
  sudo ufw allow 60000:61000/udp

  if [[ -n "$TAILSCALE_AUTH_KEY" ]] || command -v tailscale >/dev/null 2>&1 || ip link show tailscale0 >/dev/null 2>&1; then
    sudo ufw allow in on tailscale0
  fi

  sudo ufw --force enable
}

verify_tailscale_ready() {
  command -v tailscale >/dev/null 2>&1 || die 'tailscale CLI is not installed.'
  tailscale status >/dev/null 2>&1 || die 'tailscale is not connected. Aborting direct SSH rule removal.'
  ip link show tailscale0 >/dev/null 2>&1 || die 'tailscale0 interface is not present. Aborting direct SSH rule removal.'
}

remove_direct_ssh_access_if_verified() {
  if ! is_true "$TAILSCALE_LOCKDOWN_SSH"; then
    log 'Keeping direct SSH access enabled until Tailscale verification is explicitly confirmed.'
    return 0
  fi

  verify_tailscale_ready
  sudo ufw --force delete allow OpenSSH || true
  sudo ufw --force delete allow 22/tcp || true
}

swap_exists() {
  sudo swapon --show=NAME | grep -qx '/swapfile'
}

getPhysicalMemory() {
  local kib mem_gib
  kib="$(awk '/MemTotal:/ {print $2}' /proc/meminfo)"
  mem_gib=$(( (kib + 1048575) / 1048576 ))
  if (( mem_gib < 1 )); then
    mem_gib=1
  fi
  printf '%s\n' "$mem_gib"
}

createSwap() {
  local swapmem
  swapmem=$(( $(getPhysicalMemory) * 2 ))
  if (( swapmem > 4 )); then
    swapmem=4
  fi

  if swap_exists; then
    log 'Swap file already exists; skipping creation.'
    return 0
  fi

  sudo fallocate -l "${swapmem}G" /swapfile
  sudo chmod 600 /swapfile
  sudo mkswap /swapfile
  sudo swapon /swapfile
}

mountSwap() {
  append_line_if_missing /etc/fstab '/swapfile none swap sw 0 0'
}

ensure_sysctl_setting() {
  local key=${1}
  local value=${2}
  local file=/etc/sysctl.d/99-linux-setup.conf
  local escaped_key

  escaped_key="${key//./\\.}"
  sudo touch "$file"
  if sudo grep -Eq "^${escaped_key}=" "$file"; then
    sudo sed -i -E "s|^${escaped_key}=.*|${key}=${value}|" "$file"
  else
    printf '%s=%s\n' "$key" "$value" | sudo tee -a "$file" >/dev/null
  fi
  sudo sysctl -q -w "${key}=${value}"
}

tweakSwapSettings() {
  ensure_sysctl_setting vm.swappiness "$1"
  ensure_sysctl_setting vm.vfs_cache_pressure "$2"
}

saveSwapSettings() {
  tweakSwapSettings "$1" "$2"
}

setTimezone() {
  local timezone=${1}
  local current_timezone

  current_timezone="$(timedatectl show --property=Timezone --value || true)"
  if [[ "$current_timezone" != "$timezone" ]]; then
    sudo timedatectl set-timezone "$timezone"
  fi
}

configureNTP() {
  ensure_packages systemd-timesyncd
  sudo systemctl enable --now systemd-timesyncd
  sudo timedatectl set-ntp true
}

installUnattendedUpgrades() {
  ensure_packages unattended-upgrades apt-listchanges
  ensure_file_contains /etc/apt/apt.conf.d/20auto-upgrades $'APT::Periodic::Update-Package-Lists "1";\nAPT::Periodic::Unattended-Upgrade "1";\n'
  sudo dpkg-reconfigure -f noninteractive unattended-upgrades
}

installFail2ban() {
  ensure_packages fail2ban
  ensure_file_contains /etc/fail2ban/jail.local $'[DEFAULT]\nbantime = 1h\nfindtime = 10m\nmaxretry = 5\nignoreip = 127.0.0.1/8 ::1 100.64.0.0/10\n\n[sshd]\nenabled = true\nbackend = systemd\n'
  sudo systemctl enable --now fail2ban
}

copy_repo_file_to_user() {
  local source_file=${1}
  local destination_file=${2}
  local username=${3}
  local home_dir

  home_dir="$(user_home "$username")"
  install -d -m 755 "$(dirname "${home_dir}/${destination_file}")"
  cp -R "$source_file" "${home_dir}/${destination_file}"
  sudo chown -R "$username:$username" "${home_dir}/${destination_file}"
}

ensure_executable() {
  chmod +x "$1"
}
