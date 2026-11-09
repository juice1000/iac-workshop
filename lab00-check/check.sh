#!/usr/bin/env bash
# Lab-Check: prueft Werkzeuge und Netzwerkzugriff in der Lernumgebung.
# Aufruf: bash lab00-check/check.sh
set -u

ok=0
fail=0

check_cmd() {
  local name="$1"
  shift
  if command -v "$name" >/dev/null 2>&1; then
    printf '  [OK]   %-10s %s\n' "$name" "$("$@" 2>&1 | head -n 1)"
    ok=$((ok + 1))
  else
    printf '  [FEHLT] %-10s\n' "$name"
    fail=$((fail + 1))
  fi
}

check_url() {
  local url="$1"
  if curl -s -o /dev/null -m 8 "$url"; then
    printf '  [OK]   %s\n' "$url"
    ok=$((ok + 1))
  else
    printf '  [FEHLT] %s\n' "$url"
    fail=$((fail + 1))
  fi
}

echo "Werkzeuge:"
check_cmd terraform terraform version
check_cmd ansible ansible --version
check_cmd git git --version
check_cmd docker docker --version
check_cmd python3 python3 --version
check_cmd ssh ssh -V

echo "Docker-Dienst:"
if docker info >/dev/null 2>&1; then
  echo "  [OK]   Docker laeuft"
  ok=$((ok + 1))
else
  echo "  [FEHLT] Docker laeuft nicht oder keine Rechte (Gruppe docker?)"
  fail=$((fail + 1))
fi

echo "Netzwerk:"
check_url https://registry.terraform.io/.well-known/terraform.json
check_url https://github.com
check_url https://galaxy.ansible.com

echo
echo "Ergebnis: ${ok} OK, ${fail} fehlend"
[ "$fail" -eq 0 ]
