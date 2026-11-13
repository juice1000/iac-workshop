#!/usr/bin/env bash
# Prueft den Branch "start" (Teilnehmerversion): Basis, Unterschiede zu main, Luecken, Syntax.
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
# Uebungsdateien mit Luecken (TODO), dazu README und yamllint-Konfiguration
UEBUNG="lab01-terraform-grundlagen/main.tf
lab02-terraform-variablen/main.tf
lab02-terraform-variablen/outputs.tf
lab02-terraform-variablen/variables.tf
lab03-ansible-grundlagen/playbook.yml
miniprojekt/terraform/main.tf
miniprojekt/ansible/roles/app/tasks/main.yml
miniprojekt/ansible/roles/postgresql/tasks/main.yml"
erlaubt="$(printf '.yamllint\nREADME.md\n%s\n' "$UEBUNG" | sort)"
# Trainer-Doku (docs/, CLAUDE.md) ist auf start absichtlich entfernt und zaehlt hier nicht mit
geaendert="$(git -C "$ROOT" diff --name-only main start | grep -Ev '^(docs/|CLAUDE\.md$)' | sort || true)"
echo "$geaendert"
if [ "$geaendert" != "$erlaubt" ]; then
  echo "Hinweis: erwartet waren nur:" >&2
  echo "$erlaubt" >&2
  fehler "start unterscheidet sich in unerwarteten Dateien"
fi

echo "== Trainer-Doku ist auf start entfernt"
if git -C "$ROOT" cat-file -e start:CLAUDE.md 2>/dev/null || git -C "$ROOT" cat-file -e start:docs 2>/dev/null; then
  fehler "docs/ oder CLAUDE.md liegen noch auf start"
fi

git -C "$ROOT" worktree add --detach "$TMP/start" start >/dev/null 2>&1
cd "$TMP/start"

echo "== Jede Uebungsdatei hat Luecken (TODO) und keine optionalen Teile"
for f in $UEBUNG; do
  grep -q 'TODO' "$f" || fehler "$f enthaelt kein TODO"
  if grep -q 'OPTIONAL' "$f"; then fehler "$f enthaelt optionale Teile"; fi
done

echo "== Syntaxcheck der Playbooks"
(cd miniprojekt/ansible && ansible-playbook --syntax-check -i localhost, site.yml >/dev/null)
(cd lab03-ansible-grundlagen && ansible-playbook --syntax-check -i localhost, playbook.yml >/dev/null)
(cd lab05-ansible-rolle && ansible-playbook --syntax-check -i localhost, site.yml >/dev/null)

echo "== terraform fmt und validate"
# Die Labs 1, 2 und das Terraform im Miniprojekt haben absichtlich Luecken und sind nicht validierbar.
# Dort prueft fmt nur die Syntax.
terraform fmt -check -recursive >/dev/null || fehler "terraform fmt"
for d in umgebung lab04-terraform-module; do
  (cd "$d" && terraform init -backend=false -input=false >/dev/null && terraform validate -no-color >/dev/null) || fehler "validate in $d"
done

echo "start OK"
