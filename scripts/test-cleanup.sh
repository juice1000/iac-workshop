#!/usr/bin/env bash
# Bricht den Probelauf mitten im Miniprojekt ab und prueft, dass nichts zurueckbleibt.
# Aufruf aus dem Repository-Ordner: bash scripts/test-cleanup.sh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LOG="$(mktemp)"
trap 'rm -f "$LOG"' EXIT

vorher="$(docker ps -aq | sort | tr '\n' ' ')"
netze_vorher="$(docker network ls -q | sort | tr '\n' ' ')"

bash "$ROOT/scripts/dry-run.sh" >"$LOG" 2>&1 &
pid=$!

echo "Warte auf Miniprojekt-Phase (Probelauf PID ${pid})"
for _ in $(seq 1 300); do
  grep -q 'Miniprojekt: Ansible' "$LOG" && break
  kill -0 "$pid" 2>/dev/null || { echo "FEHLER: Probelauf vorzeitig beendet"; tail -n 20 "$LOG"; exit 1; }
  sleep 3
done

echo "Abbruch per SIGINT"
kill -INT "$pid"
wait "$pid" 2>/dev/null || true

nachher="$(docker ps -aq | sort | tr '\n' ' ')"
netze_nachher="$(docker network ls -q | sort | tr '\n' ' ')"

if [ "$vorher" = "$nachher" ] && [ "$netze_vorher" = "$netze_nachher" ]; then
  echo "Aufraeumen OK: keine Container oder Netzwerke uebrig"
else
  echo "FEHLER: Reste vorhanden"
  docker ps -a
  docker network ls
  exit 1
fi
