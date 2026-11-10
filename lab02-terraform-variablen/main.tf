# Lab 2: Variablen, Locals, for_each, Outputs, templatefile (Uebung)
# Ziel: eine Datei pro Server und out/inventory.ini aus templates/inventory.tftpl
#
# TODO 1: terraform-Block mit den Providern random und local
# TODO 2: locals: prefix = "tlbg-<umgebung>", rollen = sortierte Liste ohne Duplikate aller Rollen
# TODO 3: random_password "db", 20 Zeichen, ohne Sonderzeichen
# TODO 4: local_file "server_info" mit for_each ueber var.server,
#         Datei out/<prefix>-<name>.txt, Inhalt: Server, Rolle, SSH-Port
# TODO 5: local_file "inventory" mit templatefile(); die Vorlage erwartet die Variablen server und rollen
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
