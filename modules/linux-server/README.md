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

## Fragen und Antworten

### Was nimmt man in Produktion statt `privileged`?

In Produktion braucht man `privileged` gar nicht, weil dort kein systemd im Container läuft. Es gibt drei Wege:

1. **Echte Server oder VMs.** So ist es bei TLBG (OpenStack). Dort läuft systemd ganz normal, und Ansible konfiguriert die Maschine. Unser Container ist nur der Ersatz, damit man ohne VMs üben kann.
2. **Ein Prozess pro Container.** Für Anwendungen in Containern startet man nginx oder die App direkt als einziges Programm. Es gibt dann kein systemd, kein SSH und kein Ansible auf dem Container. Die Software steckt im Image (Dockerfile), Terraform oder ein Orchestrator startet es.
3. **Systemd im Container, wenn es wirklich sein muss.** Es gibt Laufzeiten, die das mit weniger Rechten können, zum Beispiel Podman oder Sysbox. Das ist hier nicht getestet. Ob es mit Docker ohne `privileged` geht, hängt von der cgroup-Version und den Rechten des Hosts ab.

Für die Schulung ist `privileged` vertretbar: Die Container laufen nur lokal, sind nur auf `127.0.0.1` erreichbar und verschwinden mit `terraform destroy` wieder.

### Was sind cgroups, und wozu sind sie da?

**cgroup** steht für "control group". Es ist eine Funktion des Linux-Kernels, die Prozesse zu Gruppen zusammenfasst. Für jede Gruppe kann der Kernel zwei Dinge:

- **messen**, wie viel CPU und Arbeitsspeicher die Gruppe verbraucht
- **begrenzen**, zum Beispiel "höchstens 512 MB"

Man sieht die Gruppen als Ordnerbaum unter `/sys/fs/cgroup`.

Zwei Programme nutzen das:

- **Docker** legt für jeden Container eine Gruppe an, damit sich Container Limits setzen lassen und sich nicht gegenseitig die Ressourcen wegnehmen.
- **systemd** legt für jeden Dienst eine Gruppe an. Ein Dienst wie nginx startet mehrere Prozesse. Über die Gruppe weiß systemd, welche dazugehören, und kann sie mit `systemctl stop nginx` alle zusammen beenden.

Deshalb braucht systemd im Container Zugriff auf den cgroup-Ordner. Ohne ihn könnte Ansible keine Dienste starten und stoppen. Auf einer VM ist das selbstverständlich, im Container muss man es erlauben.

### Was bedeuten die anderen Einstellungen für systemd?

| Einstellung | Einfach erklärt |
| --- | --- |
| `privileged` | Der Container bekommt fast alle Rechte des Rechners. Ohne das darf systemd im Container die Dinge nicht tun, die es auf einer VM täte. Im Labor akzeptabel, in Produktion zu offen (siehe oben). |
| `cgroupns_mode = "host"` | Ein **Namespace** gibt einem Container eine eigene, abgeschottete Sicht auf etwas, zum Beispiel auf die Prozessliste oder auf die cgroups. `host` heißt: Der Container sieht die cgroups des Rechners, nicht eine eigene Sicht. Das passt zum eingeblendeten cgroup-Ordner. |
| `volumes` mit `host_path` und `container_path` | Blendet einen Ordner des Rechners im Container ein ("bind mount"). Hier `/sys/fs/cgroup`, damit systemd die cgroups sieht. Für Daten, die ein Neustart überleben sollen, nimmt man dasselbe, aber das ist hier nicht der Zweck. |
| `tmpfs` für `/run` und `/run/lock` | Ein **tmpfs** ist ein Dateisystem im Arbeitsspeicher. Nach dem Stopp ist alles weg. `/run` ist der Ort für Laufzeitdaten wie PID-Dateien und Sockets. systemd erwartet, dass er beschreibbar ist und bei jedem Start leer beginnt. `/run/lock` ist für Sperrdateien. |

### Ich kenne mich mit Netzwerk nicht aus. Was sind IP, Subnetz, Port und `127.0.0.1`?

Vergleich mit Adressen in der Stadt:

| Begriff | Bild | Hier |
| --- | --- | --- |
| **IP-Adresse** | Hausnummer eines Geräts im Netz | `172.31.0.11` für `server1` |
| **Subnetz** | die Straße: ein Adressbereich, der zusammengehört | `172.31.0.0/24` |
| **Port** | die Wohnung im Haus: jeder Dienst auf einem Gerät hört auf eine eigene Nummer | `22` für SSH, `80` für HTTP |
| **`127.0.0.1`** | "dieser Rechner selbst" (localhost) | der eigene Rechner |

Zu `/24`: Die ersten drei Zahlen (`172.31.0`) sind fest, die letzte darf 0 bis 255 sein. Das sind 254 nutzbare Adressen. Je größer die Zahl nach dem Schrägstrich, desto kleiner der Bereich.

Ein **Docker-Netz** ist ein virtuelles Netzwerk nur zwischen Containern, vergleichbar mit einem Switch. Container im selben Netz erreichen sich unter ihren IPs. Container in anderen Netzen und der Rest der Welt sehen sie nicht.

### Warum veröffentlicht man Ports, und warum `127.0.0.1`?

Die Container stecken im virtuellen Netz. Der eigene Rechner kommt dort nicht ohne Weiteres hin. Mit `ports` leitet Docker einen Port des Rechners an einen Port im Container weiter:

```
ansible / ssh                  Docker                       Container
127.0.0.1:2211   --------->    leitet weiter   ------->     172.31.0.11:22  (SSH)
```

Zwei Punkte dazu:

- **Jeder Server braucht einen eigenen Rechner-Port** (`2211`, `2212`, ...), weil alle denselben Rechner teilen. Im Container ist es immer `22`.
- **`127.0.0.1`** heißt, nur dieser Rechner darf den Port benutzen. Mit `0.0.0.0` (alle Adressen) wäre der Server auch aus dem Netzwerk erreichbar. Für ein Übungs-SSH ist das unnötig und unsicher.

Die Datenbank im Miniprojekt veröffentlicht gar keinen Port. Sie ist nur für Container im selben Netz erreichbar, wie ein interner Server hinter einer Firewall.

### Warum feste IPs, wenn Ansible über Ports am Rechner verbindet?

In `umgebung/` stimmt das: Ansible verbindet über `127.0.0.1:2211` und braucht die IP nicht. Feste IPs braucht man, wenn Server sich untereinander erreichen sollen. Im Miniprojekt verbindet sich die App unter der festen IP mit der Datenbank. Ohne feste IP müsste man sie nach jedem Start neu herausfinden.

### Wozu `networks_advanced` und `dynamic "ports"`?

- **`networks_advanced`** hängt den Container in ein bestimmtes Netz und gibt ihm dort die feste IP. "Advanced" heißt nur, dass man Optionen wie die Adresse mitgeben kann.
- **`dynamic "ports"`** erzeugt den Block `ports` so oft, wie die Liste `weitere_ports` Einträge hat. Ohne Einträge entsteht keiner. Ein fester Block ginge nicht, weil der App-Server Port 8080 freigibt und die Datenbank keinen.

### Wozu `upload` und der SSH-Schlüssel?

`upload` legt beim Start eine Datei in den Container. Hier ist es der öffentliche Schlüssel als `/root/.ssh/authorized_keys`. Das ist die Liste der Schlüssel, mit denen sich `root` anmelden darf. Wer den passenden privaten Schlüssel hat (Ansible, Datei `.ssh/id_lab`), kommt ohne Passwort hinein.
