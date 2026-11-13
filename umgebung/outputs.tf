# SSH-Befehl pro Server, zum Ausprobieren von Hand. Die Schleife baut eine Map Name -> Befehl.
# -i nennt den privaten Schluessel, -p den Port am eigenen Rechner, root@127.0.0.1 ist das Ziel.
# Anzeigen mit: terraform output
output "server" {
  value = { for name, s in module.server : name => "ssh -i ${local_sensitive_file.private_key.filename} -p ${s.ssh_port} root@127.0.0.1" }
}
