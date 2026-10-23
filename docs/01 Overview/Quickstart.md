---
title: Quickstart
tags: [guide]
---

# Quickstart

## 1. Tooling

Tools are pinned by `mise.toml` (Python 3.13, repo-local `.venv`).

```bash
mise install     # Python + .venv
just deps        # ansible, passlib, and Galaxy collections (community.general, ansible.posix)
```

`passlib` backs the `password_hash` filter (Python 3.13 dropped stdlib `crypt`).

## 2. Keys

Each client needs its private key at:

```
~/.ssh/vanguard/<client-name>
```

Override per host in `host_vars/<client>.yml` with `ansible_ssh_private_key_file` if needed. `host_key_checking` is off in `ansible.cfg`.

## 3. Reach the clients

```bash
just ping                 # all
just ping foundry         # one client or group
```

## 4. Apply

```bash
just baseline <client>    # common base — always first on a new client
just install foundry      # a group's app playbook
just site                 # everything
```

## 5. Dry run

```bash
just check foundry dummyvtt
```

> [!warning] `--check` is not a full rehearsal
> Dry run can't create the app user, so the first task that runs *as* that user fails with `sudo: unknown user ...`. That's expected on a fresh host — do a real run on a [[Test on a Dummy LXC]].

Next: [[Command Cheatsheet]], [[Add a Client]].
