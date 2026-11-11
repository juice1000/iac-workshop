# Lab 2: Variablen, Locals, for_each, Outputs, templatefile (Uebung)
# Ziel: eine Datei pro Server und out/inventory.ini aus templates/inventory.tftpl
# Zeilen mit "#   " (Raute und drei Leerzeichen) sind Code zum Einkommentieren.

# TODO: terraform-Block mit required_version >= 1.6 und required_providers
#       random (hashicorp/random, ~> 3.6) und local (hashicorp/local, ~> 2.5)

# BLOCK locals { }
# Was: benannte Zwischenwerte, die nur innerhalb dieses Moduls gelten (Zugriff: local.name).
# Wozu: Ausdruecke einmal berechnen und mehrfach nutzen, statt sie zu wiederholen.
#       Anders als variable bekommen sie keinen Wert von aussen.
locals {
  # TODO: prefix = "tlbg-" plus var.umgebung
  # TODO: rollen = sortierte Liste aller Rollen ohne Duplikate.
  #       Tipp: for-Ausdruck ueber var.server, dazu distinct() und sort()

  # OPTIONAL: for-Ausdruck mit Filter, Splat und Funktionen (in locals schreiben)
  #   app_ports  = [for name, s in var.server : s.port if s.rolle == "app"]
  #   alle_ports = values(var.server)[*].port
  #   namen_gross = { for name, s in var.server : upper(name) => s.rolle }
  #   mit_standard = merge({ rolle = "app" }, { port = 22 })
  #   port_oder_22 = try(var.server["app1"].port, 22)
  #   netz         = cidrsubnet("172.30.0.0/16", 8, 1)   # ergibt 172.30.1.0/24
}

# random_password erzeugt einen Zufallswert und speichert ihn im State. Wozu: Passwoerter muss
# nicht der Mensch ausdenken. Nachteil: sie stehen im State, der deshalb geschuetzt werden muss.
# Ein Passwort, das Terraform erzeugt. Achtung: es landet im State!
resource "random_password" "db" {
  length = 20
  # TODO: keine Sonderzeichen (Argument special)
}
# OPTIONAL: weitere Argumente
#   min_upper = 2
#   min_numeric = 2
# OPTIONAL: Passwort nach einer Frist neu erzeugen (Provider time)
#   resource "time_rotating" "pw_rotation" {
#     rotation_days = 30
#   }
#   # in random_password:  keepers = { rotation = time_rotating.pw_rotation.id }

