---
title: Troubleshooting
tags: [runbook]
---

# Troubleshooting

## Ansible

| Symptom | Cause / fix |
|---|---|
| `sudo: unknown user foundry` on a **check** run | expected: dry run doesn't create the user. Do a real run on a dummy. |
| `Found both group and host with same name` | rename the group (hence `foundryvtt`) — [[Inventory and Groups]] |
| Module result deserialization failed ... `sudo: ...` | usually a missing/unknown `become_user`; ensure `acl` is installed and the user exists |
| `Module remote_tmp ... created with a mode of 0700` warning | harmless; first run as that user |
| mise install task shows `changed` every run | known: `changed_when` is a string heuristic on mise output. Cosmetic. |
| Quiet-login `touch` created a file literally named `foundry_home/.hushlogin` | list in `vars:` wasn't templated; must be `"{{ ['/root', foundry_home] }}"` |
| `Unknown steam_games entries` | slug not in `vars/steam_apps.yml` — add via `steam_apps_extra` |
| Assertion about `mc_eula` / `mc_modpack` | set both in `host_vars/<client>.yml` — [[Minecraft Variables]] |

## sshd died after a playbook (incident)

**What happened:** a handler reloaded `ssh.service` on a socket-activated LXC. sshd re-exec'd on SIGHUP and failed with `fatal: Cannot bind any address`; new connections were refused while Ansible's already-open (ControlPersist) connection still worked.

**Recover:** over any live session or an existing Ansible connection:

```bash
mkdir -p /run/sshd
systemctl start ssh.socket ssh.service
```

If you have no live session, use the Proxmox console: `pct enter <ctid>` and run the same.

**Prevent:** playbooks must not reload/restart `ssh` on these LXCs. Use `.hushlogin` instead of `PrintLastLog`. See [[Login Messages]].

## Launchers

| Symptom | Cause / fix |
|---|---|
| `DIR does not exist: ...` | app files not in place — [[Migrate Foundry to the foundry user]] / pack install |
| `TARGET does not exist` (Foundry) | wrong `foundry_version` |
| `No server jar or run.sh found` (Minecraft) | pack install failed or unusual layout — look in `~minecraft/server`, set `mc_launch` |
| `mise: command not found` / empty `RUNNER` | run [[Baseline]]; check `mise which node` as the user |
| Started from cron but dies instantly | cron has a tiny `PATH`; the script exports mise paths — check `foundry logs` |
| `Already running — attaching.` | `start` on a live session attaches by design |
| `stop` hangs then `Timeout — killing session` | server too slow to stop; raise `STOP_TIMEOUT` / `mc_stop_timeout` |
| Minecraft OOM / killed | raise `mc_memory`, and check the LXC memory limit in Proxmox |

## Minecraft install

| Symptom | Cause / fix |
|---|---|
| `forge provider not implemented` from `mrpack-install` | shouldn't appear any more: the playbook installs Forge/NeoForge itself. If the install fails, read its output: `Pack needs a server loader ...` means the pack has no forge/neoforge dependency; a Java error means `mc_java` doesn't match the pack's Minecraft version |
| Installer download fails | check the loader version in the pack exists on maven.minecraftforge.net / maven.neoforged.net |
| Crash on start: `invalid dist DEDICATED_SERVER`, `has class loading errors`, or a mixin failing on `net.minecraft.client.Minecraft` | client-only mod in the pack — add it to `mc_remove_mods` ([[Minecraft]]) and re-run |
| Wrong Minecraft version installed | `mc_modpack.version` not set → newest *release* line. Pin it ([[Minecraft]]) |
| Left-over `*.mrpack` in `~minecraft/server` | harmless; the next run reuses or removes it |

## Unverified (Minecraft)

First real run may still expose: the CurseForge zip layout and on-host paths. Fix in `playbooks/minecraft.yml` and note it in [[Minecraft]].

Related: [[Launcher Scripts]], [[Daily Operations]].
