---
title: Architecture
tags: [concept]
---

# Architecture

## The shape of it

```
operator laptop ──ssh (key per client)──▶ hosting.thekrew.app:<port> ──▶ MikroTik CHR ──▶ LXC
                                                │                         │
                                                │                         └─ guards all access (no DNAT)
                                                └─ one port per client (2200-2225)
```

- Every client is an **LXC** (Proxmox). All access goes through a **MikroTik CHR** router that guards the hosts; DNAT is not used. From Ansible's side clients differ only by the SSH port in the inventory — see [[Hosts]].
- Firewall/access rules for clients live on the CHR, not in this repo.
- Ansible connects as `root` with a per-client key at `~/.ssh/vanguard/<client-name>` (set in `group_vars/all.yml`).
- Clients are **grouped by the app they run** in `inventory.yml` — see [[Inventory and Groups]].

## Two layers

1. **[[Baseline]]** runs on `all` clients: timezone, hostname, packages, fish, mise, vimrc, unattended upgrades.
2. **Group playbooks** run on one group each: `steamcmd.yml`, `foundry.yml`, `minecraft.yml`, `web.yml`. `site.yml` runs baseline then every group.

## What an app group installs

All three game/app groups follow the same pattern:

| Piece | Why | See |
|---|---|---|
| Unprivileged user | the app never runs as root | [[Unprivileged App Users]] |
| mise-managed runtime | Node / Java picked per user, no baked-in paths | [[Launcher Scripts]] |
| tmux launcher script | start/stop/attach/logs, crash respawn | [[Launcher Scripts]] |
| `@reboot` cron entry | server comes back after a reboot | [[Launcher Scripts]] |
| Login greeting | users see *how to use it*, not the Debian banner | [[Login Messages]] |

## Design rules

- **Config in vars, logic in templates.** Anything you'd tweak lives in `group_vars/` or `host_vars/` — see [[Variables and Precedence]].
- **Idempotent.** Re-running a playbook should change nothing unless config changed. (Known soft spot: the mise install tasks use a heuristic `changed_when`, see [[Troubleshooting]].)
- **Never touch live data implicitly.** Playbooks install software; they don't move or delete worlds, Foundry data or game saves. Migrations are manual — see [[Migrate Foundry to the foundry user]].
- **Test on a dummy first.** Foundry and Minecraft hosts are live platforms — [[Test on a Dummy LXC]].
