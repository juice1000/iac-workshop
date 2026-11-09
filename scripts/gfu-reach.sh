#!/usr/bin/env bash
# Erreichbarkeitstest fuer den RDP-Zugang (ohne Zugangsdaten).
# Prueft DNS, TCP-Port und ob der Server auf eine RDP-Verbindungsanfrage antwortet.
# Aufruf: bash scripts/gfu-reach.sh [host] [port]
set -u

host="${1:-rdp.gfu.cloud}"
port="${2:-44400}"
fehler=0

echo "Ziel: ${host}:${port}"

ip="$(dig +short "$host" 2>/dev/null | tail -n 1)"
if [ -z "$ip" ] && command -v getent >/dev/null 2>&1; then
  ip="$(getent hosts "$host" | awk '{print $1; exit}')"
fi
if [ -n "$ip" ]; then
  echo "  [OK]   DNS: ${ip}"
else
  echo "  [FEHLT] DNS: ${host} wird nicht aufgeloest"
  exit 1
fi

if nc -z -w 5 "$host" "$port" >/dev/null 2>&1; then
  echo "  [OK]   TCP ${port} offen"
else
  echo "  [FEHLT] TCP ${port} nicht erreichbar (Firewall oder Server aus)"
  exit 1
fi

# X.224-Verbindungsanfrage mit TLS/CredSSP-Aushandlung. Ein RDP-Server antwortet mit 0x03 (TPKT).
antwort="$(python3 -I - "$host" "$port" <<'PY'
import socket, sys
req = bytes.fromhex("0300002b26e00000000000436f6f6b69653a206d737473686173683d746573740d0a0100080003000000")
try:
    s = socket.create_connection((sys.argv[1], int(sys.argv[2])), timeout=8)
    s.sendall(req)
    s.settimeout(8)
    data = s.recv(64)
    print("ANTWORT" if data[:1] == b"\x03" else ("ZU" if not data else "ANDERS"))
except socket.timeout:
    print("STILLE")
except OSError:
    print("FEHLER")
PY
)"

case "$antwort" in
  ANTWORT) echo "  [OK]   RDP-Server antwortet auf die Anfrage" ;;
  STILLE)
    echo "  [FEHLT] Port offen, aber keine Antwort auf RDP (Rechner vermutlich nicht gestartet)"
    fehler=1
    ;;
  *)
    echo "  [FEHLT] Unerwartete Antwort (${antwort})"
    fehler=1
    ;;
esac

exit "$fehler"
