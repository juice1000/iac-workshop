# Lab 4: Lab 2 als Modul (Uebung)
# Ziel: das Modul in modules/server-info pro Server aufrufen
#
# TODO 1: terraform-Block mit Provider local
# TODO 2: Variablen umgebung (Default "schulung") und server (wie in Lab 2)
# TODO 3: module "server_info" mit for_each ueber var.server
#         Eingaben: name, rolle, port, prefix, ausgabe_ordner (${path.module}/out)
# TODO 4: output "dateien": Map Servername -> Dateiname aus den Modul-Outputs
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
