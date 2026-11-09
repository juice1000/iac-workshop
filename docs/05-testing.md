# Testing

## scripts/dry-run.sh

Runs every lab in teaching order and fails on the first problem. Cleans up all Terraform roots on exit (trap). Takes about 5 to 10 minutes.

What it checks:

- lab 0 check (non-fatal)
- lab 1: apply, file exists, second plan is empty (`-detailed-exitcode`), destroy
- lab 2: inventory has `[app]` and the app1 line, sensitive output not empty, validation rejects `umgebung=dev`
- lab 4: module address in state
- `umgebung` apply, then lab 3: ping with retries, ad-hoc, playbook, idempotence, check/diff with port 8081, apply 8081, uri on 8081
- lab 5: playbook, idempotence
- mini project: Terraform apply, playbook, idempotence, curl contains "DB OK", port 5432 not reachable from the host

Idempotence is detected by grepping `changed=[1-9]` in the second run.

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

Julien has Terraform and OrbStack (Docker) on macOS. The dry run should work there too (`bash scripts/dry-run.sh` from the repo root). Not tried yet. macOS ships bash 3.2; the scripts avoid bash 4 features, but watch for differences.

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

- The GFU lab environment itself (see `07-open-points.md`)
- Docker Desktop on Windows with WSL2 (cgroup v2): CI uses Docker on Ubuntu with cgroup v2, which is the closest proxy
- The OpenStack example snippet in Notion page 2.5 (orientation only)
