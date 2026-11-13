# Miniprojekt: Anwendungsserver mit entferntem DB-Server.
# Terraform baut Netz und Server, Ansible konfiguriert sie.

# locals: die Beschreibung der Umgebung an einer Stelle. Server, Netz und Inventory werden daraus abgeleitet.
# cidrhost(netz, n) liefert die n-te Adresse im Subnetz, hier z. B. 172.30.0.11.
# ports: welche Ports ein Server auf dem eigenen Rechner veroeffentlicht (intern im Container, extern am Rechner).
locals {
  prefix = "tlbg-${var.umgebung}"

  server = {
    app1 = {
      rolle    = "app"
      ssh_port = 2201
      ip       = cidrhost(var.netz, 11)
      ports    = [{ intern = var.app_port, extern = var.app_port }]
    }
    db1 = {
      rolle    = "db"
      ssh_port = 2202
      ip       = cidrhost(var.netz, 21)
      ports    = [] # DB-Port wird NICHT veroeffentlicht, nur im Netz erreichbar
    }
  }

  rollen = sort(distinct([for s in local.server : s.rolle]))
}

# Ein SSH-Schluesselpaar, das Terraform erzeugt. Der oeffentliche Teil kommt in die Server, der private Teil
# wird als Datei abgelegt, damit Ansible sich anmelden kann. Achtung: der private Schluessel steht im State.
resource "tls_private_key" "lab" {
  algorithm = "ED25519"
}

resource "local_sensitive_file" "private_key" {
  filename        = "${path.module}/.ssh/id_lab"
  content         = tls_private_key.lab.private_key_openssh
  file_permission = "0600"
}

# Baut das Server-Image (systemd und sshd, ohne Anwendung) aus docker/Dockerfile.
# triggers: das Image wird neu gebaut, wenn sich das Dockerfile aendert.
resource "docker_image" "linux" {
  name         = "tlbg-linux:lab"
  keep_locally = true

  build {
    context = "${path.module}/../../docker"
  }

  triggers = {
    dockerfile = filesha1("${path.module}/../../docker/Dockerfile")
  }
}

# Das Projektnetz. ipam_config legt das Subnetz fest, damit die Server feste Adressen bekommen.
# Die Adresse der Datenbank braucht Ansible spaeter, um die App mit ihr zu verbinden.
resource "docker_network" "projekt" {
  name = "${local.prefix}-netz"

  ipam_config {
    subnet = var.netz
  }
}

# Ein Server pro Eintrag in local.server (for_each). each.key ist der Name (app1, db1), each.value
# die Eigenschaften. Was das Modul erwartet, steht in modules/linux-server/README.md (Abschnitt "Eingaben").
module "server" {
  source   = "../../modules/linux-server"
  for_each = local.server

  name          = "${local.prefix}-${each.key}"
  image_id      = docker_image.linux.image_id
  network_name  = docker_network.projekt.name
  ipv4_address  = each.value.ip
  ssh_port      = each.value.ssh_port
  public_key    = tls_private_key.lab.public_key_openssh
  weitere_ports = each.value.ports
}

# Schreibt ansible/inventory.ini aus der Vorlage. Hier gibt Terraform an Ansible weiter, was es ueber die
# Infrastruktur weiss: Server, Ports, Schluessel und die Adresse der Datenbank.
resource "local_file" "inventory" {
  filename = "${path.module}/../ansible/inventory.ini"
  content = templatefile("${path.module}/templates/inventory.tftpl", {
    server   = local.server
    rollen   = local.rollen
    knoten   = module.server
    key_path = abspath(local_sensitive_file.private_key.filename)
    db_host  = local.server["db1"].ip
    netz     = var.netz
    app_port = var.app_port
  })
}
