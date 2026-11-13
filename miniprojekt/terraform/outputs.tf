# TODO: Schreibt die drei Ausgaben. Sie zeigen nach terraform apply, was ihr braucht (terraform output).
#
#   app_url   die Adresse der Anwendung: http://127.0.0.1:<app_port>/ (Port aus var.app_port)
#   ssh       eine Map: pro Server der SSH-Befehl  ssh -i <Schluesseldatei> -p <ssh_port> root@127.0.0.1
#             Der Schluessel liegt in local_sensitive_file.private_key (Attribut filename),
#             die Server kommen aus module.server (Attribut ssh_port)
#   db_ip     die IP-Adresse des Servers db1 aus local.server
#
# Muster: umgebung/outputs.tf (dort heisst die Ausgabe "server", SSH-Befehl und for-Muster sind gleich)
# Hilfe:  output "name" { value = ... }. Einen Wert aus einer Map holt man mit local.server["db1"].ip.
