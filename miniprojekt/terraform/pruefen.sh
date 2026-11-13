#!/usr/bin/env bash
# Checkpoints fuer den Terraform-Teil des Miniprojekts. Das Skript aendert nichts, es prueft nur.
# Ihr fuehrt es zwischendurch aus, um zu sehen, ob der letzte Schritt funktioniert, bevor ihr weitermacht.
#
# Aufruf im Ordner miniprojekt/terraform, je ein Checkpoint:
#   bash pruefen.sh init        Checkpoint 1: versions.tf (Provider werden geladen)
#   bash pruefen.sh variablen   Checkpoint 2: variables.tf (Namen, Typen, Standardwerte)
#   bash pruefen.sh validate    Checkpoint 3: main.tf und outputs.tf (alle Verweise stimmen, Format)
#   bash pruefen.sh plan        Checkpoint 4: terraform plan laeuft durch, locals sind richtig
#   bash pruefen.sh apply       Checkpoint 5: nach terraform apply (Server, Netz, Schluessel, Inventory, Ausgaben)
#   bash pruefen.sh             alle Checkpoints nacheinander
#
# Jede Pruefung meldet "OK: ..." oder "FEHLT: ... Hinweis: ..." mit der Stelle, die ihr euch ansehen sollt.
# Alle Pruefungen eines Checkpoints laufen durch, damit ihr alle Ergebnisse auf einmal seht.
# Am Ende steht, wie viele fehlgeschlagen sind. Der Exit-Code ist diese Zahl (0 = alles gruen).
# Danach geht es mit Ansible weiter: im Ordner ../ansible "ansible-playbook pruefen.yml --tags verbindung".
set -uo pipefail

cd "$(dirname "$0")" || exit 1
FEHLER=0

ok() { printf 'OK: %s\n' "$*"; }
fehlt() {
  printf 'FEHLT: %s\n' "$*"
  FEHLER=$((FEHLER + 1))
}
titel() { printf '\n===== %s\n' "$*"; }

# Eine Pruefung: pruef "Beschreibung" "Hinweis" befehl ...  (Befehl gelingt = OK)
pruef() {
  local text="$1" hinweis="$2"
  shift 2
  if "$@" >/dev/null 2>&1; then ok "$text"; else fehlt "$text. Hinweis: $hinweis"; fi
}

# Vergleich: gleich "Beschreibung" "Hinweis" "gefunden" "erwartet"  (beide Werte gleich = OK)
gleich() {
  if [ "$3" = "$4" ]; then ok "$1"; else fehlt "$1 (gefunden: ${3:-nichts}, erwartet: $4). Hinweis: $2"; fi
}

# Die ersten Zeilen einer Terraform-Fehlermeldung zeigen, damit man sieht, was nicht stimmt
fehlerauszug() { sed 's/\x1b\[[0-9;]*m//g' | grep -E "Error|on .* line|│ " | head -8 | sed 's/^/    /'; }

# Wert eines Ausdrucks aus dem Terraform-Code lesen (wie terraform console)
konsole() { printf '%s\n' "$1" | terraform console -no-color 2>/dev/null | tail -n 1; }

cp_init() {
  titel "Checkpoint 1: versions.tf, Provider laden"
  if [ ! -s versions.tf ] || ! grep -q '^terraform' versions.tf; then
    fehlt "versions.tf enthaelt noch keinen terraform-Block. Hinweis: TODO am Anfang der Datei, Muster umgebung/versions.tf"
    return
  fi
  if out="$(terraform init -input=false -no-color 2>&1)"; then
    ok "terraform init laeuft durch"
  else
    fehlt "terraform init schlaegt fehl. Hinweis: source und version der Provider in versions.tf"
    printf '%s\n' "$out" | fehlerauszug
    return
  fi
  for p in kreuzwerker/docker hashicorp/tls hashicorp/local; do
    pruef "Provider $p ist geladen" "required_providers in versions.tf (source $p)" grep -q "registry.terraform.io/$p" .terraform.lock.hcl
  done
  pruef "Format stimmt (terraform fmt)" "terraform fmt im Ordner ausfuehren" terraform fmt -check -diff versions.tf
}

# Wert aus variables.tf allein lesen, damit unfertige Dateien (main.tf, outputs.tf) nicht stoeren
variablenwert() {
  local tmp out
  tmp="$(mktemp -d)"
  cp variables.tf "$tmp/"
  out="$(cd "$tmp" && printf '%s\n' "$1" | terraform console -no-color 2>&1 | tail -n 1)"
  rm -rf "$tmp"
  printf '%s' "$out"
}

