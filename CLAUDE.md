# CLAUDE.md

Training repository for a 2-day Terraform and Ansible intro workshop (client TLBG, delivered remotely via GFU, 11 and 12 November 2026). Julien is the trainer. This file is the entry point; details live in `docs/`.

## Read first

| Doc | What it covers |
| --- | --- |
| `docs/01-context.md` | Client, participants, goals, constraints, decision log |
| `docs/02-agenda.md` | 2-day schedule and which lab belongs to which block |
| `docs/03-architecture.md` | How the lab environment works (containers with systemd, ports, subnets, variants) |
| `docs/04-labs.md` | Every lab folder: purpose, files, expected results |
| `docs/05-testing.md` | Dry run, CI, local testing, known pitfalls |
| `docs/06-branches-and-workflow.md` | `main` vs `start`, how to keep them in sync, commit conventions |
| `docs/07-open-points.md` | What is still undecided or untested |
| `docs/08-notion.md` | Where the teaching material lives in Notion and how it maps to this repo |

## Commands

```bash
bash lab00-check/check.sh        # tools and network check
bash scripts/dry-run.sh          # full end-to-end run of all labs, cleans up after itself
terraform fmt -recursive         # before every commit
(cd <ansible-dir> && ansible-lint)
shellcheck lab00-check/check.sh scripts/*.sh
bash scripts/gfu-reach.sh        # RDP endpoint reachability
bash scripts/check-start-branch.sh
```

## Rules

- CI (`.github/workflows/test.yml`) must stay green on `main`. It runs fmt, validate, ansible-lint, shellcheck and `scripts/dry-run.sh`. Run the same checks locally before pushing when possible.
- Participant-facing text (README, comments in lab code, Notion lab pages) is German. Code comments use ASCII only (ae, oe, ue, ss), Markdown docs may use umlauts.
- Docs and trainer notes are English.
- No em dashes anywhere (Julien's preference).
- Keep labs small and beginner-friendly: the participants are senior admins but new to IaC. Prefer clarity over cleverness.
- Every Ansible playbook must be idempotent (second run `changed=0`); `scripts/dry-run.sh` enforces this.
- Role variables carry the role name as prefix (ansible-lint `var-naming`).
- Any change to lab code that is also shown in Notion must be mirrored there (see `docs/08-notion.md`).
- After changing `main`, update the `start` branch (see `docs/06-branches-and-workflow.md`).
- The repository is public: no credentials, no personal contact details.
