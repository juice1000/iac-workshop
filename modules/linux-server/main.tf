# Ein Linux-"Server" als Docker-Container mit systemd und SSH.

terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

resource "docker_container" "server" {
  name     = var.name
  hostname = var.name
  image    = var.image_id

  # systemd im Container braucht diese Einstellungen
  privileged    = true
  cgroupns_mode = "host"
  tmpfs = {
    "/run"      = "rw"
    "/run/lock" = "rw"
  }
  volumes {
    host_path      = "/sys/fs/cgroup"
    container_path = "/sys/fs/cgroup"
    read_only      = false
  }

  networks_advanced {
    name         = var.network_name
    ipv4_address = var.ipv4_address
  }

  # SSH nur lokal erreichbar
  ports {
    internal = 22
    external = var.ssh_port
    ip       = "127.0.0.1"
  }

  dynamic "ports" {
    for_each = var.weitere_ports
    content {
      internal = ports.value.intern
      external = ports.value.extern
      ip       = "127.0.0.1"
    }
  }

  upload {
    content = var.public_key
    file    = "/root/.ssh/authorized_keys"
  }
}
