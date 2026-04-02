# Ubuntu 24.04 Beelink Dev Server Bootstrap

This repository bootstraps a mostly non-interactive Ubuntu Server 24.04 LTS development host with:

- Tailscale-first remote access
- Docker Engine, Buildx, and Compose plugin
- mise-managed Node, Go, and Python runtimes
- Linux-safe dotfiles, NvChad bootstrap, and opencode settings
- SSH hardening, UFW, unattended upgrades, fail2ban, and local restic backups
- Machine-local GPG key generation for Git signing

## Quick start

### Pre-flight checklist

- Ubuntu Server 24.04 LTS installed
- `sudo` access available
- SSH public key ready
- Valid Tailscale auth key ready if headless join is required
- Backup destination path `/var/backups/restic` available on local disk

1. Clone the repository on the target server.
2. Copy `config.sh` and replace placeholder values.
3. Run the system bootstrap:

```bash
bash setup.sh
```

4. Switch to the provisioned user and run the user bootstrap:

```bash
su - "$SETUP_USERNAME"
bash userSetup.sh
```

## Validation

```bash
bash test/lint.sh
bash test/smoke.sh
sudo sshd -t
sudo ufw status verbose
sudo docker compose version
sudo systemctl status restic-backup.timer --no-pager
tailscale status
```

## Documentation

- `CONFIGURATION.md`
- `USAGE.md`
- `SECURITY.md`
- `TROUBLESHOOTING.md`
