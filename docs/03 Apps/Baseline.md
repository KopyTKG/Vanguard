---
title: Baseline
tags: [app]
---

# Baseline

`playbooks/baseline.yml` — `hosts: all`. Run with `just baseline [limit]`. Always run it on a **new client first**.

## What it does

| Step | Detail |
|---|---|
| Timezone | `timezone` var (Europe/Prague) |
| Hostname | = inventory name |
| apt | update, `dist` upgrade, autoclean/autoremove |
| Packages | `baseline_packages`: sudo curl vim unattended-upgrades fish tmux isc-dhcp-client zip unzip tree |
| Unattended upgrades | `20auto-upgrades` enabled |
| Shell | fish registered in `/etc/shells`, set as root's shell |
| mise | via `extrepo enable mise`, installed from apt |
| root fish | `mise activate fish \| source` in `/root/.config/fish/config.fish` |
| vim | `files/vimrc` → `/root/.vimrc` |

> [!info] Why baseline owns tmux and mise
> Every app launcher needs `tmux`; every app user needs `mise`. App playbooks assume both exist — run baseline before them. On a bare LXC the app playbook will fail without it.

## Related
- `playbooks/cleanup.yml` — one-off: removes the old `kopy` user and `chrony`. Not part of `site.yml`.
- Extend packages in `group_vars/all.yml` (`baseline_packages`).

See [[Architecture]], [[Add a Client]].
