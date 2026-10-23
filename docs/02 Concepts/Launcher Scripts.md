---
title: Launcher Scripts
tags: [concept]
---

# Launcher Scripts

`server.sh.j2` (Steam), `foundry.sh.j2` / `foundry-legacy.sh.j2` and `minecraft.sh.j2` are one design with different hooks.

## Anatomy

```
CONFIG block          ← the only part meant for tweaking (comes from vars)
runtime resolution    ← eval mise which node|java
hooks                 ← on_start, on_stop, on_restart
supervisor            ← _loop: run, log, respawn on crash
commands              ← start stop restart attach status cmd logs
```

## Commands

```
./<name>.sh {start|stop|restart|attach|status|cmd <text>|logs [n]}
```

| Command | Behaviour |
|---|---|
| `start` | rotate log, start a detached tmux session running the supervisor loop. If already up, **attaches** instead. |
| `stop` | runs `on_stop`, waits up to `STOP_TIMEOUT`, then kills the session |
| `restart` | `stop`, 2s, `start` |
| `attach` | `tmux attach` — detach with `Ctrl-b d` |
| `status` | prints `running` / `stopped` |
| `cmd <text>` | types a line into the console (tmux `send-keys`) |
| `logs [n]` | last `n` lines (default 200) of the log |

## The supervisor loop

`start` launches `<script> _loop` inside tmux. The loop runs `on_start` in the foreground, tees output to the log, and after exit:

| Situation | Result |
|---|---|
| exit code 0 | clean exit, stays down |
| stop requested (`stop` made a stop-file) | stays down |
| nonzero exit, `AUTORESTART=1` | wait `RESTART_DELAY`s and restart |
| nonzero exit, `AUTORESTART=0` | stays down |

Logs: current run `/var/log/<app>/<app>.log`, previous run `.log.old` (rotated on every `start`).

## Runtime resolution — `eval mise which`

Foundry and Minecraft do not hardcode a Node/Java path. At start the script runs:

```sh
export PATH="$ROOT/.local/bin:$ROOT/.local/share/mise/shims:$PATH"
RUNNER=$(eval mise which node)     # or java
```

The script runs from a directory with no mise config, so mise falls back to the **global** version Ansible set (`mise use --global node@lts` / `java@<mc_java>`). Bump the global version and the launcher follows with no edit.

Why PATH is exported: a tmux session started from cron has a minimal environment, so mise isn't found otherwise. Minecraft also puts Java's own directory on `PATH` because Forge/NeoForge `run.sh` calls plain `java`.

## Boot

Each launcher has an `@reboot <script> start` line in the app user's crontab. `cron` is enabled by the playbook. Steam servers can opt out per server with `boot: false`.

## Stop mechanics

| App | `on_stop` |
|---|---|
| Steam | console line (`stop`, `/stop`, ...) or a signal — per server |
| Foundry | `SIGTERM` to the node process (no console command exists) |
| Minecraft | types `stop` so the world saves first |

> [!danger] The script is Ansible-managed
> Local edits are overwritten on the next playbook run. Change vars or the template, not the deployed file.

Related: [[Unprivileged App Users]], [[Troubleshooting]], [[Templates]].
