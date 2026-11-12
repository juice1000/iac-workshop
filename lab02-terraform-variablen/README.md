# Lab 2: Variablen, Locals, for_each, Outputs, Vorlagen

> Branch `practice-solved`: Die Lücken (`TODO`) sind hier schon ausgefüllt, inklusive der optionalen Beispiele. Zum Vergleichen mit der eigenen Lösung.

## Ziel

Lab 1 hatte feste Werte im Code. Hier trennt ihr Code und Werte: dieselbe Konfiguration erzeugt je nach Eingabe andere Ergebnisse. Aus einer Datenstruktur (der Map `server`) entstehen mehrere Dateien und ein Ansible-Inventory.

Am Ende könnt ihr erklären:

- `variable`, `locals`, `output` und wofür jeder Block da ist
- `for_each` über eine Map und was `each.key` und `each.value` sind
- `templatefile`: eine Textvorlage mit Werten füllen
- dass geheime Werte (`sensitive`) trotzdem im State stehen

## Aufbau

| Datei | Inhalt |
| --- | --- |
| `variables.tf` | Eingaben: `umgebung` (mit `validation`) und `server` (Map von Objekten) |
| `main.tf` | `locals`, `random_password`, eine Datei pro Server, das Inventory |
| `outputs.tf` | Ausgaben, eine davon `sensitive` |
| `templates/inventory.tftpl` | Vorlage für das Ansible-Inventory |
| `terraform.tfvars.example` | Beispiel für eigene Werte |

## Aufgabe

Ergänzt die Stellen mit `TODO` in den drei `.tf`-Dateien. Über jedem Block steht, was er tut und wozu.

## Ablauf

```bash
cd lab02-terraform-variablen
terraform init
terraform plan
terraform apply
ls out/
cat out/inventory.ini
terraform output
terraform output -raw db_passwort
```

## Was entsteht

Mit den Standardwerten (`umgebung = "schulung"`, Server `app1` und `db1`) liegen drei Dateien in `out/`.

`tlbg-schulung-app1.txt`:

```
Server app1, Rolle app, SSH-Port 2201
```

`tlbg-schulung-db1.txt`:

```
Server db1, Rolle db, SSH-Port 2202
```

`inventory.ini`:

```ini
[app]
app1 ansible_host=127.0.0.1 ansible_port=2201

[db]
db1 ansible_host=127.0.0.1 ansible_port=2202
```

So entstehen sie:

- **Info-Dateien:** `for_each` erzeugt pro Eintrag in `var.server` eine Datei. Der Name setzt sich aus `local.prefix` (`tlbg-schulung`) und dem Schlüssel (`app1`) zusammen, der Inhalt kommt aus `each.value`.
- **Inventory:** Die Vorlage läuft über die sortierte Liste der Rollen (`local.rollen`). Pro Rolle schreibt sie einen Abschnitt `[rolle]` und darunter die Server dieser Rolle. `%{ for ... ~}` und `%{ if ... ~}` sind Schleife und Bedingung. Das `~` entfernt den Zeilenumbruch dahinter, damit keine Leerzeilen entstehen.

## Fragen und Antworten

### Was bringen diese Dateien für die Infrastruktur?

In Lab 2 legt ihr keine echte Infrastruktur an. Die Dateien beschreiben nur Server, die es hier noch nicht gibt.

- Die Info-Dateien sind Dokumentation. Man kann sie lesen, mehr nicht.
- Das Inventory ist das nützliche Stück. Ansible liest es mit `-i` und weiß dann, welche Hosts es gibt und wie es sich verbindet: `ansible -i out/inventory.ini app -m ping`. Das klappt aber nur, wenn auf `127.0.0.1` mit den Ports 2201 und 2202 wirklich etwas lauscht.
- Das tut es, wenn die Container aus `umgebung/` laufen. Dort erzeugt Terraform das Inventory für Lab 3 mit demselben Prinzip.

Die Rollenverteilung: Terraform legt an, Ansible konfiguriert. Das Inventory ist die Übergabe zwischen beiden. Lab 2 ist der Baukasten, `umgebung/` und das Miniprojekt wenden ihn auf echte Container an.

