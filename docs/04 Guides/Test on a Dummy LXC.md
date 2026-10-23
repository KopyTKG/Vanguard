---
title: Test on a Dummy LXC
tags: [guide]
---

# Test on a Dummy LXC

Foundry and Minecraft hosts are **live platforms**. Always rehearse on a throwaway LXC.

## Steps

1. Create a dummy LXC (e.g. `dummyvtt`, port 2212) and its key.
2. Add it to the relevant group; **comment out the live hosts** while testing so nothing touches them:
   ```yaml
   foundryvtt:
     hosts:
       #foundry: { ansible_port: 2210 }
       #cybervtt: { ansible_port: 2211 }
       dummyvtt: { ansible_port: 2212 }
   ```
3. Add `host_vars/dummyvtt.yml` if needed (e.g. `foundry_version: 12` to exercise the legacy template).
4. `just ping dummyvtt`
5. `just baseline dummyvtt`
6. `just check foundry dummyvtt` — expect the first as-user task to fail (see below).
7. `ansible-playbook playbooks/foundry.yml --limit dummyvtt`
8. Re-run step 7 — should change almost nothing (the mise task may report changed; [[Troubleshooting]]).
9. Verify as a user would: `ssh dummyvtt`, read the greeting, `foundry`, `foundry.sh status`.
10. Uncomment the live hosts and roll out.

> [!warning] Expected `--check` failure
> `sudo: unknown user foundry` on the first `become_user` task. Dry run doesn't create the user; the real run does.

## Verify checklist

- [ ] `id foundry` → no extra groups
- [ ] `crontab -l -u foundry` → `@reboot ... start`
- [ ] `su - foundry -c 'mise which node'` → path under `~/.local/share/mise`
- [ ] login shows only the how-to greeting
- [ ] launcher `start` without an install fails with `DIR does not exist` (guard works)
- [ ] fake `main.js` that sleeps: start / attach / stop / crash respawn behave

## Testing a launcher without the real app

Create the expected directory with a dummy entry point (a script that sleeps and handles SIGTERM) and exercise `start`, `attach`, `stop`, `logs`, and a nonzero exit to see the respawn loop.

Related: [[FoundryVTT]], [[Minecraft]], [[Daily Operations]].
