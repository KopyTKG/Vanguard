# Vanguard — Ansible task runner (tooling via mise, see mise.toml)

set shell := ["bash", "-cu"]

default:
    @just --list

# Install Ansible + Galaxy collections into the venv
deps:
    mise run setup

# SSH-reach the clients (subset: `just ping web` or `just ping client-a`)
ping limit="all":
    ansible {{limit}} -m ping

# Apply the shared baseline (subset: `just baseline web`)
baseline limit="all":
    ansible-playbook playbooks/baseline.yml --limit {{limit}}

# Install a group's apps: `just install web`
install group:
    ansible-playbook playbooks/{{group}}.yml

# Baseline + every group's apps
site:
    ansible-playbook playbooks/site.yml

# Dry-run any playbook: `just check baseline` / `just check web`
check play limit="all":
    ansible-playbook playbooks/{{play}}.yml --limit {{limit}} --check --diff
