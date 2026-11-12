# Lab 4: Lab 2 als Modul
# Das Root-Modul ruft das Modul in modules/server-info pro Server auf.

# TODO: terraform-Block mit required_version >= 1.6 und dem Provider local (~> 2.5)

# TODO: variable "umgebung" (string, Default "schulung")
# TODO: variable "server" wie in Lab 2 (map von Objekten mit rolle und port, gleicher Default)

# BLOCK module "NAME" { }
# Was: ruft ein anderes Terraform-Verzeichnis (ein Modul) auf und gibt ihm Eingaben (die Variablen
#      des Moduls). source sagt, wo das Modul liegt (Pfad, Registry, Git).
# Wozu: Wiederverwendung. Was man mehrfach braucht, schreibt man einmal als Modul. Ein Modul hat
#       Variablen als Eingang, Outputs als Ausgang und kapselt alles dazwischen.
# Mit for_each oder count entsteht pro Eintrag eine Modulinstanz: module.server_info["app1"].
module "server_info" {
  source = "./modules/server-info"
  # TODO: for_each ueber var.server

  # TODO: Eingaben name, rolle, port aus each.key / each.value
  # TODO: prefix wie in Lab 2, ausgabe_ordner = out/ im Ordner des Moduls
}

# Outputs des Moduls: das Root-Modul liest sie ueber module.<name>.<output>. Alles andere im Modul
# ist von aussen nicht sichtbar.
output "dateien" {
  # TODO: Map Servername -> Dateiname aus dem Modul-Output "datei"
  #       Tipp: for-Ausdruck ueber module.server_info
  value = {}
}
