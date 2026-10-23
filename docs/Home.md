---
title: Vanguard Docs
aliases: [Home, Index, MOC]
tags: [moc]
---

# Vanguard

Ansible for the clients hosted on **hosting.thekrew.app**. Every client is an LXC reached over SSH on its own port, with all access guarded by a MikroTik CHR; all get the same [[Baseline]], then each group installs its own apps.

> [!tip] Open this folder as an Obsidian vault
> `docs/` is a vault. Open it with *Open folder as vault*. Links are `[[wikilinks]]`, notes are tagged by type (`#app`, `#concept`, `#guide`, `#runbook`, `#reference`) and the graph view colours them.

## Start here
- [[Architecture]] — how the repo, the hosts and the playbooks fit together
- [[Quickstart]] — tooling, keys, first run
- [[Command Cheatsheet]] — every `just` / `ansible` command you'll use

## Apps
| App | Group | Playbook | Note |
|---|---|---|---|
| Common base | all | `baseline.yml` | [[Baseline]] |
| Steam dedicated servers | `steamcmd` | `steamcmd.yml` | [[Steam Servers]] |
| FoundryVTT | `foundryvtt` | `foundry.yml` | [[FoundryVTT]] |
| Minecraft modpack servers | `minecraft` | `minecraft.yml` | [[Minecraft]] |

## Concepts
[[Inventory and Groups]] · [[Variables and Precedence]] · [[Unprivileged App Users]] · [[Launcher Scripts]] · [[Login Messages]]

## Guides
[[Add a Client]] · [[Add a Group]] · [[Test on a Dummy LXC]] · [[Secrets and Vault]]

## Runbooks
[[Daily Operations]] · [[Migrate Foundry to the foundry user]] · [[Update Things]] · [[Troubleshooting]] · [[Restore Debian Banner]]

## Reference
[[Hosts]] · [[File Map]] · [[Templates]] · [[Minecraft Variables]] · [[Steam Server Variables]]
