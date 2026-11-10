# Branches and workflow

## Repository

- GitHub: https://github.com/juice1000/iac-workshop (public)
- Local clone on Julien's Mac: `~/Documents/Coding/iac-workshop`

## Branches

| Branch | Audience | Content |
| --- | --- | --- |
| `main` | Trainer | Complete solution, docs, CI |
| `start` | Participants | `main` minus the mini project role tasks (empty list with the tasks as comments), minus the trainer docs (`docs/`, `CLAUDE.md`), plus a note in the README |

Participants clone with `git clone -b start https://github.com/juice1000/iac-workshop.git`. After the mini project they can compare with `git fetch origin main && git diff start origin/main -- miniprojekt/`.

`start` consists of `main` plus one commit ("Startversion: leere Rollen-Tasks im Miniprojekt") that:

- replaces `miniprojekt/ansible/roles/postgresql/tasks/main.yml` with commented task descriptions and `[]`
- replaces `miniprojekt/ansible/roles/app/tasks/main.yml` the same way
- adds a note at the top of `README.md`
- deletes the trainer docs `docs/` and `CLAUDE.md`

## Keeping start in sync

After every change on `main`:

```bash
git checkout start
git rebase main
# resolve conflicts if the two task files or the README top changed on main
git push --force-with-lease origin start
git checkout main
```

The start commit also deletes `docs/` and `CLAUDE.md`. If a rebase brings back new files under `docs/`, remove them again (`git rm -r docs` and amend). `bash scripts/check-start-branch.sh` verifies the branch.

## Commits

- Commit messages in German, short subject line, ASCII only (Julien's existing style)
- Author: Julien Look
- Run fmt, validate, ansible-lint and shellcheck before pushing; CI repeats them plus the dry run
- Keep `main` green; check with `gh run list`

## Files that also live in Notion

Lab solutions are duplicated on the Notion pages. When lab code changes, update the matching page (see `08-notion.md`).
