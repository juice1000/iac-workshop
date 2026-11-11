#!/usr/bin/env bash
# Erste Schritte mit Terraform auf der Kommandozeile.
# Am besten tippt ihr die Befehle selbst. Dieses Skript zeigt sie der Reihe nach,
# fuehrt sie aus und wartet nach jedem Schritt auf Enter.
# Aufruf im Ordner erste-schritte/terraform: bash rundgang.sh
set -uo pipefail

cd "$(dirname "$0")" || exit 1
NR=0
FEHLER=0

# Schritt anzeigen, Befehl ausfuehren, auf Enter warten (nur im Terminal).
# Fehlgeschlagene Schritte werden gezaehlt, der Rundgang laeuft trotzdem weiter.
schritt() {
  local text="$1"
  shift
  NR=$((NR + 1))
  printf '\n===== Schritt %s: %s\n$ %s\n' "$NR" "$text" "$*"
  if ! bash -c "$*"; then
    printf '!!! Schritt %s ist fehlgeschlagen\n' "$NR"
    FEHLER=$((FEHLER + 1))
  fi
  if [ -t 0 ]; then
    read -r -p "--- Enter fuer weiter " _
  fi
}

schritt "Welche Version ist installiert?" \
  "terraform version"
schritt "Welche Befehle gibt es?" \
  "terraform -help"
schritt "Hilfe zu einem einzelnen Befehl" \
  "terraform plan -help | head -n 20"

schritt "Ordner vorbereiten (hier ohne Download, es gibt keine Provider)" \
  "terraform init"
schritt "Code einheitlich formatieren" \
  "terraform fmt"
schritt "Code pruefen, ohne etwas anzulegen" \
  "terraform validate"

schritt "Plan: was wuerde passieren?" \
  "terraform plan"
schritt "Anwenden (im Kurs ohne -auto-approve, dann fragt Terraform nach)" \
  "terraform apply -auto-approve"
schritt "Outputs lesen" \
  "terraform output"
schritt "Einen Output ohne Anfuehrungszeichen, z. B. fuer Skripte" \
  "terraform output -raw begruessung; echo"
schritt "Was steht im State?" \
  "terraform state list && terraform state show terraform_data.beispiel"
schritt "Noch einmal planen: keine Aenderungen" \
  "terraform plan"
schritt "Eine Variable von aussen setzen: zeigt ~ (aendern)" \
  "terraform plan -var name=Welt"

schritt "Ausdruecke ausprobieren mit terraform console" \
  "echo 'upper(local.begruessung)' | terraform console"
schritt "Noch ein Ausdruck: eine Liste umbauen" \
  "echo '[for s in local.server : \"\${s}.tlbg.local\"]' | terraform console"
schritt "Die Abhaengigkeiten als Graph (Text im DOT-Format)" \
  "terraform graph"

schritt "Was liegt jetzt im Ordner?" \
  "ls -la"
schritt "Aufraeumen" \
  "terraform destroy -auto-approve"
schritt "Und jetzt? Der State ist leer, das Backup enthaelt den Stand davor" \
  "ls -la && cat terraform.tfstate"

printf '\nRundgang fertig, %s Fehler.\n' "$FEHLER"
exit "$FEHLER"
