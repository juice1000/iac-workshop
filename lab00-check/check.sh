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

echo "Versionen und Zusatzpakete:"
tf_version="$(terraform version 2>/dev/null | head -n 1 | sed -E 's/^[^0-9]*//')"
tf_major="${tf_version%%.*}"
tf_minor="${tf_version#*.}"
tf_minor="${tf_minor%%.*}"
if [ -n "$tf_version" ] && { [ "${tf_major:-0}" -gt 1 ] || { [ "${tf_major:-0}" -eq 1 ] && [ "${tf_minor:-0}" -ge 6 ]; }; }; then
  echo "  [OK]   Terraform ${tf_version} (mindestens 1.6)"
  ok=$((ok + 1))
else
  echo "  [FEHLT] Terraform mindestens 1.6 (gefunden: ${tf_version:-nichts})"
  fail=$((fail + 1))
fi
if ansible-galaxy collection list 2>/dev/null | grep -q 'community.postgresql'; then
  echo "  [OK]   Ansible-Collection community.postgresql"
  ok=$((ok + 1))
else
  echo "  [FEHLT] Ansible-Collection community.postgresql (ansible-galaxy collection install community.postgresql)"
  fail=$((fail + 1))
fi

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
check_url https://registry-1.docker.io/v2/
check_url http://archive.ubuntu.com/ubuntu/
check_url http://security.ubuntu.com/ubuntu/

echo
echo "Ergebnis: ${ok} OK, ${fail} fehlend"
[ "$fail" -eq 0 ]
