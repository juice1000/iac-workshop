# Modul: linux-server

Ein Linux-"Server" als Docker-Container mit systemd und SSH. `umgebung/` und das Miniprojekt rufen das Modul pro Server mit `for_each` auf.

## Dockerfile und Modul: wer macht was?

Das Dockerfile (`docker/Dockerfile`) beschreibt das **Image**, die Vorlage. Das Modul beschreibt eine **laufende Instanz** davon. Das eine ersetzt das andere nicht.

| | Dockerfile (Image) | Modul (Container) |
| --- | --- | --- |
| Frage | Was ist installiert? | Wie läuft dieser eine Server? |
| Inhalt | Ubuntu, systemd, SSH-Dienst, Python, sudo, `CMD ["/sbin/init"]`, `STOPSIGNAL` | Name, IP, Netz, Ports, Rechte für systemd, SSH-Schlüssel |
| Wann | beim Bauen (einmal) | beim Starten (pro Server) |

Dieselbe Trennung gibt es ohne Terraform: Das Dockerfile entspricht `docker build`, das Modul entspricht `docker run` mit allen Optionen.

## Wozu ein Modul

`umgebung/` und das Miniprojekt brauchen mehrere Server mit gleichem Aufbau, aber verschiedenen Namen, IPs und Ports. Das Modul beschreibt "ein Server" einmal, `for_each` ruft es pro Eintrag auf. Das Image baut Terraform nur einmal (`docker_image.linux`), alle Container nutzen es.

## Vergleich mit docker-compose

Wer docker-compose kennt: Das Modul entspricht dem Dienst in der Compose-Datei, ungefähr so:

```yaml
services:
  server1:
    image: tlbg-linux:lab            # docker_image aus dem Aufrufer
    container_name: server1          # name
    hostname: server1
    privileged: true
    cgroup: host                     # cgroupns_mode
    tmpfs: [/run, /run/lock]
    volumes:
      - /sys/fs/cgroup:/sys/fs/cgroup
    ports:
      - "127.0.0.1:2211:22"          # ssh_port, nur lokal erreichbar
    networks:
      lab:
        ipv4_address: 172.31.0.11    # ipv4_address
```

Der Vorteil von Terraform hier: Schlüssel, Image, Netz, Container und das Ansible-Inventory entstehen in einem Lauf und hängen voneinander ab. Das Compose-Beispiel ist zum Verstehen gedacht und nicht getestet.

## Eingaben

| Variable | Bedeutung |
| --- | --- |
| `name` | Container- und Hostname |
| `image_id` | ID des Images (`docker_image` im Aufrufer) |
| `network_name` | Docker-Netz, in dem der Server hängt |
| `ipv4_address` | Feste IP im Netz |
| `ssh_port` | Port auf `127.0.0.1` des Rechners, der auf SSH im Container zeigt |
| `public_key` | Öffentlicher Schlüssel für `root` |
| `weitere_ports` | Optional: zusätzliche Ports (`intern` zu `extern`), Standard leer |

Hinweis zu `weitere_ports`: Das Miniprojekt nutzt die Variable, damit die Anwendung auf `127.0.0.1:8080` erreichbar ist. `umgebung/` gibt sie derzeit nicht weiter. Ein Webserver aus Lab 3 ist deshalb nicht im Browser erreichbar, sondern wird per Ansible (`uri`) geprüft.

## Ausgabe

`name`, `ssh_port` und `ipv4_address`. Die Aufrufer brauchen sie für das Ansible-Inventory.
