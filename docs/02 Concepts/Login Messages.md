---
title: Login Messages
tags: [concept]
---

# Login Messages

End users shouldn't see the Debian kernel banner and warranty text — they need *how to use the thing*. Admin-only hosts keep the stock login.

## What users see

| Who | Greeting shows |
|---|---|
| **root** (Foundry / Minecraft hosts) | how to switch to the app user, how to run the launcher from root |
| **foundry** | launcher commands, install/data paths, node path, boot behaviour |
| **minecraft** | launcher commands incl. `cmd`, server dir, java path, memory/port |
| **steam** | per server: start/stop/attach/cmd/logs, log path, README location |

## How it works

fish prints `fish_greeting` on interactive login. Ansible renders a function file per user:

```
~/.config/fish/functions/fish_greeting.fish
```

from `playbooks/templates/*-greeting.fish.j2`. The Steam greeting loops over `steam_servers`, the others interpolate version / memory / port.

## Silencing the Debian banner

`playbooks/tasks/quiet-login.yml` (included by `foundry.yml`, `minecraft.yml` and `steamcmd.yml`, **not** by baseline):

1. empties `/etc/motd`;
2. makes everything in `/etc/update-motd.d/` non-executable (this is the `Linux host 7.x ...` line);
3. deletes `/run/motd.dynamic`;
4. creates `~/.hushlogin` for root and the app user → no "Last login" line.

> [!bug] Never reload sshd from a playbook here
> The first attempt used `PrintLastLog no` plus an sshd reload. On the socket-activated LXC sshd the SIGHUP re-exec failed with `Cannot bind any address`, taking sshd down for new connections. Recovery was `systemctl start ssh.socket ssh.service` over Ansible's still-open connection. `.hushlogin` needs no sshd change — see [[Troubleshooting]].

To undo: [[Restore Debian Banner]].
