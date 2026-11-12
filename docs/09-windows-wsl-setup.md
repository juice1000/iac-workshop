# Windows desktops with WSL2

The GFU lab desktops run Windows (German UI). Participants work in Ubuntu 24.04 under WSL2, with Docker installed inside Ubuntu. `setup-wsl.sh` in the repo root does the setup.

## Findings from the trainer desktop (2026-11-12)

- User `Dozent`, Windows not activated, German UI
- Installed: Edge, Firefox, Chrome, VS Code, Oracle VirtualBox
- `wsl --status` and `wsl --install` print warnings about virtualization and nested virtualization. Ignore them: `wsl --install -d Ubuntu-24.04` worked, `uname -r` shows `...-microsoft-standard-WSL2` and Docker runs
- systemd is on by default in the Ubuntu 24.04 WSL image
- `apt` mirrors, Docker Hub, GitHub, galaxy.ansible.com and registry.terraform.io are reachable (`lab00-check` shows 15 OK, 0 missing)
- Ubuntu apt delivers Ansible core 2.16.3 and Docker 29.1.3. Terraform comes from the HashiCorp apt repo (1.17.2 on the day)
- `scripts/dry-run.sh` on branch `start`: labs 0 to 5 pass. The mini project Ansible step fails on `start` because the role tasks are empty on purpose

## What participants do

1. PowerShell as administrator: `wsl --install -d Ubuntu-24.04`, then choose a Unix user and password
2. In Ubuntu: `cd ~ && git clone -b start https://github.com/juice1000/iac-workshop.git && cd iac-workshop && bash setup-wsl.sh`
3. Close and reopen Ubuntu (docker group), check with `docker ps`

The same text is in the README (German). If the repo already exists: `cd ~/iac-workshop && git pull && bash setup-wsl.sh`.

## What the script does

Checks (not root, repo not under `/mnt`, systemd is PID 1), installs `docker.io ansible python3 git curl wget gnupg lsb-release ca-certificates openssh-client`, adds the HashiCorp repo and installs Terraform, enables Docker, adds the user to `docker`, makes sure `community.postgresql` exists, then runs `lab00-check/check.sh` (through `sg docker`, because the new group only applies in new shells). Re-running skips what is installed.

If systemd is not PID 1 it writes `/etc/wsl.conf`, asks for `wsl --shutdown` and exits.

## Quirks

| Symptom | Cause and fix |
| --- | --- |
| `permission denied ... docker.sock` | New group applies only in a new Ubuntu window |
| `could not create work tree dir` on clone | Shell is in `/mnt/c/...` (Windows side). `cd ~` first |
| Ansible ignores `ansible.cfg` | Repo is on `/mnt/c` (world-writable). Keep it in the Linux home |
| `sudo` asks for a password | The one chosen at Ubuntu first start |

## Not verified yet

- A fresh machine run of `setup-wsl.sh` (only its commands, and a re-run on the trainer desktop)
- Whether participants have admin rights for `wsl --install`
- VS Code with the WSL extension from the desktop (`code .`), and whether the desktop keeps Ubuntu between day 1 and day 2
