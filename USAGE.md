# Usage

## System bootstrap

```bash
bash setup.sh
```

## User bootstrap

```bash
bash userSetup.sh
```

## Docker-only refresh

```bash
bash docker.sh
```

## Backup initialization refresh

```bash
bash backup-config.sh
```

## Verification checklist

```bash
bash test/lint.sh
bash test/smoke.sh
sudo docker compose version
mise doctor
restic -r /var/backups/restic/repository snapshots
```

## Tailscale lockdown

After confirming Tailscale SSH works, set `TAILSCALE_LOCKDOWN_SSH=true` and rerun:

```bash
bash setup.sh
```
