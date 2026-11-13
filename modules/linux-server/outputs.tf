# Ausgaben des Moduls: Werte, die der Aufrufer lesen darf, z. B. module.server["server1"].ssh_port.
# umgebung und Miniprojekt reichen sie ans Inventory und an die Ausgabe weiter.
output "name" {
  value = docker_container.server.name
}

output "ssh_port" {
  value = var.ssh_port
}

output "ipv4_address" {
  value = var.ipv4_address
}
