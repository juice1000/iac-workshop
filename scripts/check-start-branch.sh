#!/usr/bin/env bash
# Prueft den Branch "start" (Teilnehmerversion): Basis, Unterschiede zu main, Syntax, Lint.
# Aufruf aus dem Repository-Ordner: bash scripts/check-start-branch.sh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'git -C "$ROOT" worktree remove --force "$TMP/start" >/dev/null 2>&1 || true; rm -rf "$TMP"' EXIT

fehler() {
  printf 'FEHLER: %s\n' "$*" >&2
  exit 1
}

git -C "$ROOT" rev-parse --verify -q start >/dev/null || fehler "Branch start existiert nicht"

echo "== start basiert auf main"
git -C "$ROOT" merge-base --is-ancestor main start || fehler "start ist nicht auf main rebased (git rebase main)"

echo "== Unterschiede zu main"
erlaubt="README.md
miniprojekt/ansible/roles/app/tasks/main.yml
miniprojekt/ansible/roles/postgresql/tasks/main.yml"
geaendert="$(git -C "$ROOT" diff --name-only main start)"
echo "$geaendert"
if [ "$geaendert" != "$erlaubt" ]; then
  echo "Hinweis: erwartet waren nur:" >&2
  echo "$erlaubt" >&2
  fehler "start unterscheidet sich in unerwarteten Dateien (docs/ oder CLAUDE.md entfernt? dann hier anpassen)"
fi

git -C "$ROOT" worktree add --detach "$TMP/start" start >/dev/null 2>&1
cd "$TMP/start"

echo "== Rollen-Tasks sind leere Listen"
for f in miniprojekt/ansible/roles/app/tasks/main.yml miniprojekt/ansible/roles/postgresql/tasks/main.yml; do
  grep -Eq '^\[\]' "$f" || fehler "$f enthaelt keine leere Aufgabenliste"
done

echo "== Syntaxcheck der Playbooks"
(cd miniprojekt/ansible && ansible-playbook --syntax-check -i localhost, site.yml >/dev/null)
(cd lab03-ansible-grundlagen && ansible-playbook --syntax-check -i localhost, playbook.yml >/dev/null)
(cd lab05-ansible-rolle && ansible-playbook --syntax-check -i localhost, site.yml >/dev/null)

echo "== terraform fmt und validate"
terraform fmt -check -recursive >/dev/null || fehler "terraform fmt"
for d in lab01-terraform-grundlagen lab02-terraform-variablen lab04-terraform-module umgebung miniprojekt/terraform; do
  (cd "$d" && terraform init -backend=false -input=false >/dev/null && terraform validate -no-color >/dev/null) || fehler "validate in $d"
done

echo "start OK"
