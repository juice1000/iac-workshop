# Im Modul reicht required_providers: es sagt, welchen Provider das Modul braucht.
# Der Provider selbst wird nicht im Modul konfiguriert, sondern vom Aufrufer (Root-Modul).
# Ein Modul besteht ueblich aus main.tf (Ressourcen), variables.tf (Eingaben) und outputs.tf (Ausgaben).
# TODO: terraform-Block mit required_providers fuer local (hashicorp/local, ~> 2.5)

resource "local_file" "info" {
  # TODO: filename = <ausgabe_ordner>/<prefix>-<name>.txt
  # TODO: content = "Server <name>, Rolle <rolle>, SSH-Port <port>\n" mit den Modul-Variablen
}
