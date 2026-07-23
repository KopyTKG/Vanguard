# Vanguard

Ansible for the clients hosted on **hosting.thekrew.app**. Each client is an
LXC reached over SSH on its own port (DNAT). Every client gets the same
**baseline**; then clients are grouped and each **group** installs its own apps.

## Files

```
inventory.yml            clients grouped by app (all same host, differ by port)
group_vars/
  all.yml                shared config: host, admin user, key, packages
  web.yml                vars for the `web` group
playbooks/
  baseline.yml           runs on all clients
  web.yml                installs the web group's apps
  site.yml               baseline + every group
mise.toml / justfile     tooling + task shortcuts
```

## Setup

```bash
mise install     # Python + .venv
just deps        # Ansible + collections
```

Each client's SSH private key goes at `~/.ssh/vanguard/<client-name>`.

## Usage

```bash
just ping              # reach all clients
just baseline          # baseline on all clients
just install web       # install the web group's apps
just site              # baseline + all groups
just check web         # dry-run playbooks/web.yml
```

## Add a client

Add a line under the right group in `inventory.yml` with its SSH port, drop its
key at `~/.ssh/vanguard/<name>`, then `just baseline <name>`.

## Add a group

1. Add the group + its hosts to `inventory.yml`.
2. `group_vars/<group>.yml` — the group's vars.
3. `playbooks/<group>.yml` — install its apps (copy `web.yml`).
4. Add it to `site.yml`.
