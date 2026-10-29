# Vanguard

Ansible for the clients hosted on **hosting.thekrew.app**. Each client is an
LXC reached over SSH on its own port; all access is guarded by a MikroTik CHR
router (no DNAT). Every client gets the same
**baseline**; then clients are grouped and each **group** installs its own apps.

> Full documentation lives in [`docs/`](docs/Home.md) — an Obsidian vault (open the
> folder as a vault): architecture, per-app guides, runbooks, troubleshooting,
> hosts and variable references.

## Files

```
inventory.yml            clients grouped by app (all same host, differ by port)
group_vars/
  all.yml                shared config: host, admin user, key, packages
  web.yml                vars for the `web` group
  steamcmd.yml           vars for the `steamcmd` group (steam user, deps)
  foundryvtt.yml         vars for the `foundryvtt` group (foundry user, version default)
  minecraft.yml          vars + documented defaults for the `minecraft` group
  proxmox.yml            vars for the `proxmox` group (host packages)
host_vars/
  palworld.yml           which game(s) that client installs
  <client>.yml           per-client: foundry_version, or mc_* settings
vars/
  steam_apps.yml         every SteamCMD dedicated server, by slug
playbooks/
  baseline.yml           runs on all clients
  web.yml                installs the web group's apps
  steamcmd.yml           installs SteamCMD + the client's game servers
  foundry.yml            installs the FoundryVTT launcher
  minecraft.yml          installs a modpack Minecraft server
  tasks/quiet-login.yml  shared: strips the stock Debian login banner
  proxmox.yml            the Proxmox host: fish, fastfetch, vim (not in baseline)
  templates/             files rendered onto the clients
  site.yml               baseline + every group
mise.toml / justfile     tooling + task shortcuts
docs/                    Obsidian vault with the full documentation
```

## Game servers (`steamcmd` group)

`just install steamcmd` creates the `steam` user, installs SteamCMD into
`~steam/Steam`, and drops `~steam/steamcmd-install.sh` — a generated script that
installs or updates any game listed in `steam_games`.

