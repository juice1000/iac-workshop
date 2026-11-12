# Testing

## scripts/dry-run.sh

Runs every lab in teaching order and fails on the first problem. Cleans up all Terraform roots on exit (trap). Takes about 5 to 10 minutes.

What it checks:

- lab 0 check (non-fatal)
- both `erste-schritte` walkthroughs (`rundgang.sh` exit code = number of failed steps), plus idempotence of `erste-schritte/ansible/hallo.yml`
- lab 1: apply, file exists, second plan is empty (`-detailed-exitcode`), destroy
- lab 2: inventory has `[app]` and the app1 line, sensitive output not empty, validation rejects `umgebung=dev`
- lab 4: module address in state
- `umgebung` apply, then lab 3: ping with retries, ad-hoc, playbook, idempotence, check/diff with port 8081, apply 8081, uri on 8081
- lab 5: playbook, idempotence
- mini project: Terraform apply, playbook, idempotence, curl contains "DB OK", port 5432 not reachable from the host

Idempotence is detected by grepping `changed=[1-9]` in the second run.

## Other scripts

| Script | Purpose |
| --- | --- |
| `scripts/gfu-reach.sh [host] [port]` | Reachability test for the RDP endpoint (DNS, TCP, answer to an RDP connection request). No credentials. Defaults to `rdp.gfu.cloud 44400` |
| `scripts/check-start-branch.sh` | Checks `start`: based on `main`, differs only in README, `.yamllint` and the exercise files, every exercise file has `TODO` gaps and no `OPTIONAL` parts, syntax check, fmt, validate (only `umgebung` and the mini project, the labs have gaps on purpose) |
| `scripts/test-cleanup.sh` | Interrupts the dry run (SIGINT) during the mini project and checks that no containers or networks remain |
| `setup-wsl.sh` (repo root) | Participant setup for Ubuntu on WSL2: installs Docker, Ansible, Terraform, adds the user to `docker`, runs `lab00-check`. Idempotent. Not run in CI (needs sudo, systemd), only linted with shellcheck. See `09-windows-wsl-setup.md` |
| `scripts/dry-run-vm.sh` | Variant B (Linux VMs): runs labs 3, 5 and optionally the mini project against `INVENTORY` and `MINI_INVENTORY`. Needs SSH and sudo on the hosts |

`lab00-check/check.sh` also checks Terraform >= 1.6, the `community.postgresql` collection, Docker Hub and the Ubuntu mirrors.

## CI

`.github/workflows/test.yml`, runs on push to `main`, on pull requests and manually.

- Job `lint`: `terraform fmt -check -recursive`, `terraform init -backend=false` + `validate` in every Terraform root, `ansible-lint` in every Ansible dir, `shellcheck`
- Job `dry-run`: `bash scripts/dry-run.sh` on ubuntu-24.04 (Terraform via `hashicorp/setup-terraform@v3`, Ansible via pip)
- Not triggered for the `start` branch on purpose (its mini project tasks are empty, the smoke test would fail)

First green run: 2026-11-09 (Terraform 1.17.1, ansible-core 2.21, Docker 28).

Useful commands:

```bash
gh run list -R juice1000/iac-workshop -L 5
gh run view <id> -R juice1000/iac-workshop --log-failed
gh workflow run Test -R juice1000/iac-workshop
```

## Local testing on Julien's Mac

Julien has Terraform and OrbStack (Docker) on macOS. Tested 2026-11-09: `bash scripts/dry-run.sh` passes (Terraform 1.13.2, ansible-core 2.21.6, Docker 29.4.0), also from a cold start (image and providers removed). macOS ships bash 3.2; the scripts avoid bash 4 features.

Local `ansible-lint` from Homebrew uses its own ansible-core and does not see the collections (`unknown-module community.postgresql...`). Lint in a venv with `pip install ansible ansible-lint`, as CI does.

## Pitfalls already solved

| Problem | Fix |
| --- | --- |
| nginx failed during `apt install` (`Address family not supported`, no IPv6 in container, default site listens on `[::]:80`) | `policy-rc.d` in the image, Ansible starts services after configuring them |
| Lab 3 verify play failed in `--check` mode | `when: not ansible_check_mode` on the verify tasks |
| Lab 3 assert failed with a custom greeting | assert checks `inventory_hostname` instead of "Hallo" |
| ansible-lint `var-naming[no-role-prefix]` in lab 5 | role variables renamed to `webserver_*` |
| `terraform validate` rejects `-input=false` | dry run uses `TF_INPUT=0` instead |
| templatefile variable named `module` | renamed to `knoten` |

## What is not tested

- `setup-wsl.sh` on a fresh Ubuntu (only its individual commands were run by hand on the GFU desktop, and a re-run on that machine)
- Docker Desktop on Windows with WSL2 (cgroup v2): CI uses Docker on Ubuntu with cgroup v2, which is the closest proxy
- The OpenStack example snippet in Notion page 2.5 (orientation only)
