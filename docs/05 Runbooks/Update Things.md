---
title: Update Things
tags: [runbook]
---

# Update Things

| Thing | How |
|---|---|
| OS packages | `just baseline <client>` (dist-upgrade; unattended-upgrades also runs) |
| Node.js LTS (Foundry) | re-run `foundry.yml` — `node@lts` moves to the newest LTS. Restart Foundry afterwards. |
| Java (Minecraft) | change `mc_java` in host vars, re-run `minecraft.yml`, restart |
| FoundryVTT itself | unpack the new build over `~foundry/foundryvtt` as `foundry`, restart. If crossing v12→v13 also change `foundry_version`. |
| Modrinth pack | bump `mc_modpack.version`, re-run `minecraft.yml`, restart |
| CurseForge pack | new `url` (+ `version` label), re-run `minecraft.yml`, restart |
| Steam game | `sudo -iu steam ./steamcmd-install.sh <slug>` then restart the server |
| mise itself | apt upgrade via baseline |
| mrpack-install | delete `/usr/local/bin/mrpack-install` and re-run `minecraft.yml` (downloads latest) |

> [!tip] Back up worlds first
> Minecraft: `~minecraft/server/world*`. Foundry: `~foundry/foundrydata`. Pack and version bumps replace mods/config and can break worlds.

Related: [[Daily Operations]], [[Minecraft]], [[FoundryVTT]].
