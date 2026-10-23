---
title: Variables and Precedence
tags: [concept]
---

# Variables and Precedence

## Where things live

| File | Scope | Typical content |
|---|---|---|
| `group_vars/all.yml` | every client | host, SSH user/key, timezone, `baseline_packages` |
| `group_vars/<group>.yml` | one group | app user, packages, **defaults** for per-host options |
| `host_vars/<client>.yml` | one client | the per-client choices |
| `playbooks/<x>.yml` `vars:` | one play | rarely used here |
| `vars/steam_apps.yml` | loaded by `steamcmd.yml` | the 145-game SteamCMD catalog |

More specific wins: `host_vars` overrides `group_vars/<group>` overrides `group_vars/all`.

## The pattern used for apps

The **group file holds the default + documentation**; the **host file overrides only what differs**:

```yaml
# group_vars/foundryvtt.yml
foundry_version: 13

# host_vars/cybervtt.yml
foundry_version: 12
```

```yaml
# group_vars/minecraft.yml documents every option and its default
# host_vars/<client>.yml sets mc_eula, mc_modpack, and any overrides
```

## Per-app variable reference

- Foundry: `foundry_user`, `foundry_home`, `foundry_packages`, `foundry_version` → [[FoundryVTT]]
- Minecraft: all `mc_*` → [[Minecraft Variables]]
- Steam: `steam_*` → [[Steam Server Variables]]

> [!note] Jinja in vars
> `foundry_home: "/home/{{ foundry_user }}"` — vars are templated lazily, so a host can override `foundry_user` and the home path follows.

> [!warning] Lists passed via `include_tasks vars:`
> A bare variable inside a YAML flow list is a string, not a lookup. Use `"{{ ['/root', foundry_home] }}"` — this bit the quiet-login include once.
