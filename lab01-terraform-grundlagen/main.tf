# Lab 1: Terraform-Grundlagen
# Ziel: out/hallo.txt mit "Hallo Terraform! Servername: <zufaelliger Name>"
# Ergaenzt die Stellen mit TODO.

# BLOCK terraform { }
# Was: Einstellungen fuer Terraform selbst, kein Teil der Infrastruktur.
# Wozu: legt fest, welche Terraform-Version laufen darf (required_version) und welche Provider
#       mit welcher Version geladen werden (required_providers). Ohne diese Angaben kann ein Update
#       still das Verhalten aendern.
# Ein Provider ist ein Plugin, das Terraform eine Art von Ressourcen beibringt (hier random und local).
# TODO: terraform-Block mit required_version >= 1.6 und required_providers
#       random (hashicorp/random, ~> 3.6) und local (hashicorp/local, ~> 2.5)

# BLOCK resource "TYP" "NAME" { }
# Was: beschreibt ein Objekt, das Terraform anlegen und verwalten soll. TYP sagt was (Provider und Art),
#      NAME ist der Name im Code. Zusammen ergeben sie die Adresse, z. B. random_pet.server_name.
# Wozu: das ist der Kern von Terraform. Man beschreibt den Zielzustand, Terraform vergleicht ihn mit
#       dem State und berechnet, was angelegt, geaendert oder geloescht werden muss (plan, apply).
# Verweise wie random_pet.server_name.id legen die Reihenfolge fest (implizite Abhaengigkeit).
# Erzeugt einen zufaelligen Namen, z. B. "brave-otter"
resource "random_pet" "server_name" {
  # TODO: length auf 2 setzen (zwei Woerter)
}

# Schreibt eine Datei. Der Inhalt haengt von random_pet ab (implizite Abhaengigkeit).
resource "local_file" "hallo" {
  # TODO: filename = Datei hallo.txt im Ordner out/ des Moduls (path.module)
  # TODO: content = "Hallo Terraform! Servername: " plus den Namen aus random_pet.server_name
  #       (Attribut id), am Ende ein Zeilenumbruch \n
}

# Pruefen: terraform init, plan, apply. Zweiter plan muss leer sein. Dann destroy.