cp_variablen() {
  titel "Checkpoint 2: variables.tf"
  for v in umgebung netz app_port; do
    pruef "Variable $v ist deklariert" "variable \"$v\" in variables.tf (type und default)" grep -q "variable \"$v\"" variables.tf
  done
  gleich "umgebung hat den Standardwert schulung" "default in variables.tf (Text in Anfuehrungszeichen)" "$(variablenwert var.umgebung)" '"schulung"'
  gleich "netz hat den Standardwert 172.30.0.0/24" "default in variables.tf (Text in Anfuehrungszeichen)" "$(variablenwert var.netz)" '"172.30.0.0/24"'
  gleich "app_port ist die Zahl 8080" "type = number und default = 8080 (ohne Anfuehrungszeichen)" "$(variablenwert var.app_port)" '8080'
  pruef "Format stimmt (terraform fmt)" "terraform fmt im Ordner ausfuehren" terraform fmt -check -diff variables.tf
}

cp_validate() {
  titel "Checkpoint 3: main.tf und outputs.tf (validate)"
  [ -d .terraform ] || {
    fehlt "Provider fehlen noch. Hinweis: zuerst bash pruefen.sh init"
    return
  }
  if out="$(terraform validate -no-color 2>&1)"; then
    ok "terraform validate: die Konfiguration ist in sich stimmig"
  else
    fehlt "terraform validate meldet Fehler. Hinweis: fehlende Ressource, Variable oder Tippfehler im Namen"
    printf '%s\n' "$out" | fehlerauszug
  fi
  for r in 'tls_private_key" "lab' 'local_sensitive_file" "private_key' 'docker_image" "linux' 'docker_network" "projekt' 'local_file" "inventory'; do
    pruef "Ressource ${r//\" \"/.} ist in main.tf" "Block resource \"${r%%\"*}\" fehlt oder heisst anders" grep -q "resource \"$r\"" main.tf
  done
  pruef "Modul server ist in main.tf" "Block module \"server\" fehlt" grep -q 'module "server"' main.tf
  for o in app_url ssh db_ip; do
    pruef "Ausgabe $o ist in outputs.tf" "output \"$o\" in outputs.tf" grep -q "output \"$o\"" outputs.tf
  done
  pruef "Pfad zum Dockerfile ist gesetzt (kein TODO in main.tf)" "filesha1 in docker_image.linux: Pfad zu ../../docker/Dockerfile" bash -c '! grep -q "TODO" main.tf'
  pruef "Format stimmt (terraform fmt)" "terraform fmt im Ordner ausfuehren" terraform fmt -check -diff
}

cp_plan() {
  titel "Checkpoint 4: terraform plan und locals"
  [ -d .terraform ] || {
    fehlt "Provider fehlen noch. Hinweis: zuerst bash pruefen.sh init"
    return
  }
  gleich "local.server enthaelt app1 und db1" "Eintrag db1 in den locals (Muster: app1 darueber)" "$(konsole 'join(",", sort(keys(local.server)))')" '"app1,db1"'
  gleich "db1 hat die IP 172.30.0.21 (Host 21 im Netz)" "ip = cidrhost(var.netz, 21)" "$(konsole 'local.server["db1"].ip')" '"172.30.0.21"'
  gleich "db1 hat den SSH-Port 2202" "ssh_port = 2202 im Eintrag db1" "$(konsole 'local.server["db1"].ssh_port')" '2202'
  gleich "db1 hat die Rolle db" "rolle = \"db\" im Eintrag db1" "$(konsole 'local.server["db1"].rolle')" '"db"'
  gleich "db1 veroeffentlicht keine Ports (Anzahl 0)" "ports = [] im Eintrag db1, der DB-Port wird nicht veroeffentlicht" "$(konsole 'length(local.server["db1"].ports)')" '0'
  gleich "local.rollen ist app,db" "rollen-Zeile in den locals nicht aendern" "$(konsole 'join(",", local.rollen)')" '"app,db"'
  # plan: -detailed-exitcode liefert 0 (keine Aenderung), 2 (Aenderungen) oder 1 (Fehler)
  out="$(terraform plan -input=false -no-color -detailed-exitcode 2>&1)"
  code=$?
  if [ "$code" = 1 ]; then
    fehlt "terraform plan schlaegt fehl. Hinweis: Fehler unten beheben, meist ein Wert mit null oder ein TODO"
    printf '%s\n' "$out" | fehlerauszug
  elif [ "$code" = 0 ]; then
    ok "terraform plan: keine Aenderungen (die Umgebung steht schon)"
  else
    plan="$(printf '%s\n' "$out" | grep -E '^Plan:')"
    ok "terraform plan laeuft durch: $plan"
    case "$plan" in
      *"Plan: 7 to add, 0 to change, 0 to destroy"*) ok "7 Ressourcen: Schluessel, Schluesseldatei, Image, Netz, zwei Server, Inventory" ;;
      *) printf '    Erwartet bei leerem State: Plan: 7 to add (Schluessel, Schluesseldatei, Image, Netz, 2 Server, Inventory)\n' ;;
    esac
  fi
}

