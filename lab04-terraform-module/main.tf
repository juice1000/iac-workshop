# Lab 4: Lab 2 als Modul (Uebung)
# Das Root-Modul ruft das Modul in modules/server-info pro Server auf.
# Zeilen mit "#   " (Raute und drei Leerzeichen) sind Code zum Einkommentieren.

# TODO: terraform-Block mit required_version >= 1.6 und dem Provider local (~> 2.5)

# TODO: variable "umgebung" (string, Default "schulung")
# TODO: variable "server" wie in Lab 2 (map von Objekten mit rolle und port, gleicher Default)

module "server_info" {
  source = "./modules/server-info"
  # TODO: for_each ueber var.server

  # TODO: Eingaben name, rolle, port aus each.key / each.value
  # TODO: prefix wie in Lab 2, ausgabe_ordner = out/ im Ordner des Moduls
}
# OPTIONAL: andere Modulquellen (Zeile "source" ersetzen)
#   source  = "terraform-aws-modules/vpc/aws"      # Registry
#   version = "~> 5.0"
#   source  = "git::https://github.com/juice1000/iac-workshop.git//lab04-terraform-module/modules/server-info?ref=main"
# OPTIONAL: Modul nur unter einer Bedingung aufrufen (statt for_each)
#   count = var.aktiv ? 1 : 0
# OPTIONAL: Modul zwei Mal mit anderen Eingaben (zweiter Aufruf)
#   module "server_info_test" {
#     source         = "./modules/server-info"
#     name           = "test1"
#     rolle          = "app"
#     port           = 2299
#     prefix         = "tlbg-test"
#     ausgabe_ordner = "${path.module}/out"
#   }
# OPTIONAL: Lab-2-Ressource in ein Modul verschieben, ohne sie zu zerstoeren
#   moved {
#     from = local_file.server_info["app1"]
#     to   = module.server_info["app1"].local_file.info
#   }

output "dateien" {
  # TODO: Map Servername -> Dateiname aus dem Modul-Output "datei"
  #       Tipp: for-Ausdruck ueber module.server_info
  value = {}
}
# OPTIONAL: Output nur anzeigen, wenn die Bedingung stimmt (in den Block schreiben)
#   precondition {
#     condition     = length(module.server_info) > 0
#     error_message = "Kein Server angelegt."
#   }
# OPTIONAL: Pruefung, die nur warnt und nichts blockiert (check-Block)
#   check "alle_server_da" {
#     assert {
#       condition     = length(module.server_info) == length(var.server)
#       error_message = "Es fehlt ein Server."
#     }
#   }
# OPTIONAL: Befehle
#   terraform init -upgrade      # Module und Provider neu laden
#   terraform graph              # Abhaengigkeiten als Graph (dot)
#   terraform state list         # zeigt module.server_info["app1"]...
