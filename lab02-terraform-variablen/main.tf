# Lab 2: Variablen, Locals, for_each, Outputs, templatefile (Uebung)
# Ziel: eine Datei pro Server und out/inventory.ini aus templates/inventory.tftpl

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

locals {
  prefix = "tlbg-${var.umgebung}"
  # TODO: rollen = sortierte Liste aller Rollen ohne Duplikate.
  #       Tipp: for-Ausdruck ueber var.server, dazu distinct() und sort()
}

# Ein Passwort, das Terraform erzeugt. Achtung: es landet im State!
resource "random_password" "db" {
  length = 20
  # TODO: keine Sonderzeichen (Argument special)
}

# Eine Datei pro Server (for_each ueber eine Map)
resource "local_file" "server_info" {
  # TODO: for_each ueber var.server

  filename = "${path.module}/out/${local.prefix}-${each.key}.txt"
  # TODO: content = "Server <name>, Rolle <rolle>, SSH-Port <port>\n"
  #       Tipp: each.key und each.value.rolle / each.value.port
}

# Ansible-Inventory aus einer Vorlage erzeugen
resource "local_file" "inventory" {
  filename = "${path.module}/out/inventory.ini"
  # TODO: content mit templatefile("${path.module}/templates/inventory.tftpl", { ... })
  #       Die Vorlage erwartet die Variablen server und rollen (siehe Vorlage)
}

#
# OPTIONAL / GUT ZU WISSEN
# - count gegen for_each: bei count verschiebt das Loeschen eines mittleren Elements alle Indizes
#   (Ressourcen werden neu erzeugt). for_each adressiert ueber den Schluessel und hat das Problem nicht.
# - lifecycle { prevent_destroy, create_before_destroy, ignore_changes, replace_triggered_by }
#   erklaert, warum Terraform etwas ersetzt oder eben nicht.
# - precondition und postcondition in lifecycle: eigene Pruefungen, z. B. Port im erlaubten Bereich.
# - dynamic-Bloecke erzeugen wiederholte verschachtelte Bloecke aus einer Liste.
# - Nuetzliche Funktionen: merge, lookup, try, coalesce, flatten, zipmap, toset, cidrsubnet,
#   jsonencode, yamlencode, file, fileexists, format, join, split.
# - for-Ausdruck mit Filter: [for s in var.server : s.port if s.rolle == "app"]
# - Splat: values(local_file.server_info)[*].filename
# - local_sensitive_file statt local_file, wenn der Inhalt geheim ist. Im State steht er trotzdem.
# - time_rotating erzeugt nach einer Frist einen neuen Wert (Passwort-Rotation).
# - data "local_file" liest eine vorhandene Datei, data "http" eine URL.
# - moved-Block: Ressource umbenennen, ohne sie neu zu erzeugen.