cp_apply() {
  titel "Checkpoint 5: nach terraform apply"
  if ! terraform output -json >/dev/null 2>&1 || [ "$(terraform output -json 2>/dev/null)" = "{}" ]; then
    fehlt "Noch keine Ausgaben. Hinweis: terraform apply ausfuehren (und outputs.tf pruefen)"
    return
  fi
  gleich "app_url ist http://127.0.0.1:8080/" "output app_url in outputs.tf (Port aus var.app_port)" "$(terraform output -raw app_url 2>/dev/null)" "http://127.0.0.1:8080/"
  gleich "db_ip ist 172.30.0.21" "output db_ip in outputs.tf (local.server[\"db1\"].ip)" "$(terraform output -raw db_ip 2>/dev/null)" "172.30.0.21"
  ssh_aus="$(terraform output -json ssh 2>/dev/null)"
  case "$ssh_aus" in
    *'-p 2201'*'-p 2202'*) ok "ssh enthaelt je einen Befehl fuer app1 (Port 2201) und db1 (Port 2202)" ;;
    *) fehlt "ssh soll pro Server einen SSH-Befehl enthalten (Ports 2201 und 2202). Hinweis: for-Ausdruck in outputs.tf, Muster umgebung/outputs.tf" ;;
  esac
  # Dateirechte lesen: Linux (stat -c) und macOS (stat -f)
  modus="$(stat -c %a .ssh/id_lab 2>/dev/null || stat -f %Lp .ssh/id_lab 2>/dev/null || echo fehlt)"
  gleich "Schluessel .ssh/id_lab hat die Rechte 0600" "local_sensitive_file mit file_permission = \"0600\"" "$modus" "600"
  inv=../ansible/inventory.ini
  for eintrag in 'Gruppe [app]|^\[app\]' 'Gruppe [db]|^\[db\]' 'db_host=172.30.0.21|^db_host=172\.30\.0\.21' \
    'app_netz=172.30.0.0/24|^app_netz=172\.30\.0\.0/24' 'app_port=8080|^app_port=8080' 'Pfad zum Schluessel (ansible_ssh_private_key_file)|^ansible_ssh_private_key_file=/'; do
    pruef "inventory.ini enthaelt ${eintrag%%|*}" "rechte Seiten in local_file.inventory (main.tf), Vorlage templates/inventory.tftpl" grep -Eq "${eintrag#*|}" "$inv"
  done
  for c in tlbg-schulung-app1 tlbg-schulung-db1; do
    pruef "Container $c laeuft" "Modulaufruf in main.tf (name, image_id, network_name ...), docker ps" bash -c "[ \"\$(docker inspect -f '{{.State.Running}}' $c)\" = true ]"
  done
  pruef "Netz tlbg-schulung-netz hat das Subnetz 172.30.0.0/24" "ipam_config mit subnet = var.netz in docker_network.projekt" bash -c "docker network inspect tlbg-schulung-netz | grep -q '172.30.0.0/24'"
  pruef "app1 veroeffentlicht Port 8080" "weitere_ports = each.value.ports im Modulaufruf" bash -c "docker port tlbg-schulung-app1 | grep -q 8080"
  pruef "db1 veroeffentlicht den Datenbankport NICHT" "ports der db1 in den locals soll eine leere Liste sein" bash -c "! docker port tlbg-schulung-db1 | grep -q 5432"
  # Nur zur Information, zaehlt nicht als Fehler: Manche Docker-Umgebungen (z. B. OrbStack) melden nach dem apply
  # Unterschiede im Netz und in den Containern, obwohl nichts geaendert wurde (Eigenheit des Docker-Providers).
  if terraform plan -input=false -no-color -detailed-exitcode >/dev/null 2>&1; then
    ok "terraform plan: keine Aenderungen mehr (Zustand stimmt mit dem Code ueberein)"
  else
    printf 'INFO: terraform plan zeigt noch Aenderungen. Wenn sie Netz oder Container betreffen (ipam_config, log_opts), liegt es am Docker-Provider, nicht an euch. Fuehrt dann KEIN weiteres apply aus: es wuerde die Server neu bauen (danach muesste Ansible neu laufen).\n'
  fi
  printf '\nWeiter mit Ansible: cd ../ansible && ansible-playbook pruefen.yml --tags verbindung\n'
}

stufe="${1:-alle}"
case "$stufe" in
  init) cp_init ;;
  variablen) cp_variablen ;;
  validate) cp_validate ;;
  plan) cp_plan ;;
  apply) cp_apply ;;
  alle) cp_init; cp_variablen; cp_validate; cp_plan; cp_apply ;;
  *)
    echo "Unbekannter Checkpoint: $stufe (init, variablen, validate, plan, apply)" >&2
    exit 2
    ;;
esac

printf '\nErgebnis: %s Pruefung(en) fehlgeschlagen\n' "$FEHLER"
exit "$FEHLER"
