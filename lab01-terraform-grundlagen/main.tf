# Lab 1: Terraform-Grundlagen (Uebung)
# Ziel: out/hallo.txt mit "Hallo Terraform! Servername: <zufaelliger Name>"
#
# TODO 1: terraform-Block mit required_version >= 1.6 und den Providern random (~> 3.6) und local (~> 2.5)
# TODO 2: Resource random_pet "server_name" mit zwei Woertern
# TODO 3: Resource local_file "hallo", Datei unter ${path.module}/out/hallo.txt,
#         Inhalt nutzt den Namen aus random_pet (implizite Abhaengigkeit)
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
