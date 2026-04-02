# Troubleshooting

## Tailscale did not connect

- Verify `TAILSCALE_AUTH_KEY` is valid and not expired.
- Run `sudo systemctl status tailscaled`.
- Run `sudo tailscale status`.

## Docker repository issues

- Confirm `/etc/apt/sources.list.d/docker.list` contains `noble stable`.
- Re-run `sudo apt-get update`.

## mise runtime install failed

- Re-run `mise install`.
- Confirm `~/.config/mise/config.toml` exists.
- Open a new shell or run `source ~/.zshrc`.

## Restic backup timer did not run

- Run `systemctl status restic-backup.timer`.
- Run `systemctl list-timers restic-backup.timer`.
- Run `sudo systemctl start restic-backup.service` for a manual test.

## GPG signing does not work

- Run `gpg --list-secret-keys --keyid-format=long`.
- Run `git config --global --get user.signingkey`.
- Export the public key again with `gpg --armor --export <KEY_ID>`.
