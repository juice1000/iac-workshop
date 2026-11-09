output "app_url" {
  value = "http://127.0.0.1:${var.app_port}/"
}

output "ssh" {
  value = { for name, s in module.server : name => "ssh -i ${local_sensitive_file.private_key.filename} -p ${s.ssh_port} root@127.0.0.1" }
}

output "db_ip" {
  value = local.server["db1"].ip
}
