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
    # TODO: Server db1 mit rolle "db", ssh_port 2202, ip als Host 21 im Netz (cidrhost wie bei app1)
    #       und ports als leere Liste (der DB-Port wird nicht veroeffentlicht, nur im Netz erreichbar)
    #       Muster: der Eintrag app1 darueber. Maps kennt ihr aus Lab 2 (variable "server").
  }

  rollen = sort(distinct([for s in local.server : s.rolle]))
}

# Ein SSH-Schluesselpaar, das Terraform erzeugt. Der oeffentliche Teil kommt in die Server, der private Teil
# wird als Datei abgelegt, damit Ansible sich anmelden kann. Achtung: der private Schluessel steht im State.
resource "tls_private_key" "lab" {
  algorithm = "ED25519"
}

# TODO: Schreibt die Ressource local_sensitive_file.private_key. Sie legt den privaten Schluessel als Datei
#       ab, damit Ansible sich anmelden kann. "sensitive" blendet den Inhalt in plan und apply aus.
#   filename         ${path.module}/.ssh/id_lab  (Ordner .ssh neben dieser Datei, nicht im Git)
#   content          der private Schluessel im OpenSSH-Format: private_key_openssh von tls_private_key.lab
#   file_permission  "0600" (nur der Besitzer darf lesen). Pflicht: ssh verweigert Schluessel, die andere lesen duerfen.
# Muster: umgebung/main.tf, Ressource local_sensitive_file.private_key
# Hilfe:  Der Name ist wichtig: der Rest der Datei und outputs.tf verweisen auf local_sensitive_file.private_key.

# Baut das Server-Image (systemd und sshd, ohne Anwendung) aus docker/Dockerfile.
# triggers: das Image wird neu gebaut, wenn sich das Dockerfile aendert.
resource "docker_image" "linux" {
  name         = "tlbg-linux:lab"
  keep_locally = true

  build {
    context = "${path.module}/../../docker"
  }

  triggers = {
    dockerfile = filesha1("TODO") # TODO: Pfad zum Dockerfile. context oben zeigt auf den Ordner docker, die Datei darin heisst Dockerfile. Muster: umgebung/main.tf
  }
}

# Das Projektnetz. ipam_config legt das Subnetz fest, damit die Server feste Adressen bekommen.
# Die Adresse der Datenbank braucht Ansible spaeter, um die App mit ihr zu verbinden.
resource "docker_network" "projekt" {
  name = "${local.prefix}-netz"

  # TODO: ipam_config-Block mit subnet = var.netz
  #       Muster: umgebung/main.tf, Ressource docker_network.lab
}

# Ein Server pro Eintrag in local.server (for_each). each.key ist der Name (app1, db1), each.value
# die Eigenschaften. Was das Modul erwartet, steht in modules/linux-server/README.md (Abschnitt "Eingaben").
module "server" {
  source   = "../../modules/linux-server"
  for_each = local.server

  # TODO: die Eingaben des Moduls (Tabelle in modules/linux-server/README.md):
  #   name           Praefix, Bindestrich und Name des Servers: "${local.prefix}-${each.key}"
  #   image_id       image_id von docker_image.linux
  #   network_name   name von docker_network.projekt
  #   ipv4_address   ip des Servers (each.value.ip)
  #   ssh_port       ssh_port des Servers
  #   public_key     public_key_openssh von tls_private_key.lab
  #   weitere_ports  ports des Servers
  # Muster: umgebung/main.tf, module "server" (dieselben Eingaben, dort ohne weitere_ports)
}

# Schreibt ansible/inventory.ini aus der Vorlage. Hier gibt Terraform an Ansible weiter, was es ueber die
# Infrastruktur weiss: Server, Ports, Schluessel und die Adresse der Datenbank.
resource "local_file" "inventory" {
  filename = "${path.module}/../ansible/inventory.ini"
  content = templatefile("${path.module}/templates/inventory.tftpl", {
    # TODO: Ersetzt jedes null durch den richtigen Wert (rechte Seite). Die Namen links benutzt die Vorlage
    #       templates/inventory.tftpl. Muster: umgebung/main.tf, Ressource local_file.inventory
    server   = null          # die Server-Map aus den locals
    rollen   = null          # die sortierte Liste der Rollen aus den locals
    knoten   = null          # die Ausgabe des Moduls "server" (alle Instanzen, in der Vorlage knoten[name].name)
    key_path = abspath(null) # der Dateiname von local_sensitive_file.private_key (abspath macht ihn absolut)
    db_host  = null          # die IP-Adresse von db1 aus den locals
    netz     = null          # die Variable netz
    app_port = null          # die Variable app_port
  })
}