### Wie überschreibe ich Standardwerte, zum Beispiel `umgebung` oder `rollen`?

`rollen` lässt sich nicht überschreiben. Es ist ein `local` und wird aus `var.server` berechnet (die `rolle`-Werte der Server). Wollt ihr andere Rollen, ändert ihr `server`. Nur `umgebung` und `server` sind Variablen.

**Auf der Kommandozeile**

```bash
terraform plan -var 'umgebung=test'
terraform plan -var 'server={ web1 = { rolle = "web", port = 2203 } }'
```

`server` ersetzt den Default komplett. Schreibt alle Server hin, die ihr haben wollt, nicht nur den neuen.

**Als Umgebungsvariable**

```bash
export TF_VAR_umgebung=test
terraform plan
```

**In einer Datei** (am bequemsten für `server`): siehe unten.

### Wie setze ich `terraform.tfvars`?

Legt die Datei im Lab-Ordner an, es ist eine normale Textdatei (`terraform.tfvars.example` ist die Vorlage):

```hcl
umgebung = "test"

server = {
  web1 = { rolle = "web", port = 2203 }
  db1  = { rolle = "db", port = 2202 }
}
```

Strings stehen in Anführungszeichen, Zahlen und `true`/`false` ohne. Eine Map schreibt ihr mit `{ ... }` wie im `default`. Dann reicht:

```bash
terraform plan
```

Terraform lädt `terraform.tfvars` und `*.auto.tfvars` automatisch. Eine Datei mit anderem Namen laden nur wir mit `-var-file`:

```bash
terraform plan -var-file=prod.tfvars
```

Wichtig:

- In die Datei gehören nur Variablen aus `variables.tf`. Eine unbekannte Variable führt zu einer Warnung, `rollen` ist keine.
- Die Werte müssen zu `type` und `validation` passen. `umgebung = "dev"` wird abgelehnt.
- Bei echten Projekten gehören `.tfvars` mit Geheimnissen in `.gitignore`.

### Überschreibt `variables.tf` die `terraform.tfvars`?

Nein, umgekehrt. Der `default` in `variables.tf` hat die niedrigste Priorität. Steht dieselbe Variable in `terraform.tfvars`, gilt der Wert aus der Datei.

Reihenfolge, spätere Quellen gewinnen:

1. `default` in `variables.tf`
2. Umgebungsvariable `TF_VAR_name`
3. `terraform.tfvars`
4. `*.auto.tfvars` (alphabetisch)
5. `-var-file` und `-var` auf der Kommandozeile, in der Reihenfolge, in der sie dastehen

Beispiel `umgebung`:

| Quelle | Wert | Gilt? |
| --- | --- | --- |
| `default` in `variables.tf` | `"schulung"` | nur, wenn nichts anderes gesetzt ist |
| `terraform.tfvars` | `"test"` | ja, ersetzt den Default |
| `-var 'umgebung=prod'` | `"prod"` | ja, ersetzt auch die Datei |

Was die Variable selbst festlegt, also `type`, `validation` und `description`, steht nur in `variables.tf`. Alle Werte müssen dazu passen.

Stolperstein: `umgebung` steckt im Dateinamen (`tlbg-<umgebung>-<server>.txt`). Ein neuer Wert löscht die alten Dateien und legt neue an, weil sich die Adresse ändert.

### Welche Dateinamen haben in Terraform eine besondere Bedeutung?

Es gibt keine "geschützten" Namen, die man nicht verwenden dürfte. Einige Namen haben aber eine feste Bedeutung.

Terraform lädt automatisch:

| Name | Bedeutung |
| --- | --- |
| `*.tf` und `*.tf.json` | Jede Datei im Ordner gehört zur Konfiguration, alle werden zusammen gelesen. |
| `terraform.tfvars` (auch `.json`) | Variablenwerte |
| `*.auto.tfvars` (auch `.json`) | Variablenwerte, alphabetisch geladen |
| `override.tf`, `*_override.tf` | Überschreiben gleichnamige Blöcke. Selten sinnvoll, verwirrt leicht. |