`vars/steam_apps.yml` is the catalog: all 145 servers from Valve's
[Dedicated Servers List](https://developer.valvesoftware.com/wiki/Dedicated_Servers_List),
keyed by slug. A client picks from it by name in `host_vars/<client>.yml`:

```yaml
steam_games:
  - palworld
  - satisfactory
```

Each game installs into `~steam/<slug>`. Unknown slugs fail the run with the
list of what's valid. Anything the catalog is missing goes in `steam_apps_extra`
in the same shape.

Installs are always native. The catalog's `platform` field only records which
wiki table the server appears in — it doesn't change what gets downloaded,
because the wiki is wrong often enough that acting on it does more harm than a
failed download. Palworld is the example: listed Windows-only, ships a Linux
depot. A game that genuinely has no Linux build fails at download; set
`force_platform: windows` on it and run it under Proton/Wine yourself.

What the catalog does change:

- **`anonymous: false`** — SteamCMD needs an account that owns the game. The
  playbook refuses to install these until `steam_login` is set to a real one.
- **`config`** — extra `+app_set_config`, which the GoldSrc mods sharing appid
  90 need to pick a mod.

The playbook skips games that are already installed. To pull an update after a
patch, run the script on the client:

```bash
sudo -iu steam ./steamcmd-install.sh palworld
```

### Running them

`steam_games` installs a game; `steam_servers` is what actually runs it. Entries
are keyed by the same slug and say how to launch and shut down:

```yaml
steam_servers:
  palworld:
    start: ./PalServer.sh    # run from ~steam/palworld
    stop: stop               # console line; use stop_signal: INT instead when
                             # the server has no console
```

Each one gets `~steam/<slug>-server.sh`, which supervises the server in a tmux
session and respawns it if it crashes, plus a `@reboot` line in the steam user's
crontab. A game in `steam_games` but not `steam_servers` is installed and left
alone.

As root, the `steam` switch script is the shortcut: `steam` becomes the steam
user, `steam palworld status` runs a server's launcher directly (tab completes).

```bash
sudo -iu steam ./palworld-server.sh start      # stop | restart | status
sudo -iu steam ./palworld-server.sh attach     # drop into the console
sudo -iu steam ./palworld-server.sh cmd 'say hi'
sudo -iu steam ./palworld-server.sh logs 200
```

`stop_timeout`, `restart_delay`, `autorestart`, `session` and `boot` are the
remaining knobs — see `group_vars/steamcmd.yml` for the defaults.

## FoundryVTT (`foundryvtt` group)

`just install foundry` (all clients in the group, or
`ansible-playbook playbooks/foundry.yml --limit <client>` for one) sets up an
unprivileged **`foundry`** user and a launcher; it does **not** download
Foundry itself (the build is licensed — unpack it yourself).

What it does on each client:

- creates `foundry` with fish as its shell, **no sudo, locked password** — you
  reach it by SSHing in as root and running `foundry` (see below);
- installs the latest Node.js LTS with mise and sets it as that user's global
  (`mise use --global node@lts`); re-running after a new LTS ships moves it
  forward;
- renders `~foundry/foundry.sh`, a tmux launcher with crash respawn and logs in
  `/var/log/foundry/foundry.log` (previous run kept as `.log.old`), plus an
  `@reboot` line in the `foundry` crontab.

Paths the launcher expects (edit the CONFIG block in the template to change):

```
~foundry/foundryvtt     unpacked Foundry build (needs main.js)
~foundry/foundrydata    user data, passed as --dataPath
```

The node binary is resolved at start with `eval mise which node`, so the global
mise version is always used — no version baked into the script.

### Foundry version

Foundry v13+ has `main.js` at the install root; v12 and older nest it under
`resources/app/`. The playbook picks the template from `foundry_version`:

```yaml
# host_vars/<client>.yml — default is 13 (group_vars/foundryvtt.yml)
foundry_version: 12     # -> templates/foundry-legacy.sh.j2
```

### Using it

As root on the client, `foundry` is a switch script:

```bash
foundry                  # become the foundry user (su - foundry)
foundry status           # or run the launcher directly from root:
foundry start            #   start | stop | restart | attach | logs [n]
```

As the `foundry` user: `foundry.sh start|stop|restart|status|attach|logs [n]`.
Detach from `attach` with `Ctrl-b d`.

Existing install in `/root`? Move `foundryvtt` and `foundrydata` to
`/home/foundry/` and `chown -R foundry:foundry` them first — the playbook
doesn't touch live data.

## Minecraft (`minecraft` group)

`just install minecraft` sets up a **vanilla** server or a modded one from a
**Modrinth** or **CurseForge** pack, run by an unprivileged **`minecraft`** user (no sudo,
locked password — `minecraft` as root switches to it, like `foundry` above).
Java comes from mise, version set per host.

Everything is configured in `host_vars/<client>.yml`; defaults and a full
example are in `group_vars/minecraft.yml`:

```yaml
mc_eula: true            # required — you accept https://aka.ms/MinecraftEULA
mc_java: temurin-21      # any mise java spec; 1.20.5+ needs 21, 1.18-1.20.4 needs 17
mc_memory: 6G            # -Xms/-Xmx
mc_port: 25565           # written into server.properties
mc_max_players: 12       # optional: max-players
mc_motd: "My server"     # optional: server name in the multiplayer list
mc_seed: 8675309         # optional: level-seed, only used when the world is first generated
mc_stop_cmd: stop        # console command typed on `stop`/`restart`
mc_whitelist: [Notch]    # optional: enables the whitelist, rewrites whitelist.json
mc_ops: [Notch]          # optional: rewrites ops.json (mc_op_level, default 4)
mc_properties:           # optional: any other server.properties key
  difficulty: hard
mc_modpack:
  source: modrinth       # or curseforge, or vanilla (then: version: "1.21.4" | latest)
  pack: adrenaserver     # modrinth: slug, project id, or .mrpack URL/path
  version: 1.2.3         # optional, default latest
# curseforge instead:
#   source: curseforge
#   url: https://mediafilez.forgecdn.net/files/.../ServerFiles-1.2.zip
#   version: "1.2"       # optional label; change it to force a reinstall
```

- **Vanilla** downloads Mojang's official `server.jar` for `version` (required;
  `latest` = newest release at install time) and checks its sha1.
