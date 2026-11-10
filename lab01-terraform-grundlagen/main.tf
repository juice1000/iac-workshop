# Lab 1: Terraform-Grundlagen (Uebung)
# Ziel: out/hallo.txt mit "Hallo Terraform! Servername: <zufaelliger Name>"
#
# TODO 1: terraform-Block mit required_version >= 1.6 und den Providern random (~> 3.6) und local (~> 2.5)
# TODO 2: Resource random_pet "server_name" mit zwei Woertern
# TODO 3: Resource local_file "hallo", Datei unter ${path.module}/out/hallo.txt,
#         Inhalt nutzt den Namen aus random_pet (implizite Abhaengigkeit)
# Pruefen: terraform init, plan, apply. Zweiter plan muss leer sein. Dann destroy.
