---
title: Daily Operations
tags: [runbook]
---

# Daily Operations

Examples use Foundry; Minecraft is identical with `minecraft` and Steam with `sudo -iu steam ./<slug>-server.sh`.

## Is it up?

```bash
ssh <client>
foundry status                  # running | stopped
foundry logs 100
```

## Restart

```bash
foundry restart                 # stop (clean), wait, start
```

## Watch the console

```bash
foundry attach                  # leave with Ctrl-b d  (NOT Ctrl-c)
```

## Minecraft console commands

```bash
minecraft                       # become minecraft
./minecraft.sh cmd 'say server restarting in 5 minutes'
./minecraft.sh cmd 'save-all'
```

## Server crashed?

The supervisor respawns after `RESTART_DELAY` unless the exit was clean or a stop was requested. Check:

```bash
foundry logs 200          # look for ">> crashed (exit N), restarting"
foundry logs; cat /var/log/foundry/foundry.log.old    # the previous run
```

## After a reboot

`@reboot` in the app user's crontab starts it. If not: `crontab -l -u foundry`, `systemctl status cron`, check the log for a `mise` or path error ([[Troubleshooting]]).

## Apply config changes

Change vars in `host_vars/`, then re-run only that client:

```bash
ansible-playbook playbooks/foundry.yml --limit <client>
```

See [[Command Cheatsheet]], [[Launcher Scripts]], [[Update Things]].