- **Modrinth** packs install with
  [mrpack-install](https://github.com/nothub/mrpack-install) (fetched to
  `/usr/local/bin`), which sets up Fabric/Quilt servers itself. For Forge/NeoForge
  packs (which it can't) the playbook runs the loader's own installer, then lets
  mrpack-install add the mods and config.
- **CurseForge** needs the pack's **Server Files** zip, not the client modpack:
  client manifests need an API key and don't contain the server. The zip is
  unpacked into `~minecraft/server`.
- The installed pack is remembered in `~minecraft/server/.modpack`; changing
  `pack`/`url`/`version` reinstalls mods and config over the server dir. Worlds
  and `server.properties` are kept.
- The playbook **refuses to run** unless `mc_eula: true` and a valid
  `mc_modpack` are set.

The launcher `~minecraft/minecraft.sh` works like the Steam and Foundry ones
(tmux, crash respawn, `@reboot`, logs in `/var/log/minecraft/minecraft.log`). It
runs `./run.sh nogui` for Forge/NeoForge, otherwise `-jar` on
`fabric-server-launch.jar`, `quilt-server-launch.jar` or `server.jar` (override
with `mc_launch`). `stop` types `stop` into the console so the world saves;
`mc_stop_timeout` (default 120s) is how long it waits.

```bash
minecraft status | start | stop | restart | attach | logs 200   # as root
minecraft.sh cmd 'say hi'                                     # as minecraft
```

`host_vars/allthemons.yml` is the worked example (All the Mons) — copy it. Add a host by uncommenting/adding it under `minecraft:` in `inventory.yml`,
creating `host_vars/<name>.yml`, then `just baseline <name>` and
`ansible-playbook playbooks/minecraft.yml --limit <name>`.

## Login messages

Hosts running Foundry, Minecraft or Steam servers greet users with a short
how-to instead of the stock Debian banner:

- **root** (Foundry/Minecraft hosts): how to switch to the app user and run the
  launcher from root;
- **app user** (`foundry`, `minecraft`, `steam`): the launcher commands, log and
  data paths, and what starts at boot.

They are fish `fish_greeting` functions rendered from
`playbooks/templates/*-greeting.fish.j2`. `playbooks/tasks/quiet-login.yml`
empties `/etc/motd`, disables the scripts in `/etc/update-motd.d` (kernel
banner) and adds `~/.hushlogin` for root and the app user (no last-login line).
It is **not** in baseline, so hosts without these apps keep the defaults. To
restore a host: delete the `.hushlogin` files, restore `/etc/motd`, and
`chmod +x /etc/update-motd.d/*`.

> Don't reload `ssh` from a playbook on these LXCs — socket-activated sshd
> failed to rebind on `SIGHUP` and dropped new connections. That's why the
> banner is silenced with `.hushlogin` rather than `PrintLastLog`.

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

## Test on a throwaway LXC first

Foundry and Minecraft hosts are live platforms. Add a dummy client to the group
(e.g. `dummyvtt` under `foundryvtt:`), `just baseline <name>`, then
`just check foundry <name>` and `ansible-playbook playbooks/foundry.yml --limit <name>`.
Note `--check` fails at the first task that runs as the new user (it doesn't
exist in dry-run mode) — that's expected, do a real run on the dummy.

## Add a group

1. Add the group + its hosts to `inventory.yml`.
2. `group_vars/<group>.yml` — the group's vars.
3. `playbooks/<group>.yml` — install its apps (copy `web.yml`).
4. Add it to `site.yml`.
