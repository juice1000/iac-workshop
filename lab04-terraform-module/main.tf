# Lab 4: Lab 2 als Modul (Uebung)
# Ziel: das Modul in modules/server-info pro Server aufrufen
#
# TODO 1: terraform-Block mit Provider local
# TODO 2: Variablen umgebung (Default "schulung") und server (wie in Lab 2)
# TODO 3: module "server_info" mit for_each ueber var.server
#         Eingaben: name, rolle, port, prefix, ausgabe_ordner (${path.module}/out)
# TODO 4: output "dateien": Map Servername -> Dateiname aus den Modul-Outputs
