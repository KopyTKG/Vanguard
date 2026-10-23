---
title: Templates
tags: [reference]
---

# Templates

All in `playbooks/templates/`. Deployed files are Ansible-managed — edit the template, not the host.

| Template | Used by | Deployed to |
|---|---|---|
| `server.sh.j2` | `steamcmd.yml` | `~steam/<slug>-server.sh` |
| `steamcmd-install.sh.j2` | `steamcmd.yml` | `~steam/steamcmd-install.sh` |
| `steamcmd-readme.txt.j2` | `steamcmd.yml` | `~steam/<slug>/README.txt` |
| `steam-greeting.fish.j2` | `steamcmd.yml` | `~steam/.config/fish/functions/fish_greeting.fish` |
| `launcher-completions.fish.j2` | `foundry.yml`, `minecraft.yml`, `steamcmd.yml` | `~<user>/.config/fish/conf.d/launcher-completions.fish` (and root's, for the switch scripts) |
| `foundry.sh.j2` | `foundry.yml` (v13+) | `~foundry/foundry.sh` |
| `foundry-legacy.sh.j2` | `foundry.yml` (≤v12) | `~foundry/foundry.sh` |
| `foundry-greeting.fish.j2` | `foundry.yml` | `~foundry/.config/fish/functions/fish_greeting.fish` |
| `foundry-root-greeting.fish.j2` | `foundry.yml` | `/root/.config/fish/functions/fish_greeting.fish` |
| `minecraft.sh.j2` | `minecraft.yml` | `~minecraft/minecraft.sh` |
| `minecraft-greeting.fish.j2` | `minecraft.yml` | `~minecraft/.config/fish/functions/fish_greeting.fish` |
| `minecraft-root-greeting.fish.j2` | `minecraft.yml` | `/root/.config/fish/functions/fish_greeting.fish` |

`foundry.sh.j2` and `foundry-legacy.sh.j2` differ **only** in the `TARGET=` line. If you change one, change both.

How the launchers work: [[Launcher Scripts]]. Greetings: [[Login Messages]].
