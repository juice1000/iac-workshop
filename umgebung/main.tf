# Uebungsumgebung fuer die Ansible-Labs an Tag 1:
# zwei Linux-Server (Container mit systemd und SSH).

resource "tls_private_key" "lab" {
  algorithm = "ED25519"
}

resource "local_sensitive_file" "private_key" {
  filename        = "${path.module}/.ssh/id_lab"
  content         = tls_private_key.lab.private_key_openssh
  file_permission = "0600"
}

resource "docker_image" "linux" {
  name         = "tlbg-linux:lab"
  keep_locally = true

  build {
    context = "${path.module}/../docker"
  }

  triggers = {
    dockerfile = filesha1("${path.module}/../docker/Dockerfile")
  }
}

resource "docker_network" "lab" {
  name = "tlbg-umgebung"

  ipam_config {
    subnet = "172.31.0.0/24"
  }
}

module "server" {
  source   = "../modules/linux-server"
  for_each = var.server

  name         = each.key
  image_id     = docker_image.linux.image_id
  network_name = docker_network.lab.name
  ipv4_address = each.value.ip
  ssh_port     = each.value.ssh_port
  public_key   = tls_private_key.lab.public_key_openssh
}

resource "local_file" "inventory" {
  filename = "${path.module}/../lab03-ansible-grundlagen/inventory.ini"
  content = templatefile("${path.module}/templates/inventory.tftpl", {
    server   = module.server
    key_path = abspath(local_sensitive_file.private_key.filename)
  })
}
