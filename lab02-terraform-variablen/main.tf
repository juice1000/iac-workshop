# Lab 2: Variablen, Locals, for_each, Outputs, templatefile (Uebung)
# Ziel: eine Datei pro Server und out/inventory.ini aus templates/inventory.tftpl
#
# TODO 1: terraform-Block mit den Providern random und local
# TODO 2: locals: prefix = "tlbg-<umgebung>", rollen = sortierte Liste ohne Duplikate aller Rollen
# TODO 3: random_password "db", 20 Zeichen, ohne Sonderzeichen
# TODO 4: local_file "server_info" mit for_each ueber var.server,
#         Datei out/<prefix>-<name>.txt, Inhalt: Server, Rolle, SSH-Port
# TODO 5: local_file "inventory" mit templatefile(); die Vorlage erwartet die Variablen server und rollen
