# Configuration

Configuration precedence is:

1. Environment variables
2. `config.sh`
3. Interactive prompts when `NONINTERACTIVE=false`

## Required values

- `SETUP_USERNAME`
- `SETUP_PASSWORD`
- `SETUP_SSH_KEY`

## Optional values

- `SETUP_TIMEZONE` default: `Europe/Istanbul`
- `TAILSCALE_AUTH_KEY`
- `TAILSCALE_HOSTNAME`
- `TAILSCALE_LOCKDOWN_SSH`
- `INSTALL_DOCKER`
- `INSTALL_MISE`
- `INSTALL_GPG`
- `INSTALL_RESTIC`
- `INSTALL_FAIL2BAN`
- `INSTALL_UNATTENDED_UPGRADES`
- `RESTIC_REPOSITORY`
- `RESTIC_PASSWORD_FILE`
- `RESTIC_EXCLUDES_FILE`
- `GPG_REAL_NAME`
- `GPG_EMAIL`
- `GPG_PASSPHRASE`

## Non-interactive example

```bash
export SETUP_USERNAME=devops
export SETUP_PASSWORD='strong-password'
export SETUP_SSH_KEY='ssh-ed25519 AAAA...'
export TAILSCALE_AUTH_KEY='tskey-auth-...'
export NONINTERACTIVE=true
bash setup.sh
```
