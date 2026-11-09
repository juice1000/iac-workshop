output "name" {
  value = docker_container.server.name
}

output "ssh_port" {
  value = var.ssh_port
}

output "ipv4_address" {
  value = var.ipv4_address
}
