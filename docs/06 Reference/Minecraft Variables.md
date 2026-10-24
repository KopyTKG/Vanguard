---
title: Minecraft Variables
tags: [reference]
---

# Minecraft Variables

Defaults live in `group_vars/minecraft.yml`; override per host in `host_vars/<client>.yml`.

| Variable | Default | Required | Notes |
|---|---|---|---|
| `mc_user` | `minecraft` | | app user — [[Unprivileged App Users]] |
| `mc_home` | `/home/{{ mc_user }}` | | |
| `mc_packages` | acl procps cron unzip curl ca-certificates | | apt packages |
| `mc_java` | `temurin-21` | | any mise java spec |
| `mc_memory` | `4G` | | `-Xms`/`-Xmx`, e.g. `6G`, `8192M` |
| `mc_port` | `25565` | | written to `server.properties` |
| `mc_stop_timeout` | `120` | | seconds `stop` waits for the world to save |
| `mc_stop_cmd` | `stop` | | console command typed by `stop`/`restart` |
| `mc_max_players` | *(unset)* | | `max-players` in `server.properties` |
| `mc_motd` | *(unset)* | | `motd`, the server name in the multiplayer list |
| `mc_seed` | *(unset)* | | `level-seed`; only used when the world is first generated |
| `mc_whitelist` | *(unset)* | | player names; turns on `white-list` + `enforce-whitelist` and rewrites `whitelist.json` |
| `mc_ops` | *(unset)* | | operator names; rewrites `ops.json` |
| `mc_op_level` | `4` | | permission level 1-4 given to every name in `mc_ops` |
| `mc_properties` | `{}` | | any other `server.properties` keys, e.g. `difficulty: hard`; booleans become `true`/`false` |
| `mc_remove_mods` | `[]` | | mod file globs deleted from `server/mods` on every run (client-only mods) |
| `mc_launch` | *(auto)* | | force a specific server jar |
| `mc_eula` | `false` | **yes → true** | accept https://aka.ms/MinecraftEULA |
| `mc_modpack` | `{}` | **yes** | see below |
| `mc_pack_name` | *(derived)* | | label shown in login greetings |

## server.properties

Only the keys you set (`mc_port`, `mc_max_players`, `mc_motd`, `mc_seed`, and everything in `mc_properties`) are written; the rest of the file is left alone. `mc_properties` wins over the named variables if both set the same key. Unset variables never touch the file.

`level-seed` only matters before the world exists. To change the seed of an existing server, stop it, remove `server/world` (back it up first) and run the playbook again.

```yaml
mc_motd: "Create+ survival"
mc_max_players: 12
mc_seed: 8675309
mc_properties:
  difficulty: hard
  white-list: true
```

### Whitelist and operators

```yaml
mc_whitelist: [Notch, jeb_]
mc_ops: [Notch]
```

Names are looked up on Mojang's API when the playbook runs, so an unknown name fails the run and the server needs `online-mode=true`. `whitelist.json` and `ops.json` are rewritten from the lists every run, which makes the host_vars the source of truth: players added in-game with `whitelist add` or `op` are dropped on the next run. Leave a variable unset to keep managing that file by hand. Ops must also be whitelisted.

Changes apply on the next `minecraft restart`.

## `mc_modpack`

```yaml
# Vanilla (official Mojang server.jar)
mc_modpack:
  source: vanilla
  version: <"1.21.4" | latest>                   # required; latest = newest release

# Modrinth
mc_modpack:
  source: modrinth
  pack: <slug | project id | .mrpack URL/path>   # required
  version: <string>                              # optional, default latest

# CurseForge (server pack zip)
mc_modpack:
  source: curseforge
  url: <https URL of the Server Files zip>       # required
  version: <label>                               # optional; change to force reinstall
```

The asserts in `minecraft.yml` fail the run if `mc_eula` isn't true, `source` isn't `vanilla`/`modrinth`/`curseforge`, or the source's required field is missing.

Worked example: `host_vars/allthemons.yml` — [[Minecraft#Worked example allthemons]].

See [[Minecraft]].
