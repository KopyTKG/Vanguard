---
title: Unprivileged App Users
tags: [concept, security]
---

# Unprivileged App Users

Foundry, Minecraft and Steam servers don't run as root. Each app gets its own user.

| App | User | Home | Shell | sudo | Password |
|---|---|---|---|---|---|
| FoundryVTT | `foundry` | `/home/foundry` | fish | **no** | locked (`!`) |
| Minecraft | `minecraft` | `/home/minecraft` | fish | **no** | locked (`!`) |
| Steam | `steam` | `/home/steam` | fish | yes (`sudo` group) | set (`steam_password`) |

## Why no sudo, no password

Operators SSH in as **root** and switch with `su - <user>`. Root can switch to any user without a password, so the app user needs neither. A compromised app can't escalate through `sudo` or a guessable password.

> [!question] Does the foundry user need sudo?
> No. Only root logs in over SSH; `su - foundry` from root needs no password. Anything privileged (packages, cron for other users, systemd) is done by root or by Ansible.

> [!info] Steam is the odd one out
> The `steam` user predates this pattern: it's in `sudo` and has a password (`steam_password`, still plaintext — see [[Secrets and Vault]]). Tightening it to match is on the todo list.

## Switch shortcuts

On Foundry and Minecraft hosts Ansible installs `/usr/local/bin/foundry` / `/usr/local/bin/minecraft` (root only):

```bash
foundry                  # su - foundry
foundry attach           # su - foundry -c "~/foundry.sh attach"
```

## What each user owns

- its home (`/home/<user>`), including the app files and the mise-installed runtime;
- its log dir (`/var/log/foundry`, `/var/log/minecraft`) — root creates the directory (needs write on `/var/log`), the user writes inside;
- its crontab (`@reboot` line), written by root since only root can edit other users' crontabs.

> [!warning] Ansible `become_user` needs `acl`
> To hand temp files to an unprivileged user, Ansible needs the `acl` package. It's in every group's package list for that reason.

Related: [[Launcher Scripts]], [[Login Messages]].
