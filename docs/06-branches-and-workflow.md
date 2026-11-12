# Branches and workflow

## Repository

- GitHub: https://github.com/juice1000/iac-workshop (public)
- Local clone on Julien's Mac: `~/Documents/Coding/iac-workshop`

## Branches

| Branch | Audience | Content |
| --- | --- | --- |
| `main` | Trainer | Complete solution, docs, CI |
| `start` | Participants | `main` with gaps to fill in (`TODO` comments) in every lab block and in the mini project role tasks, without the trainer docs (`docs/`, `CLAUDE.md`), plus a note in the README |

Participants clone with `git clone -b start https://github.com/juice1000/iac-workshop.git`. After the mini project they can compare with `git fetch origin main && git diff start origin/main -- miniprojekt/`.

`start` is `main` plus commits that:

- turn the lab files into exercises: the block explanations (what, why) stay, one or more pieces per block are replaced by a `TODO` comment (same layout as the `practice` branch, without the optional extras)
- add `.yamllint` and a note at the top of `README.md`
- delete the trainer docs `docs/` and `CLAUDE.md`

The exercise files are listed in `scripts/check-start-branch.sh`. Related branches for the trainer: `practice` (the same gaps plus optional extras as comments) and `practice-solved` (everything filled in).

## Keeping start in sync

After every change on `main`:

```bash
git checkout start
git merge main
# conflicts happen when main changes one of the exercise files: keep the gaps (TODO), take the new text
git push origin start
git checkout main
```

Use merge, not rebase: participants may already have cloned `start`, so do not rewrite its history.

`start` has no `docs/` and no `CLAUDE.md`. If a merge brings back new files under `docs/`, remove them again (`git rm -r docs` and commit). `bash scripts/check-start-branch.sh` verifies the branch.

## Commits

- Commit messages in German, short subject line, ASCII only (Julien's existing style)
- Author: Julien Look
- Run fmt, validate, ansible-lint and shellcheck before pushing; CI repeats them plus the dry run
- Keep `main` green; check with `gh run list`

## Files that also live in Notion

Lab solutions are duplicated on the Notion pages. When lab code changes, update the matching page (see `08-notion.md`).
