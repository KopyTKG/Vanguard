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
  steamcmd.yml           vars for the `steamcmd` group (steam user, deps)
host_vars/
  palworld.yml           which game(s) that client installs
vars/
  steam_apps.yml         every SteamCMD dedicated server, by slug
playbooks/
  baseline.yml           runs on all clients
  web.yml                installs the web group's apps
  steamcmd.yml           installs SteamCMD + the client's game servers
  templates/             files rendered onto the clients
  site.yml               baseline + every group
mise.toml / justfile     tooling + task shortcuts
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

Two things the catalog tracks that change what gets installed:

- **`platform: windows`** — the game has no Linux build (Palworld is one).
  SteamCMD downloads it via `+@sSteamCmdForcePlatformType windows`, so the files
  land, but running it needs Proton or Wine. That part isn't automated.
- **`anonymous: false`** — SteamCMD needs an account that owns the game. The
  playbook refuses to install these until `steam_login` is set to a real one.

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

```bash
sudo -iu steam ./palworld-server.sh start      # stop | restart | status
sudo -iu steam ./palworld-server.sh attach     # drop into the console
sudo -iu steam ./palworld-server.sh cmd 'say hi'
sudo -iu steam ./palworld-server.sh logs 200
```

`stop_timeout`, `restart_delay`, `autorestart`, `session` and `boot` are the
remaining knobs — see `group_vars/steamcmd.yml` for the defaults.

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
