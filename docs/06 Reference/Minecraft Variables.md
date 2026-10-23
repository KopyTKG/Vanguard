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
| `mc_launch` | *(auto)* | | force a specific server jar |
| `mc_eula` | `false` | **yes → true** | accept https://aka.ms/MinecraftEULA |
| `mc_modpack` | `{}` | **yes** | see below |

## `mc_modpack`

```yaml
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

The asserts in `minecraft.yml` fail the run if `mc_eula` isn't true, `source` isn't `modrinth`/`curseforge`, or the source's required field is missing.

Worked example: `host_vars/allthemons.yml` — [[Minecraft#Worked example allthemons]].

See [[Minecraft]].
