# Security Checklist

- SSH password authentication disabled
- Root SSH login disabled
- UFW default deny incoming, allow outgoing
- Tailscale interface allowed explicitly
- Remove direct SSH only after verified Tailscale access and `TAILSCALE_LOCKDOWN_SSH=true`
- Automatic security updates enabled with unattended-upgrades
- fail2ban enabled for `sshd`
- Review passwordless sudo requirement for the setup user after bootstrap
- Export and back up the generated public and private GPG material securely
- Disable Tailscale node key expiry in the admin console

## GPG backup and Git hosting

```bash
gpg --armor --export-secret-keys "${GPG_EMAIL:-m@mhrsntrk.com}" > ~/git-signing-private-backup.asc
gpg --armor --export "${GPG_EMAIL:-m@mhrsntrk.com}" > ~/git-signing-public.asc
```

- Upload `~/git-signing-public.asc` to GitHub or GitLab signing keys.
- Store the secret key backup offline and encrypted.

## Manual post-setup review

```bash
sudo sshd -t
sudo ufw status verbose
sudo fail2ban-client status sshd
sudo unattended-upgrade --dry-run --debug
tailscale status
```
