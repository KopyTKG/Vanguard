---
title: Migrate Foundry to the foundry user
tags: [runbook]
---

# Migrate Foundry to the foundry user

For a host whose Foundry currently lives in `/root` (`/root/foundryvtt`, `/root/foundrydata`). The playbook never moves live data — you do, deliberately.

> [!danger] Live platform
> Take a backup first and pick a quiet time. Rehearse on a [[Test on a Dummy LXC]].

## Steps

1. **Back up**
   ```bash
   tar czf /root/foundry-backup-$(date +%F).tgz /root/foundryvtt /root/foundrydata
   ```
2. **Stop the old process** (however it ran: `pkill -f main.js`, an old tmux, etc.).
3. **Run the playbook** — creates the user, node, launcher, cron:
   ```bash
   ansible-playbook playbooks/foundry.yml --limit <client>
   ```
4. **Move the data**
   ```bash
   mv /root/foundryvtt  /home/foundry/foundryvtt
   mv /root/foundrydata /home/foundry/foundrydata
   chown -R foundry:foundry /home/foundry/foundryvtt /home/foundry/foundrydata
   ```
5. **Check the version** matches `foundry_version` in host vars ([[FoundryVTT]]).
6. **Start and watch**
   ```bash
   foundry start
   foundry logs 100
   ```
7. **Remove the old root cron/script** that started it, if any (`crontab -l`).
8. Verify from the web UI, then delete the backup when satisfied.

## If it won't start

| Message | Fix |
|---|---|
| `DIR does not exist: /home/foundry/foundryvtt` | step 4 not done |
| `TARGET does not exist: .../main.js` | wrong `foundry_version` (v12 → `resources/app/main.js`) |
| `mise: command not found` | run [[Baseline]] first |
| permission denied on data | `chown -R foundry:foundry` again |

See [[Troubleshooting]].
