# TODO: Schreibt die drei Variablen dieses Projekts. Sie werden in main.tf und outputs.tf benutzt
#       (var.umgebung, var.netz, var.app_port). Jede braucht einen type und einen default:
#
#   umgebung   Text (string), Standard "schulung". Wird zum Praefix der Namen (tlbg-schulung-...).
#   netz       Text (string), Standard "172.30.0.0/24". Subnetz fuer App und DB (entspricht einem
#              Projektnetz in OpenStack). Mit description erklaeren, wofuer es dient.
#   app_port   Zahl (number), Standard 8080. Port der Anwendung, auf dem eigenen Rechner unter
#              127.0.0.1 erreichbar. Auch hier eine description.
#
# Muster: lab02-terraform-variablen/variables.tf und umgebung/variables.tf (Aufbau eines variable-Blocks)
# Hilfe:  Die Datei variables.tf im Ordner umgebung zeigt auch, wie description aussieht.
