# Lab 4: Lab 2 als Modul (Uebung)
# Das Root-Modul ruft das Modul in modules/server-info pro Server auf.
# Zeilen mit "#   " (Raute und drei Leerzeichen) sind Code zum Einkommentieren.
# ZUSATZMATERIAL (Branch additional-material): alle TODOs sind ausgefuellt, die optionalen Beispiele sind aktiv.
# Beispiele mit [NICHT AKTIV] bleiben bewusst auskommentiert, der Grund steht dabei.
# Optional in dieser Datei: andere Modulquellen, count als Bedingung, zweiter Modulaufruf, moved
#   ins Modul, precondition, check, Befehle.

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
# [OPTIONAL] Modulquellen: lokaler Pfad (./modules/...), Terraform Registry (mit version) oder Git (mit ?ref=).
# Mit version bzw. ref pinnt man den Stand, damit Aenderungen am Modul nicht ungeplant wirken.
# OPTIONAL: andere Modulquellen (Zeile "source" ersetzen)
# [NICHT AKTIV] Registry und Git brauchen ein anderes Modul. Hier zeigt source weiter auf ./modules/server-info.
#   source  = "terraform-aws-modules/vpc/aws"      # Registry
#   version = "~> 5.0"
#   source  = "git::https://github.com/juice1000/iac-workshop.git//lab04-terraform-module/modules/server-info?ref=main"
# OPTIONAL: Modul nur unter einer Bedingung aufrufen (statt for_each)
# [NICHT AKTIV] count und for_each lassen sich nicht mischen. Dieses Modul nutzt for_each.
#   count = var.aktiv ? 1 : 0
# OPTIONAL: Modul zwei Mal mit anderen Eingaben (zweiter Aufruf)
module "server_info_test" {
  source         = "./modules/server-info"
  name           = "test1"
  rolle          = "app"
  port           = 2299
  prefix         = "tlbg-test"
  ausgabe_ordner = "${path.module}/out"
}
# OPTIONAL: Lab-2-Ressource in ein Modul verschieben, ohne sie zu zerstoeren
moved {
  from = local_file.server_info["app1"]
  to   = module.server_info["app1"].local_file.info
}

# Outputs des Moduls: das Root-Modul liest sie ueber module.<name>.<output>. Alles andere im Modul
# ist von aussen nicht sichtbar.
output "dateien" {
  value = { for name, m in module.server_info : name => m.datei }

  precondition {
    condition     = length(module.server_info) > 0
    error_message = "Kein Server angelegt."
  }
}
# OPTIONAL: Output nur anzeigen, wenn die Bedingung stimmt (in den Block schreiben)
# Aktiv: die precondition steht oben im Output "dateien".
# OPTIONAL: Pruefung, die nur warnt und nichts blockiert (check-Block)
check "alle_server_da" {
  assert {
    condition     = length(module.server_info) == length(var.server)
    error_message = "Es fehlt ein Server."
  }
}
# OPTIONAL: Befehle
#   terraform init -upgrade      # Module und Provider neu laden
#   terraform graph              # Abhaengigkeiten als Graph (dot)
#   terraform state list         # zeigt module.server_info["app1"]...
