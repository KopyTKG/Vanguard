---
title: File Map
tags: [reference]
---

# File Map

```
ansible.cfg              inventory path, ssh multiplexing, vault hint
inventory.yml            clients grouped by app
justfile / mise.toml     task shortcuts / pinned tooling
requirements.yml         Galaxy collections
group_vars/
  all.yml                host, ssh user/key, timezone, baseline_packages
  steamcmd.yml           steam user, deps, steam_* defaults (documented)
  foundryvtt.yml         foundry user, packages, foundry_version default
  minecraft.yml          minecraft user, packages, all mc_* defaults (documented)
  web.yml                web group vars
host_vars/
  avorion.yml            steam_games, steam_servers
  foundry.yml cybervtt.yml dummyvtt.yml     foundry_version
  allthemons.yml         Minecraft worked example (mc_*)
vars/steam_apps.yml      145-game SteamCMD catalog
playbooks/
  baseline.yml  site.yml  cleanup.yml
  steamcmd.yml  foundry.yml  minecraft.yml  web.yml
  files/vimrc
  tasks/quiet-login.yml  shared: strip Debian login noise
  templates/             see [[Templates]]
docs/                    this vault
```

Concepts behind it: [[Architecture]], [[Variables and Precedence]].
