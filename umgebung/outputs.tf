# SSH-Befehl pro Server, zum Ausprobieren von Hand.
output "server" {
  value = { for name, s in module.server : name => "ssh -i ${local_sensitive_file.private_key.filename} -p ${s.ssh_port} root@127.0.0.1" }
}
