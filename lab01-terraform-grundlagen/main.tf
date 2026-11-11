# Lab 1: Terraform-Grundlagen (Uebung)
# Ziel: out/hallo.txt mit "Hallo Terraform! Servername: <zufaelliger Name>"
# Ergaenzt die Stellen mit TODO.

# TODO: terraform-Block mit required_version >= 1.6 und required_providers
#       random (hashicorp/random, ~> 3.6) und local (hashicorp/local, ~> 2.5)

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

#
# OPTIONAL / GUT ZU WISSEN
# - Weitere Bloecke: provider (mit alias fuer mehrere Konten/Regionen), data (vorhandenes lesen),
#   variable, locals, output, module, moved, import, check.
# - terraform-Block: backend "s3" oder "http" legt den State auf einen gemeinsamen Ort, mit Locking.
# - Weitere Provider ohne Cloud: tls (Schluessel), time (time_static, time_rotating), http (URL lesen),
#   archive (zip), null bzw. terraform_data (Ausloeser und Klebstoff), external (Skript, nur im Notfall).
# - Befehle: plan -out=plan.tfplan, show, state list, state show, apply -replace=<Adresse>, fmt, validate.
# - Drift zeigen: out/hallo.txt von Hand aendern, dann terraform plan.
# - .terraform.lock.hcl pinnt die Provider-Versionen (gehoert normalerweise ins Git).
# - depends_on nur bei versteckten Abhaengigkeiten. Hier reicht die implizite Abhaengigkeit.
# - Provider-Versionen: "~> 3.6" erlaubt 3.x ab 3.6, nicht 4.0.
