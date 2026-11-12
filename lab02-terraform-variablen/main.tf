# Lab 2: Variablen, Locals, for_each, Outputs, templatefile
# Ziel: eine Datei pro Server und out/inventory.ini aus templates/inventory.tftpl

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
}

# random_password erzeugt einen Zufallswert und speichert ihn im State. Wozu: Passwoerter muss
# nicht der Mensch ausdenken. Nachteil: sie stehen im State, der deshalb geschuetzt werden muss.
# Ein Passwort, das Terraform erzeugt. Achtung: es landet im State!
resource "random_password" "db" {
  length = 20
  # TODO: keine Sonderzeichen (Argument special)
}

# for_each: erzeugt aus einer Map oder einem Set eine Ressource pro Eintrag. Innerhalb gibt es
# each.key (Schluessel) und each.value (Wert). Wozu: viele gleichartige Objekte aus einer Datenstruktur.
# Jede Instanz hat eine Adresse mit Schluessel: local_file.server_info["app1"].
# Eine Datei pro Server (for_each ueber eine Map)
resource "local_file" "server_info" {
  # TODO: for_each ueber var.server

  # TODO: filename = out/<prefix>-<servername>.txt im Ordner des Moduls
  # TODO: content = "Server <name>, Rolle <rolle>, SSH-Port <port>\n"
  #       Tipp: each.key und each.value.rolle / each.value.port
}

# templatefile(Pfad, Werte): fuellt eine Textvorlage (*.tftpl) mit Werten und liefert den Text.
# In der Vorlage gibt es Schleifen %{ for ... } und Bedingungen %{ if ... }.
# Wozu: Dateien erzeugen, die zur Infrastruktur passen, z. B. das Ansible-Inventory.
# Ansible-Inventory aus einer Vorlage erzeugen
resource "local_file" "inventory" {
  # TODO: filename = out/inventory.ini im Ordner des Moduls
  # TODO: content mit templatefile("${path.module}/templates/inventory.tftpl", { ... })
  #       Die Vorlage erwartet die Variablen server und rollen (siehe Vorlage)
}
