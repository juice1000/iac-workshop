# TODO: terraform-Block mit required_providers fuer local (hashicorp/local, ~> 2.5)

resource "local_file" "info" {
  # TODO: filename = <ausgabe_ordner>/<prefix>-<name>.txt
  # TODO: content = "Server <name>, Rolle <rolle>, SSH-Port <port>\n" mit den Modul-Variablen
}

#
# OPTIONAL / GUT ZU WISSEN
# - Ein Modul deklariert seine Provider nur in required_providers, konfiguriert sie aber nicht (das macht der Aufrufer).
# - Versionsbedingung ins Modul: required_version und Provider-Mindestversion.
