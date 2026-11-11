# Lab 4: Lab 2 als Modul (Uebung)
# Das Root-Modul ruft das Modul in modules/server-info pro Server auf.

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

module "server_info" {
  source = "./modules/server-info"
  # TODO: for_each ueber var.server

  # TODO: Eingaben name, rolle, port aus each.key / each.value
  prefix         = "tlbg-${var.umgebung}"
  ausgabe_ordner = "${path.module}/out"
}

output "dateien" {
  # TODO: Map Servername -> Dateiname aus dem Modul-Output "datei"
  #       Tipp: for-Ausdruck ueber module.server_info
  value = {}
}

#
# OPTIONAL / GUT ZU WISSEN
# - Modulquellen: lokaler Pfad, Terraform Registry (mit version = "~> 1.0"), Git (git::https://...?ref=v1.2.0).
# - Module mit count oder for_each, depends_on und eigenen Provider-Zuordnungen (providers = { ... }).
# - moved-Block: Ressourcen aus Lab 2 in ein Modul verschieben, ohne sie zu zerstoeren.
#     moved { from = local_file.server_info  to = module.server_info }
# - Modul-Outputs koennen ein anderes Modul speisen (Verkettung).
# - Ein Modul sollte klein sein und eine Aufgabe haben. Zu viele Variablen sind ein Warnsignal.
# - terraform get / init laedt Module. terraform graph zeigt die Abhaengigkeiten.
# - check-Block: Pruefung nach dem Apply, die nur warnt und nichts blockiert.
