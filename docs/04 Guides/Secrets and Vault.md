---
title: Secrets and Vault
tags: [guide, security]
---

# Secrets and Vault

## Current state

| Secret | Where | Status |
|---|---|---|
| Client SSH keys | `~/.ssh/vanguard/<client>` | outside the repo ✔ |
| `steam_password` | `group_vars/steamcmd.yml` | **plaintext in git** ✘ |
| Vault password file | `.vault_pass` | gitignored; not created yet |

## Moving to ansible-vault

1. Create `.vault_pass` (it is gitignored — **never commit it**).
2. Uncomment in `ansible.cfg`:
   ```ini
   vault_password_file = .vault_pass
   ```
3. Encrypt the value:
   ```bash
   ansible-vault encrypt_string 'the-password' --name steam_password
   ```
   Paste the output into `group_vars/steamcmd.yml`.
4. Rotate the password on the host — the old one is in git history.

> [!danger] Before the repo goes anywhere public
> Do this first. The comment in `group_vars/steamcmd.yml` flags it as a TODO.

The Foundry and Minecraft users have **locked passwords**, so there is nothing to store for them — see [[Unprivileged App Users]].