# for_each: erzeugt aus einer Map oder einem Set eine Ressource pro Eintrag. Innerhalb gibt es
# each.key (Schluessel) und each.value (Wert). Wozu: viele gleichartige Objekte aus einer Datenstruktur.
# Jede Instanz hat eine Adresse mit Schluessel: local_file.server_info["app1"].
# Eine Datei pro Server (for_each ueber eine Map)
resource "local_file" "server_info" {
  # TODO: for_each ueber var.server

  # TODO: filename = out/<prefix>-<servername>.txt im Ordner des Moduls
  # TODO: content = "Server <name>, Rolle <rolle>, SSH-Port <port>\n"
  #       Tipp: each.key und each.value.rolle / each.value.port

  # BLOCK lifecycle { } (in einer Ressource)
  # Was: Regeln, wie Terraform diese Ressource behandelt.
  #   precondition / postcondition: eigene Pruefungen mit klarer Fehlermeldung vor/nach dem Anlegen.
  #   create_before_destroy: neues Objekt zuerst anlegen, dann das alte loeschen.
  #   replace_triggered_by:  Ressource neu anlegen, wenn sich eine andere aendert.
  #   prevent_destroy:       Terraform bricht ab, wenn die Ressource geloescht werden soll.
  #   ignore_changes:        Aenderungen an diesen Argumenten werden ignoriert.
  # OPTIONAL: eigene Pruefung vor dem Erzeugen (in den Block schreiben)
  #   lifecycle {
  #     precondition {
  #       condition     = each.value.port >= 1024
  #       error_message = "Der SSH-Port muss mindestens 1024 sein."
  #     }
  #     create_before_destroy = true
  #     replace_triggered_by  = [random_password.db]
  #   }
}
# count: erzeugt n Kopien mit count.index (0, 1, 2 ...). Nachteil: Elemente werden ueber die Position
# adressiert, das Loeschen eines mittleren Elements verschiebt alle folgenden. for_each ist stabiler.
# OPTIONAL: count statt for_each (loescht man ein mittleres Element, verschieben sich die Indizes)
#   resource "local_file" "mit_count" {
#     count    = length(keys(var.server))
#     filename = "${path.module}/out/count-${count.index}.txt"
#     content  = "Index ${count.index}\n"
#   }
# OPTIONAL: Datei mit geheimem Inhalt (steht trotzdem im State)
#   resource "local_sensitive_file" "db_passwort" {
#     filename        = "${path.module}/out/db.pass"
#     content         = random_password.db.result
#     file_permission = "0600"
#   }
# BLOCK dynamic "NAME" { }
# Was: erzeugt einen verschachtelten Block (z. B. ports) mehrfach aus einer Liste oder Map.
# Wozu: wenn die Anzahl der inneren Bloecke von einer Variable abhaengt. for_each geht nur auf
#       Ressourcen, dynamic auf Bloecke in Ressourcen.
# OPTIONAL: Wiederholte verschachtelte Bloecke aus einer Liste (dynamic)
#   # Beispiel mit dem docker-Provider, siehe modules/linux-server:
#   dynamic "ports" {
#     for_each = var.weitere_ports
#     content {
#       internal = ports.value.intern
#       external = ports.value.extern
#     }
#   }
# BLOCK moved { }
# Was: sagt Terraform, dass eine Ressource ihre Adresse geaendert hat.
# Wozu: Umbenennen oder in ein Modul verschieben, ohne dass Terraform sie loescht und neu anlegt.
# OPTIONAL: Ressource umbenennen, ohne sie neu zu erzeugen.
#   Erst den Namen der Ressource aendern (server_info -> server_datei), dann den moved-Block ergaenzen.
#   Der alte Name darf danach nicht mehr als Ressource existieren.
#   moved {
#     from = local_file.server_info
#     to   = local_file.server_datei
#   }

# templatefile(Pfad, Werte): fuellt eine Textvorlage (*.tftpl) mit Werten und liefert den Text.
# In der Vorlage gibt es Schleifen %{ for ... } und Bedingungen %{ if ... }.
# Wozu: Dateien erzeugen, die zur Infrastruktur passen, z. B. das Ansible-Inventory.
# Ansible-Inventory aus einer Vorlage erzeugen
resource "local_file" "inventory" {
  # TODO: filename = out/inventory.ini im Ordner des Moduls
  # TODO: content mit templatefile("${path.module}/templates/inventory.tftpl", { ... })
  #       Die Vorlage erwartet die Variablen server und rollen (siehe Vorlage)
}
# OPTIONAL: Daten als JSON oder YAML schreiben
#   resource "local_file" "server_json" {
#     filename = "${path.module}/out/server.json"
#     content  = jsonencode(var.server)
#   }
#   # yamlencode(var.server) fuer YAML
# data-Block: liest Vorhandenes (siehe Lab 1). Hier eine Datei und eine Webseite (Provider http).
# OPTIONAL: vorhandene Datei oder URL lesen
#   data "local_file" "readme" {
#     filename = "${path.module}/README.md"
#   }
#   data "http" "beispiel" {
#     url = "https://example.com"        # Provider hashicorp/http
#   }
# BLOCK check "NAME" { }
# Was: Pruefung der laufenden Umgebung mit assert. Schlaegt sie fehl, gibt es nur eine Warnung.
# Wozu: Gesundheitspruefungen nach dem Apply (Webseite erreichbar?), ohne den Lauf abzubrechen.
#       Im Gegensatz zu precondition blockiert ein check nichts.
# OPTIONAL: Pruefung, die nur warnt und nichts blockiert (check-Block, gedacht fuer Aussenwelt)
#   check "webseite_erreichbar" {
#     data "http" "seite" {
#       url = "https://example.com"
#     }
#     assert {
#       condition     = data.http.seite.status_code == 200
#       error_message = "Die Webseite antwortet nicht mit 200."
#     }
#   }
#   # Achtung: fileexists() fuer Dateien, die dieselbe Konfiguration erzeugt, geht hier nicht.
