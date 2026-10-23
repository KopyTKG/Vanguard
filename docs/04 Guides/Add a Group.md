---
title: Add a Group
tags: [guide]
---

# Add a Group

1. **Inventory** — add the group + hosts to `inventory.yml`. Name it differently from every host.
2. **Vars** — `group_vars/<group>.yml`: app user/home, packages, documented defaults.
3. **Playbook** — `playbooks/<group>.yml`. Copy `foundry.yml` (the cleanest recent example) and keep the shape:
   - assert required vars
   - install packages (include `acl`, `procps`, `cron`)
   - create an unprivileged user — [[Unprivileged App Users]]
   - create `/var/log/<app>` owned by the user
   - as the user: mise + runtime, greeting, app install
   - template the launcher, `include_tasks: tasks/quiet-login.yml`, `@reboot` cron
   - root switch script + root greeting
4. **Templates** — launcher (copy one — [[Launcher Scripts]]) and greeting(s) ([[Login Messages]]).
5. **`site.yml`** — add `- import_playbook: <group>.yml`.
6. **Docs** — add an app note under `03 Apps/`, link it in [[Home]].
7. `ansible-playbook playbooks/<group>.yml --syntax-check`, then [[Test on a Dummy LXC]].
