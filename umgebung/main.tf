# Uebungsumgebung fuer die Ansible-Labs an Tag 1:
# zwei Linux-Server (Container mit systemd und SSH).

# WARUM EIN SCHLUESSEL: Ansible meldet sich per SSH an den Servern an, und zwar ohne Passwort, mit einem
# Schluesselpaar. Terraform erzeugt es hier selbst, damit niemand von Hand ssh-keygen ausfuehren muss.
#   privater Teil: bleibt auf dem eigenen Rechner (Datei unten), damit meldet sich Ansible an.
#   oeffentlicher Teil: kommt in jeden Server (Modul, Eingabe public_key) und erlaubt genau diesem Schluessel den Login.
# ED25519 ist ein modernes, kurzes Verfahren. Achtung: der private Schluessel steht auch im State.
resource "tls_private_key" "lab" {
  algorithm = "ED25519"
}

# Schreibt den privaten Schluessel als Datei (.ssh/id_lab, nicht im Git). "sensitive" blendet den Inhalt in plan
# und apply aus. file_permission 0600 (nur der Besitzer darf lesen) ist Pflicht: ssh verweigert Schluessel,
# die andere lesen duerfen.
resource "local_sensitive_file" "private_key" {
  filename        = "${path.module}/.ssh/id_lab"
  content         = tls_private_key.lab.private_key_openssh
  file_permission = "0600"
}

# Das Server-Image: Ubuntu mit systemd und SSH, gebaut aus docker/Dockerfile. Es ist ein "leerer" Server,
# nginx und Co. installiert erst Ansible.
# keep_locally: terraform destroy loescht das Image nicht, denn der Bau dauert Minuten.
# triggers: aendert sich das Dockerfile (Pruefsumme), wird das Image neu gebaut.
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

# WARUM EIN EIGENES NETZ MIT SUBNET: Alle Server haengen in einem eigenen Docker-Netz statt im Standardnetz.
#   Feste Adressen: ipam_config legt den Adressbereich fest (172.31.0.0/24), jeder Server bekommt eine bekannte IP.
#   Abgrenzung: das Netz ist vom Rest der Docker-Container getrennt, wie ein eigenes Projektnetz in OpenStack.
# In diesem Lab verbindet sich Ansible ueber die Ports am eigenen Rechner (127.0.0.1:2211). Die festen IPs
# brauchen wir vor allem im Miniprojekt, wo die App die Datenbank unter ihrer IP erreicht.
resource "docker_network" "lab" {
  name = "tlbg-umgebung"

  ipam_config {
    subnet = "172.31.0.0/24"
  }
}

# Ein Server pro Eintrag in var.server (for_each). each.key ist der Name (server1), each.value die Eigenschaften.
# Was das Modul daraus baut, steht in modules/linux-server/main.tf. Hier werden nur die Teile
# zusammengesteckt: Image, Netz, IP, SSH-Port und der oeffentliche Schluessel.
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

# Die Bruecke von Terraform zu Ansible: Terraform schreibt die Inventory-Datei, die Ansible im naechsten Lab liest.
# Die Vorlage bekommt die Server (Ports) und den Pfad zum privaten Schluessel. abspath macht den Pfad absolut,
# damit Ansible ihn auch aus einem anderen Ordner findet.
resource "local_file" "inventory" {
  filename = "${path.module}/../lab03-ansible-grundlagen/inventory.ini"
  content = templatefile("${path.module}/templates/inventory.tftpl", {
    server   = module.server
    key_path = abspath(local_sensitive_file.private_key.filename)
  })
}
