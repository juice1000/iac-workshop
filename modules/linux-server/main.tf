# Ein Linux-"Server" als Docker-Container mit systemd und SSH.
# Das Image (docker/Dockerfile) bringt die Software mit. Dieses Modul macht daraus eine laufende Instanz:
# Container starten, ins Netz haengen, Ports freigeben, Schluessel ablegen.
# Einsteiger-Erklaerung zu cgroups, tmpfs, Ports, IPs und Subnetzen: README.md in diesem Ordner, "Fragen und Antworten".

terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

# Der laufende Server. hostname ist der Name, den der Server von sich selbst sieht.
resource "docker_container" "server" {
  name     = var.name
  hostname = var.name
  image    = var.image_id

  # systemd im Container braucht diese Einstellungen. Ansible startet Dienste mit systemd, und systemd
  # erwartet eine Umgebung wie auf einer VM. Das ist ein Kompromiss fuers Labor, in Produktion
  # waere privileged zu offen.
  #   privileged       volle Rechte, damit systemd seine Prozesse verwalten darf
  #   cgroupns_mode    der Container sieht die cgroups des Rechners (Kernel-Funktion, die Prozesse zu Gruppen zusammenfasst).
  #                    systemd legt pro Dienst eine Gruppe an, so kann es alle Prozesse eines Dienstes zusammen beenden
  #   tmpfs            /run und /run/lock liegen im Arbeitsspeicher, dort legt systemd Laufzeitdaten ab
  #   volumes          bindet /sys/fs/cgroup vom Host ein, passend zum cgroup-Modus
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

  # networks_advanced: haengt den Container in das Netz aus der Umgebung und gibt ihm dort eine feste IP.
  # "advanced" heisst nur: man kann Optionen wie die Adresse mitgeben.
  networks_advanced {
    name         = var.network_name
    ipv4_address = var.ipv4_address
  }

  # ports: veroeffentlicht einen Port des Containers auf dem eigenen Rechner (Container 22 -> Rechner ssh_port).
  # ip 127.0.0.1 heisst: nur von diesem Rechner aus erreichbar, nicht aus dem Netzwerk. Jeder Server braucht
  # einen eigenen ssh_port, denn alle teilen sich denselben Rechner. Ansible verbindet sich darueber.
  ports {
    internal = 22
    external = var.ssh_port
    ip       = "127.0.0.1"
  }

  # dynamic: erzeugt den ports-Block so oft, wie die Liste weitere_ports Eintraege hat. Ohne Eintrag
  # entsteht keiner (Standard []). Wozu: der App-Server im Miniprojekt gibt zusaetzlich Port 8080 frei,
  # die Datenbank keinen. Ein fester Block ginge nicht, weil die Anzahl vom Aufruf abhaengt.
  dynamic "ports" {
    for_each = var.weitere_ports
    content {
      internal = ports.value.intern
      external = ports.value.extern
      ip       = "127.0.0.1"
    }
  }

  # upload: legt beim Start eine Datei in den Container. Hier der oeffentliche Schluessel als authorized_keys
  # von root. Damit darf sich der Besitzer des privaten Schluessels (Ansible) ohne Passwort anmelden.
  upload {
    content = var.public_key
    file    = "/root/.ssh/authorized_keys"
  }
}
