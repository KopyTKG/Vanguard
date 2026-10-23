---
title: Command Cheatsheet
aliases: [Cheatsheet, Commands]
tags: [reference]
---

# Command Cheatsheet

## From your laptop (repo root)

| Goal | Command |
|---|---|
| Install tooling | `mise install && just deps` |
| Ping | `just ping [limit]` |
| Baseline | `just baseline [limit]` |
| Install a group | `just install <group>` (`steamcmd`, `foundry`, `minecraft`, `web`) |
| One client only | `ansible-playbook playbooks/<group>.yml --limit <client>` |
| Everything | `just site` |
| Dry run | `just check <playbook> [limit]` |
| Show inventory | `ansible-inventory --graph` |
| Ad-hoc command | `ansible <client> -b -m shell -a '<cmd>'` |
| Syntax check | `ansible-playbook playbooks/<x>.yml --syntax-check` |

## On a FoundryVTT host

| As | Command | Does |
|---|---|---|
| root | `foundry` | switch to the `foundry` user |
| root | `foundry status \| start \| stop \| restart \| attach \| logs [n]` | run the launcher from root |
| foundry | `foundry.sh start\|stop\|restart\|status\|attach\|logs [n]` | launcher |

## On a Minecraft host

| As | Command | Does |
|---|---|---|
| root | `minecraft` | switch to the `minecraft` user |
| root | `minecraft status \| start \| stop \| restart \| attach \| logs [n]` | run the launcher from root |
| minecraft | `minecraft.sh cmd 'say hi'` | type into the server console |
| minecraft | `minecraft.sh start\|stop\|restart\|status\|attach\|logs [n]` | launcher |

## On a Steam host

```bash
sudo -iu steam <slug>-server.sh start|stop|restart|status|attach|logs [n]
sudo -iu steam <slug>-server.sh cmd 'say hi'
sudo -iu steam ./steamcmd-install.sh <slug>      # install / update a game
```

## Tab completion

In fish, `Tab` after any launcher (`foundry.sh`, `minecraft.sh`, `<slug>-server.sh`, or root's `foundry` / `minecraft`) completes the subcommands; after `logs` it offers line counts, after Minecraft's `cmd` common console commands. See [[Launcher Scripts]].

## tmux inside `attach`

| Keys | Does |
|---|---|
| `Ctrl-b d` | detach (server keeps running) |
| `Ctrl-b [` | scroll mode (`q` to leave) |

> [!danger] Don't `Ctrl-c` in an attached console
> That kills the server process. Detach with `Ctrl-b d`; stop with `stop`.

See also [[Daily Operations]], [[Launcher Scripts]].
