# Lab 4: Lab 2 als Modul. Das Root-Modul ruft das Modul pro Server auf.

terraform {
  required_version = ">= 1.6"

  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }
}

variable "umgebung" {
  type    = string
  default = "schulung"
}

variable "server" {
  type = map(object({
    rolle = string
    port  = number
  }))
  default = {
    app1 = { rolle = "app", port = 2201 }
    db1  = { rolle = "db", port = 2202 }
  }
}

# BLOCK module "NAME" { }
# Was: ruft ein anderes Terraform-Verzeichnis (ein Modul) auf und gibt ihm Eingaben (die Variablen
#      des Moduls). source sagt, wo das Modul liegt (Pfad, Registry, Git).
# Wozu: Wiederverwendung. Was man mehrfach braucht, schreibt man einmal als Modul. Ein Modul hat
#       Variablen als Eingang, Outputs als Ausgang und kapselt alles dazwischen.
# Mit for_each oder count entsteht pro Eintrag eine Modulinstanz: module.server_info["app1"].
module "server_info" {
  source   = "./modules/server-info"
  for_each = var.server

  name           = each.key
  rolle          = each.value.rolle
  port           = each.value.port
  prefix         = "tlbg-${var.umgebung}"
  ausgabe_ordner = "${path.module}/out"
}

# Outputs des Moduls: das Root-Modul liest sie ueber module.<name>.<output>. Alles andere im Modul
# ist von aussen nicht sichtbar.
output "dateien" {
  value = { for name, m in module.server_info : name => m.datei }
}
