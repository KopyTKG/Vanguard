---
title: Minecraft
aliases: [mc]
tags: [app]
---

# Minecraft (`minecraft` group)

Minecraft servers — **vanilla**, or modded from a **Modrinth** or **CurseForge** pack — run by an unprivileged `minecraft` user with Java from mise (version set per host). `just install minecraft` → `playbooks/minecraft.yml`.

## Minimum host config

```yaml
# host_vars/<client>.yml
mc_eula: true                    # you accept https://aka.ms/MinecraftEULA
mc_java: temurin-21
mc_memory: 6G
mc_modpack:
  source: modrinth
  pack: adrenaserver
```

The playbook **asserts** `mc_eula` and a valid `mc_modpack` (`vanilla` + `version`, `modrinth` + `pack`, or `curseforge` + `url`) before touching anything. Full option list: [[Minecraft Variables]].

## Java version cheat sheet

| Minecraft | Java (`mc_java`) |
|---|---|
| 1.20.5+ | `temurin-21` |
| 1.18 – 1.20.4 | `temurin-17` |
| 1.17 | `temurin-16`/`17` |
| ≤ 1.16 | `temurin-8` / `11` |

Any mise java spec works (`zulu-21`, `21`, ...).

## Pack sources

### Vanilla
Downloads the official `server.jar` straight from Mojang (version manifest at `piston-meta.mojang.com`) and verifies its sha1. No modpack tooling involved.

```yaml
mc_modpack: { source: vanilla, version: "1.21.4" }    # or version: latest
```

`version` is required. `latest` means the newest **release** at install time (snapshots are not picked); like the other sources it is remembered in `.modpack`, so `latest` won't auto-upgrade later — set an explicit version to move. Pick `mc_java` to match (table above). The launcher runs `java -jar server.jar nogui`.

```yaml
# minimal vanilla host
mc_eula: true
mc_java: temurin-21
mc_memory: 4G
mc_modpack: { source: vanilla, version: "1.21.4" }
```

### Modrinth
`mrpack-install` (downloaded to `/usr/local/bin`) installs the `.mrpack` into `~minecraft/server`.

| Loader in the pack | Who sets up the server |
|---|---|
| Fabric, Quilt, vanilla | `mrpack-install` itself |
| **Forge, NeoForge** | the playbook — `mrpack-install` errors on Forge (`forge provider not implemented`) and, worse, **silently installs a vanilla jar for NeoForge**. So the playbook downloads the `.mrpack` itself (Modrinth API), reads the loader version from it, runs the loader's own installer (`--installServer`, creates `run.sh` + `libraries/`), then runs `mrpack-install` on the local file with `--server-file` to add mods and config |

**Version matters.** Without `version`, the newest *release* is installed. A pack can have several Minecraft lines — *Create+* is 1.19.2 Forge (5.x releases) and 1.21.1 NeoForge (`6.0.0-alpha-*`, pre-releases, so never "latest"). Pin `version` to get the line you want; list the versions with `curl -s https://api.modrinth.com/v2/project/<slug>/version`.

Forge installers come from `maven.minecraftforge.net`, NeoForge from `maven.neoforged.net`. Pick `mc_java` for the pack's Minecraft version — the installer and the server both use it. 1.19.2's official target is Java 17, but Forge 1.19.2 also booted fine on Java 21 in testing, so 21 is not a blocker.

> [!info] Tested
> Run end to end from a workstation on *Create+*: Forge 1.19.2 (5.2.1b) and NeoForge 1.21.1 (6.0.0-alpha-f) both installed and the servers reached `Done`, on Java 21. Old Forge (< 1.17, which writes `forge-<mc>-<ver>.jar` instead of `run.sh`) is handled but untested.

```yaml
mc_modpack: { source: modrinth, pack: <slug|id|url|path>, version: 1.2.3 }   # version optional
```

### CurseForge
Use the pack's **Server Files** zip — *not* the client modpack (client manifests need an API key and don't contain the server).

```yaml
mc_modpack: { source: curseforge, url: https://mediafilez.forgecdn.net/files/.../ServerFiles-1.2.zip, version: "1.2" }
```

The zip is unpacked into `~minecraft/server`; a single top-level folder is flattened.

## Client-only mods (`mc_remove_mods`)

Many packs ship mods that only work on a client (shaders, CIT, animated models, minimap-style HUDs...). On a dedicated server they crash startup with errors like:

- `Attempted to load class ... for invalid dist DEDICATED_SERVER`
- `Mixin ... ClassMetadataNotFoundException: net.minecraft.client.Minecraft`
- `<Mod> has class loading errors`

List them per host and they are deleted from `~minecraft/server/mods` on every run (so a pack reinstall doesn't bring them back):

```yaml
mc_remove_mods:
  - "oculus-mc*.jar"        # shell globs on the file name
  - "figura-*.jar"
```

**Finding them:** start the server, read which mods Forge lists under `Mod File:` / `has class loading errors` (or the mixin config named in the stack), add them, re-run `minecraft.yml`, repeat. A mixin crash that doesn't name the mod is usually a client mod whose mixin touches `net.minecraft.client.Minecraft`; scanning the jars' mixin configs for that class finds the candidates.

`host_vars/createmc.yml` has a worked example: one client mod (`statuseffectbars`) from *Create+* 6.0.0-alpha-f (NeoForge 1.21.1). The older 1.19.2 line needed 13. NeoForge lists failures as `- <Name> (<modid>) has failed to load correctly`; Forge 1.19.2 lists them under `Mod File:`.

## Reinstall rules

`~minecraft/server/.modpack` stores `source:pack-or-url:version`. If it differs from the host vars the pack is reinstalled: the old `mods/`, `libraries/`, `run.sh` and loader/server jars are **deleted first** (mrpack-install only adds files, so a Minecraft-version change would otherwise leave stale mods), then the new pack is installed. **Worlds, `config/` and `server.properties` are kept** — a world from a different Minecraft version may need a backup and a manual upgrade. Using `version: latest` (omitted) never self-updates; change the version or delete `.modpack`.

## Launcher

`~minecraft/minecraft.sh`:

- Forge/NeoForge (`run.sh` exists) → `JAVA_TOOL_OPTIONS="-Xms$MEM -Xmx$MEM" sh run.sh nogui`
- otherwise `java -Xms -Xmx -jar` the first of `fabric-server-launch.jar`, `quilt-server-launch.jar`, `server.jar` (override: `mc_launch`)
- `stop` types `stop` so the world saves; waits `mc_stop_timeout` (120s)

```bash
minecraft status | start | stop | restart | attach | logs 200      # root
minecraft.sh cmd 'say hi'                                        # minecraft user
```

## Layout

```
/home/minecraft/
├── minecraft.sh
└── server/     world, mods, config, server.properties, eula.txt, .modpack
/var/log/minecraft/minecraft.log   (+ .log.old)
```

## Worked example: allthemons

`host_vars/allthemons.yml` is the reference config — an All the Mons (Cobblemon) server. Copy it for a new client.

```yaml
mc_eula: true
mc_java: temurin-21          # 1.21.x
mc_memory: 8G
mc_port: 25565
mc_modpack:
  source: curseforge
  url: https://mediafilez.forgecdn.net/files/8822/160/ServerFiles-1.3.0.zip
  version: "1.3.0"
```

The pack URL is real (ServerFiles 1.3.0, ~1 GB). The host is in the `minecraft` group in `inventory.yml` but still **commented out** (port 2204). To bring it up:

1. Make sure the LXC has a few GB free in `/tmp` and `/home` — the zip is downloaded to a temp dir, then unpacked.
2. Uncomment `allthemons` in `inventory.yml`.
3. `just baseline allthemons`, then `ansible-playbook playbooks/minecraft.yml --limit allthemons`.
4. `ssh allthemons` → `minecraft start`, `minecraft logs 100`.

> [!note] Assumptions
> `mc_java: temurin-21` and `mc_memory: 8G` are guesses for this pack; confirm against the pack's page. The first start of a big pack can take several minutes.

## Adding a host

[[Add a Client]] with group `minecraft`, create `host_vars/<name>.yml`, then `just baseline <name>` and `ansible-playbook playbooks/minecraft.yml --limit <name>`. Try a small pack on a [[Test on a Dummy LXC]] first.

> [!bug] Not yet exercised on a real host
> Written and syntax/render-checked only. The vanilla download logic (manifest lookup, version pick, sha1-checked jar) was run against Mojang from a workstation and works; the install-on-host path was not (the test LXC was unreachable). The Modrinth install and Forge fallback were run from a workstation (see above). Still unverified: the CurseForge zip layout and the on-host paths (users, mise, launcher, cron). First dummy run should confirm them — fix here and in the playbook.

Related: [[Launcher Scripts]], [[Unprivileged App Users]], [[Login Messages]].
