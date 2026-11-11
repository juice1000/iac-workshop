# Lab 2: Variablen, Locals, for_each, Outputs, templatefile (Uebung)
# Ziel: eine Datei pro Server und out/inventory.ini aus templates/inventory.tftpl
# Zeilen mit "#   " (Raute und drei Leerzeichen) sind Code zum Einkommentieren.

# TODO: terraform-Block mit required_version >= 1.6 und required_providers
#       random (hashicorp/random, ~> 3.6) und local (hashicorp/local, ~> 2.5)

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

# Eine Datei pro Server (for_each ueber eine Map)
resource "local_file" "server_info" {
  # TODO: for_each ueber var.server

  # TODO: filename = out/<prefix>-<servername>.txt im Ordner des Moduls
  # TODO: content = "Server <name>, Rolle <rolle>, SSH-Port <port>\n"
  #       Tipp: each.key und each.value.rolle / each.value.port

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
# OPTIONAL: Wiederholte verschachtelte Bloecke aus einer Liste (dynamic)
#   # Beispiel mit dem docker-Provider, siehe modules/linux-server:
#   dynamic "ports" {
#     for_each = var.weitere_ports
#     content {
#       internal = ports.value.intern
#       external = ports.value.extern
#     }
#   }
# OPTIONAL: Ressource umbenennen, ohne sie neu zu erzeugen.
#   Erst den Namen der Ressource aendern (server_info -> server_datei), dann den moved-Block ergaenzen.
#   Der alte Name darf danach nicht mehr als Ressource existieren.
#   moved {
#     from = local_file.server_info
#     to   = local_file.server_datei
#   }

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
# OPTIONAL: vorhandene Datei oder URL lesen
#   data "local_file" "readme" {
#     filename = "${path.module}/README.md"
#   }
#   data "http" "beispiel" {
#     url = "https://example.com"        # Provider hashicorp/http
#   }
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
