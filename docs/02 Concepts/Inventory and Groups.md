---
title: Inventory and Groups
tags: [concept]
---

# Inventory and Groups

`inventory.yml` lists every client under the group for the app it runs. Connection details are shared via `group_vars/all.yml` (`ansible_host: hosting.thekrew.app`, `ansible_user: root`), so a host entry is just its port:

```yaml
foundryvtt:
  hosts:
    foundry: { ansible_port: 2210 }
```

## Current groups

| Group | Playbook | Hosts |
|---|---|---|
| `generic` | baseline only | esl, ts-server, grafana, proxy, jenkins |
| `steamcmd` | `steamcmd.yml` | avorion |
| `foundryvtt` | `foundry.yml` | foundry, cybervtt (+ test hosts) |
| `minecraft` | `minecraft.yml` | none yet |
| `web` | `web.yml` | worldle-web |
| `csharp` | — | worldle-api |
| `postgress` | — | worldle-db |

Full list with ports: [[Hosts]].

## Gotchas

> [!warning] A group and a host must not share a name
> Ansible warns `Found both group and host with same name` and targeting becomes ambiguous. That's why the FoundryVTT group is `foundryvtt`, not `foundry`, while the host is still `foundry`.

- **Commenting a host out** (`#foundry: ...`) removes it from every playbook, including baseline. That's the safe way to protect live hosts while testing.
- A host can be in several groups; group vars merge — see [[Variables and Precedence]].

Related: [[Add a Client]], [[Add a Group]].
