---
title: Steam Server Variables
tags: [reference]
---

# Steam Server Variables

Defaults in `group_vars/steamcmd.yml`.

| Variable | Default | Notes |
|---|---|---|
| `steam_user` | `steam` | |
| `steam_home` | `/home/steam` | |
| `steam_password` | *(plaintext)* | move to vault — [[Secrets and Vault]] |
| `steam_login` | `anonymous` | set a real account for `anonymous: false` games |
| `steam_games` | `[]` | slugs to install (host_vars) |
| `steam_apps_extra` | `{}` | catalog additions: `{appid, platform, anonymous}` |
| `steam_servers` | `{}` | what to run, per slug |

## `steam_servers.<slug>`

| Key | Default | Meaning |
|---|---|---|
| `start` | **required** | command run from `~steam/<slug>` |
| `stop` | `stop` | console line sent on shutdown |
| `stop_signal` | — | signal instead (INT/TERM) for console-less servers; wins over `stop` |
| `session` | slug | tmux session name |
| `stop_timeout` | 60 | seconds to wait for clean exit |
| `restart_delay` | 5 | seconds between crash respawns |
| `autorestart` | true | respawn on nonzero exit |
| `boot` | true | `@reboot` cron entry |

> [!info] Picking stop vs stop_signal
> Games differ: some read a bare word (`stop`), some a slash command (`/stop`), and many Unreal-engine servers read no stdin at all and need a signal. Sending the wrong kind does nothing — check the game's docs.

See [[Steam Servers]].
