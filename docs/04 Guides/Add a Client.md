---
title: Add a Client
tags: [guide]
---

# Add a Client

1. **Create the LXC** and allow access to it on the **MikroTik CHR** (the CHR guards all access; no DNAT) → pick a free port, [[Hosts]] (next free: 2213).
2. **Key**: put its private key at `~/.ssh/vanguard/<name>`.
3. **Inventory**: add under the right group in `inventory.yml`:
   ```yaml
   foundryvtt:
     hosts:
       newvtt: { ansible_port: 2213 }
   ```
   Don't reuse a group's name as a host name — [[Inventory and Groups]].
4. **Host vars** (if the app needs them): `host_vars/<name>.yml`
   - Foundry: `foundry_version`
   - Minecraft: `mc_eula`, `mc_modpack`, `mc_java`, ... (copy `host_vars/allthemons.yml`)
   - Steam: `steam_games`, `steam_servers`
5. **Reach it**: `just ping <name>`
6. **Baseline**: `just baseline <name>`
7. **App**: `ansible-playbook playbooks/<group>.yml --limit <name>`
8. Update [[Hosts]].

> [!tip] Live platform? Dummy first
> [[Test on a Dummy LXC]].