Terraform legt selbst an und verwaltet:

| Name | Bedeutung |
| --- | --- |
| `terraform.tfstate`, `terraform.tfstate.backup` | Der State (lokales Backend). Nicht von Hand ändern. |
| `.terraform.lock.hcl` | Fixiert die Provider-Versionen. Gehört ins Git. |
| `.terraform/` | Heruntergeladene Provider und Module. Gehört nicht ins Git. |
| `crash.log` | Wird bei einem Absturz geschrieben. |

Nur Konvention: `main.tf`, `variables.tf`, `outputs.tf` und `providers.tf` haben keine technische Sonderrolle. Terraform ist es egal, in welcher Datei ein Block steht. Die Namen helfen beim Lesen.

### Kann ich die Logik aus `inventory.tftpl` auch direkt in `main.tf` schreiben?

Ja, auf zwei Arten. Beide Varianten habe ich getestet: Sie erzeugen byte-genau dieselbe `inventory.ini` wie die Vorlage.

**1. Heredoc mit denselben Direktiven.** `%{ for }` und `%{ if }` funktionieren in jedem String, nicht nur in Vorlagen. Dann braucht ihr `templatefile()` nicht, und die Werte heißen direkt `var.server` und `local.rollen`:

```hcl
resource "local_file" "inventory" {
  filename = "${path.module}/out/inventory.ini"
  content  = <<EOT
%{for rolle in local.rollen~}
[${rolle}]
%{for name, s in var.server~}
%{if s.rolle == rolle~}
${name} ansible_host=127.0.0.1 ansible_port=${s.port}
%{endif~}
%{endfor~}

%{endfor~}
EOT
}
```

Achtung: Schreibt `<<EOT` ohne Bindestrich und setzt den Text an den Zeilenanfang. Mit `<<-EOT` und eingerücktem Text bleiben Einrückungen von den Direktiven übrig, und die Datei sieht falsch aus. `terraform fmt` schreibt `%{ for ... ~}` übrigens zu `%{for ...~}` um. Beides ist gleichwertig.

**2. Mit `for`-Ausdrücken und `join()`** statt Template-Direktiven:

```hcl
locals {
  inventory = join("\n\n", [
    for rolle in local.rollen : join("\n", concat(
      ["[${rolle}]"],
      [for name, s in var.server :
        "${name} ansible_host=127.0.0.1 ansible_port=${s.port}"
      if s.rolle == rolle]
    ))
  ])
}

resource "local_file" "inventory" {
  filename = "${path.module}/out/inventory.ini"
  content  = "${local.inventory}\n\n"
}
```

Das ist kürzer, aber schwerer zu lesen. Die zwei `\n` am Ende ergeben die Leerzeile, die die Vorlage am Dateiende erzeugt.

**Warum `templatefile` trotzdem üblich ist:**

- Die Vorlage ist eine eigene Datei, und ihr Text sieht aus wie das Ergebnis. Bei längeren Dateien (Konfigurationen, Skripte) ist das viel übersichtlicher.
- Der Terraform-Code bleibt kurz.
- Mit anderen Werten erzeugt dieselbe Vorlage ein anderes Ergebnis. Ein Heredoc ist fest an die Variablen im Modul gebunden.

Faustregel: Für ein paar Zeilen ist ein Heredoc in Ordnung, ab etwa zehn Zeilen lohnt sich die eigene Datei. Soll ein wörtliches `${` im Text stehen, schreibt ihr `$${`, in beiden Fällen.

## Dinge zum Ausprobieren

- Kopiert `terraform.tfvars.example` nach `terraform.tfvars` und führt `plan` aus. Ein dritter Server kommt dazu, alle Namen tragen `test`.
- `terraform plan -var 'umgebung=dev'` zeigt die `validation` in Aktion.
- `terraform output db_passwort` zeigt `<sensitive>`, `terraform output -raw db_passwort` den Klartext. Im State steht er so oder so offen: `grep result terraform.tfstate`.

## Aufräumen

```bash
terraform destroy
```
