---
title: Minecraft
aliases: [mc]
tags: [app]
---

# Minecraft (`minecraft` group)

Modded Minecraft servers from a **Modrinth** or **CurseForge** pack, run by an unprivileged `minecraft` user with Java from mise (version set per host). `just install minecraft` → `playbooks/minecraft.yml`.

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

The playbook **asserts** `mc_eula` and a valid `mc_modpack` before touching anything. Full option list: [[Minecraft Variables]].

## Java version cheat sheet

| Minecraft | Java (`mc_java`) |
|---|---|
| 1.20.5+ | `temurin-21` |
| 1.18 – 1.20.4 | `temurin-17` |
| 1.17 | `temurin-16`/`17` |
| ≤ 1.16 | `temurin-8` / `11` |

Any mise java spec works (`zulu-21`, `21`, ...).

## Pack sources

### Modrinth
`mrpack-install` (downloaded to `/usr/local/bin`) installs the `.mrpack` and the right server (Fabric / Forge / NeoForge / Quilt) into `~minecraft/server`.

```yaml
mc_modpack: { source: modrinth, pack: <slug|id|url|path>, version: 1.2.3 }   # version optional
```

### CurseForge
Use the pack's **Server Files** zip — *not* the client modpack (client manifests need an API key and don't contain the server).

```yaml
mc_modpack: { source: curseforge, url: https://mediafilez.forgecdn.net/files/.../ServerFiles-1.2.zip, version: "1.2" }
```

The zip is unpacked into `~minecraft/server`; a single top-level folder is flattened.

## Reinstall rules

`~minecraft/server/.modpack` stores `source:pack-or-url:version`. If it differs from the host vars the pack is reinstalled over the server dir — **mods and config are replaced, worlds and `server.properties` are kept**. Using `version: latest` (omitted) never self-updates; change the version or delete `.modpack`.

## Launcher

`~minecraft/minecraft.sh`:

- Forge/NeoForge (`run.sh` exists) → `JAVA_TOOL_OPTIONS="-Xms$MEM -Xmx$MEM" sh run.sh nogui`
- otherwise `java -Xms -Xmx -jar` the first of `fabric-server-launch.jar`, `quilt-server-launch.jar`, `server.jar` (override: `mc_launch`)
- `stop` types `stop` so the world saves; waits `mc_stop_timeout` (120s)

```bash
minecraft status | start | stop | restart | attach | logs 200      # root
./minecraft.sh cmd 'say hi'                                        # minecraft user
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
> Written and syntax/render-checked only. Unverified assumptions: the exact `mrpack-install <pack> <version> --server-dir` invocation, the jar names above, CurseForge zip layout. First dummy run should confirm them — fix here and in the playbook.

Related: [[Launcher Scripts]], [[Unprivileged App Users]], [[Login Messages]].
