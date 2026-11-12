# Lab 2: Variablen, Locals, for_each, Outputs, templatefile

terraform {
  required_version = ">= 1.6"

  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }
}

# BLOCK locals { }
# Was: benannte Zwischenwerte, die nur innerhalb dieses Moduls gelten (Zugriff: local.name).
# Wozu: Ausdruecke einmal berechnen und mehrfach nutzen, statt sie zu wiederholen.
#       Anders als variable bekommen sie keinen Wert von aussen.
locals {
  prefix = "tlbg-${var.umgebung}"
  rollen = sort(distinct([for s in var.server : s.rolle]))
}

# random_password erzeugt einen Zufallswert und speichert ihn im State. Wozu: Passwoerter muss
# nicht der Mensch ausdenken. Nachteil: sie stehen im State, der deshalb geschuetzt werden muss.
# Ein Passwort, das Terraform erzeugt. Achtung: es landet im State!
resource "random_password" "db" {
  length  = 20
  special = false
}

# for_each: erzeugt aus einer Map oder einem Set eine Ressource pro Eintrag. Innerhalb gibt es
# each.key (Schluessel) und each.value (Wert). Wozu: viele gleichartige Objekte aus einer Datenstruktur.
# Jede Instanz hat eine Adresse mit Schluessel: local_file.server_info["app1"].
# Eine Datei pro Server (for_each ueber eine Map)
resource "local_file" "server_info" {
  for_each = var.server

  filename = "${path.module}/out/${local.prefix}-${each.key}.txt"
  content  = "Server ${each.key}, Rolle ${each.value.rolle}, SSH-Port ${each.value.port}\n"
}

# templatefile(Pfad, Werte): fuellt eine Textvorlage (*.tftpl) mit Werten und liefert den Text.
# In der Vorlage gibt es Schleifen %{ for ... } und Bedingungen %{ if ... }.
# Wozu: Dateien erzeugen, die zur Infrastruktur passen, z. B. das Ansible-Inventory.
# Ansible-Inventory aus einer Vorlage erzeugen
resource "local_file" "inventory" {
  filename = "${path.module}/out/inventory.ini"
  content = templatefile("${path.module}/templates/inventory.tftpl", {
    server = var.server
    rollen = local.rollen
  })
}
