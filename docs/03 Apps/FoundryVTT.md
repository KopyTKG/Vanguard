---
title: FoundryVTT
aliases: [Foundry]
tags: [app]
---

# FoundryVTT (`foundryvtt` group)

`just install foundry` → `playbooks/foundry.yml`.

> [!warning] It does not download Foundry
> The build is licensed to you. Unpack it yourself into `~foundry/foundryvtt`.

## What the playbook does

1. installs `acl procps cron`;
2. creates `foundry` (fish, no sudo, locked password) — [[Unprivileged App Users]];
3. creates `/var/log/foundry` owned by `foundry`;
4. as `foundry`: activates mise in fish, installs the greeting, **installs latest Node LTS globally** (`mise use --global node@lts`);
5. templates `~foundry/foundry.sh` (v13+ or legacy template);
6. quiets the Debian login, enables cron, adds `@reboot` for `foundry`;
7. installs `/usr/local/bin/foundry` (root switch script) and root's login greeting.

## Layout on the host

```
/home/foundry/
├── foundry.sh          launcher (Ansible-managed)
├── foundryvtt/         unpacked Foundry build  ← you provide
└── foundrydata/        user data (--dataPath)   ← created by Foundry
/var/log/foundry/foundry.log      (+ .log.old)
```

## Version switch

| `foundry_version` | Template | Entry point |
|---|---|---|
| `> 12` (default 13) | `foundry.sh.j2` | `foundryvtt/main.js` |
| `<= 12` | `foundry-legacy.sh.j2` | `foundryvtt/resources/app/main.js` |

Set per host:

```yaml
# host_vars/cybervtt.yml
foundry_version: 12
```

## Variables

| Var | Default | File |
|---|---|---|
| `foundry_user` | `foundry` | `group_vars/foundryvtt.yml` |
| `foundry_home` | `/home/foundry` | same |
| `foundry_packages` | `acl procps cron` | same |
| `foundry_version` | `13` | same; override in host_vars |

The launcher CONFIG block (`ROOT`, `DATA`, `FOUNDRY_ROOT`, `TARGET`, timeouts, log paths) is in the template. Node is `eval mise which node` — see [[Launcher Scripts]].

## Using it

```bash
foundry                         # root → become foundry
foundry start | stop | restart | status | attach | logs 200
```

As `foundry`: `./foundry.sh <same commands>`. `stop` sends SIGTERM (Foundry has no console quit).

## Moving an existing install

[[Migrate Foundry to the foundry user]].

> [!bug] Check your version vars
> `host_vars/foundry.yml` and `cybervtt.yml` should reflect reality: foundry is **v13+** (`13`), cybervtt is **v12 or older** (`12`). A wrong value points `TARGET` at a file that doesn't exist and `start` refuses with `TARGET does not exist`.

Related: [[Login Messages]], [[Test on a Dummy LXC]], [[Troubleshooting]].
