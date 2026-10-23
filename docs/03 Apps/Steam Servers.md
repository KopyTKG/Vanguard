---
title: Steam Servers
aliases: [steamcmd]
tags: [app]
---

# Steam Servers (`steamcmd` group)

`just install steamcmd` creates the `steam` user, installs SteamCMD into `~steam/Steam`, drops `~steam/steamcmd-install.sh`, and builds a control script per configured server.

## Two lists, two jobs

```yaml
# host_vars/avorion.yml
steam_games:           # INSTALL these (slugs from vars/steam_apps.yml)
  - avorion
steam_servers:         # RUN these (how to start/stop)
  avorion:
    start: ./server.sh
    stop: "/stop"
```

A game in `steam_games` but not `steam_servers` is installed and left alone.

## Catalog

`vars/steam_apps.yml` has all 145 servers from Valve's *Dedicated Servers List*, keyed by slug. Unknown slugs fail the run with the valid list. Add missing ones via `steam_apps_extra`.

| Field | Meaning |
|---|---|
| `anonymous: false` | needs a Steam account that owns the game — refused until `steam_login` is set |
| `config` | extra `+app_set_config` (GoldSrc mods sharing appid 90) |
| `platform` | **informational only** — installs are always native; the wiki is wrong often enough (Palworld) |

## Per server files

```
~steam/<slug>/              game files + README.txt
~steam/<slug>-server.sh     tmux control script  (see Launcher Scripts)
/var/log/steamcmd/<slug>.log
```

Plus an `@reboot` line in `steam`'s crontab (`boot: false` to opt out).

## Updating a game

Re-runs skip games whose app manifest exists. To pull a patch:

```bash
sudo -iu steam ./steamcmd-install.sh <slug>
```

## Switching from root

`/usr/local/bin/steam` (installed by the playbook, root only):

```bash
steam                       # become the steam user
steam avorion status        # steam <server> <command>
steam avorion attach        # start | stop | restart | attach | status | cmd | logs
```

An unknown server name prints the list of configured servers. Tab completes servers and commands.

## Login greeting

The steam user's login lists every server with its commands — [[Login Messages]].

Variables: [[Steam Server Variables]] · design: [[Launcher Scripts]], [[Unprivileged App Users]].
