---
title: Restore Debian Banner
tags: [runbook]
---

# Restore Debian Banner

Undo [[Login Messages]] quieting on one host (as root on that host):

```bash
rm -f /root/.hushlogin /home/foundry/.hushlogin      # and the other app users
chmod +x /etc/update-motd.d/*
# restore /etc/motd from the Debian default:
cat > /etc/motd <<'EOF'

The programs included with the Debian GNU/Linux system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
permitted by applicable law.
EOF
```

To keep the greeting but stop quieting for good, remove the `include_tasks: tasks/quiet-login.yml` step from the app playbook — otherwise the next run re-applies it.

To drop the how-to greeting too: `rm ~/.config/fish/functions/fish_greeting.fish` for that user (and remove the template task so it isn't recreated).
