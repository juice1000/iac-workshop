# Labs

Every lab folder, `umgebung` and `miniprojekt` has a German `README.md` with goal, task, steps and things to try (the lab 2 README also answers the participant questions on overriding variables, tfvars, precedence and special file names). All lab code is German-facing. Providers are pinned with `~>` constraints: `hashicorp/random ~> 3.6`, `hashicorp/local ~> 2.5`, `hashicorp/tls ~> 4.0`, `kreuzwerker/docker ~> 3.0` (a v4 exists with possible breaking changes, deliberately not used).

## lab00-check

`check.sh` checks terraform, ansible, git, docker, python3, ssh, Terraform >= 1.6, the `community.postgresql` collection, the Docker daemon and access to the Terraform registry, GitHub, Ansible Galaxy, Docker Hub and the Ubuntu mirrors. Expected: `Ergebnis: 15 OK, 0 fehlend`. Exit code non-zero if anything fails.

## erste-schritte

Command line warm-ups that need no lab servers. Each folder has a `rundgang.sh` that prints each command, runs it and waits for Enter when run in a terminal (no pause without a TTY). Failed steps are counted, the walk continues, and the exit code is the number of failures, so CI can use it. Participants should type the commands themselves; the script is the fallback and a reference.

### erste-schritte/terraform

`main.tf` uses no provider at all: a variable, locals, one `terraform_data` resource (built in since Terraform 1.4) and two outputs. So `init` downloads nothing and works offline. Steps: `version`, `-help`, `plan -help`, `init`, `fmt`, `validate`, `plan`, `apply`, `output`, `output -raw`, `state list/show`, empty second plan, `plan -var name=Welt` (shows `~` in-place update, which lab 1 does not show), two `terraform console` expressions, `graph`, `ls -la`, `destroy`, then `ls -la` again: empty state plus `terraform.tfstate.backup` with the previous state.

Tested locally with OpenTofu 1.10 (HashiCorp downloads are blocked in the cloud sandbox), and in CI with Terraform. With OpenTofu, no `.terraform/` and no lock file appear because there are no providers; not verified for Terraform, so the docs do not claim it.

### erste-schritte/ansible

`ansible.cfg` plus a hand-written `inventory.ini` with only `localhost` (`ansible_connection=local`, `ansible_python_interpreter="{{ ansible_playbook_python }}"`), group `[lokal]`. It is excluded from the `**/inventory.ini` ignore rule in `.gitignore`. `hallo.yml` writes `out/rechner.txt` from facts and is idempotent.

Steps: `ansible --version`, `ansible-config dump --only-changed`, `ansible-inventory --graph`, ad-hoc `ping`, `setup` with filter, `debug`, `command` (always CHANGED), `file` twice (CHANGED then SUCCESS), `copy`, `copy --check --diff`, `ansible-doc -l ansible.builtin`, `ansible-doc -s ansible.builtin.copy`, `ansible-galaxy collection list community.postgresql`, `ansible-doc -l community.general | wc -l`, playbook twice (`changed=1`, then `changed=0`), playbook `--check --diff -e begruessung=Moin`.

Do not use plain `ansible-doc -l` without a collection name: with ansible 14.6 / ansible-core 2.21.6 it crashes (`'_AnsibleTaggedDict' object has no attribute 'strip'`). Filtered by collection it works. Reference numbers from that version: `ansible.builtin` has 71 modules, the full `ansible` package ships 94 collections, `community.general` alone has 581 modules.

## lab01-terraform-grundlagen

`main.tf` with `random_pet` and `local_file` (writes `out/hallo.txt`). Teaches init, fmt, validate, plan, apply, state list/show, second apply = no changes, `-/+` replacement when the content changes, drift when the file is deleted by hand, destroy.

## lab02-terraform-variablen

`variables.tf` (`umgebung` with validation schulung/test/prod, `server` map of objects), `main.tf` (locals, `random_password`, `local_file` with `for_each`, inventory via `templatefile`), `outputs.tf` (one sensitive), `templates/inventory.tftpl`, `terraform.tfvars.example` (adds app2, umgebung=test). Key lesson: sensitive values still sit in the state in plain text.

## umgebung

Terraform root (split like lab 2: `versions.tf`, `variables.tf`, `main.tf`, `outputs.tf`) that builds the image, network `tlbg-umgebung` and two servers `server1`, `server2` via `modules/linux-server`, plus the inventory for lab 3 (group `[web]`). Run at 14:55 on day 1, keep running for lab 5.

## lab03-ansible-grundlagen

`playbook.yml`: play 1 installs nginx, templates `index.html.j2` and `site.conf.j2` (port `web_port`, default 80), starts nginx, handler "Nginx neu laden". Play 2 verifies via `uri` and `assert` (skipped in check mode). `ansible.cfg` points to the generated `inventory.ini`.

Tested sequence: ping, ad-hoc `uptime` and `setup`, first run `changed=5`, second run `changed=0`, `--check --diff -e web_port=8081` shows the listen diff, apply with 8081 runs the handler, `uri` on 8081 returns 200.

## lab04-terraform-module

Lab 2 refactored: `modules/server-info` (inputs name, rolle, port, prefix, ausgabe_ordner; output `datei`), root calls it with `for_each`. Addresses look like `module.server_info["app1"].local_file.info`.

## lab05-ansible-rolle

Lab 3 as role `roles/webserver` (defaults `webserver_port`, `webserver_begruessung`, tasks, handler, templates). `site.yml` sets `webserver_begruessung: "Hallo aus der Rolle"`. Uses lab 3's inventory via `ansible.cfg`. Also used for: `-e webserver_port=8082` precedence demo, Vault demo (`ansible-vault create vault.yml`, then `ansible web -m debug -a "var=api_token" -e @vault.yml --ask-vault-pass`).

## miniprojekt

Scenario from the client: application server with a remote DB server.

### terraform/

`versions.tf`, `variables.tf` (`umgebung`, `netz` 172.30.0.0/24, `app_port` 8080), `main.tf` (locals with app1 and db1, IPs via `cidrhost`, key, image, network, module per server, inventory). On `start` the Terraform part has these gaps: `versions.tf`, `variables.tf` and `outputs.tf` are empty except for a TODO spec (names, types, defaults, values) that participants write themselves; in `main.tf` the `local_sensitive_file.private_key` resource, the Dockerfile path in `docker_image.linux` (`filesha1("TODO")`), the `db1` entry, `ipam_config` of the network, the inputs of the module call and the right-hand sides of the `templatefile` call (placeholders `null`, `abspath` stays). Outputs: `app_url`, `ssh`, `db_ip`. `templates/inventory.tftpl` stays given (groups `[app]`, `[db]`, vars `db_host`, `app_netz`, `app_port`).

### ansible/

- `site.yml`: play db (role postgresql), play app (role app), play smoke test (uri with retries, assert "DB OK")
- `group_vars/all.yml`: `db_name`, `db_user`, `db_password` (plain text on purpose, Vault is the stretch task)
- on `start` the participants also write both handlers (`roles/*/handlers/main.yml`, empty except a TODO spec) and in `site.yml` the first two plays and the smoke test tasks (`uri`, `assert`; pattern: lab 3 second play, lab 5 `site.yml`)
- final plays collect results into `ansible/out/` (git-ignored): `fetch` of `pg_hba.conf` and the systemd unit, `ss -tln` per server as `ports.txt`, and `antwort.txt` (the visit counter is cut off with `regex_replace`, otherwise the second run would not be `changed=0`)
- `terraform/pruefen.sh <init|variablen|validate|plan|apply>`: Terraform checkpoints for participants (separate from Ansible), prints `OK:`/`FEHLT:` with hints, exit code = number of failures. `plan` expects db1 locals values and accepts any plan; `apply` checks outputs, key mode 0600, inventory, containers, subnet, no published 5432. A non-empty plan after apply is only an INFO line (docker provider quirk seen with OrbStack: `ipam_config` and `log_opts` diffs). `scripts/dry-run.sh` runs it
- `pruefen.yml`: read-only checkpoints for participants (`--tags verbindung|db|zugriff|app`), each check prints `OK:` or `FEHLT:` plus a hint; failures are `ignore_errors` so all results show, `ignored=0` in the recap means green. The table of six checkpoints is in `ansible/README.md`. `scripts/dry-run.sh` runs it and fails on `ignored=[1-9]`
- role `postgresql`: install postgresql + python3-psycopg2, `listen_addresses = '*'`, `pg_hba` rule only for `db_user` from `app_netz` with scram-sha-256, service, user and DB via `community.postgresql` as user postgres. Defaults: `postgresql_version: "16"` (Ubuntu 24.04)
- role `app`: python3-psycopg2, system user `tlbg-app`, `/opt/tlbg-app/app.py` (stdlib HTTP server, counts visits in table `besuche`), `/etc/tlbg-app.env` (0640), systemd unit `tlbg-app`, handler restarts with daemon reload
- `requirements.yml`: `community.postgresql` (only needed with ansible-core)

Expected: `curl http://127.0.0.1:8080/` returns `Hallo von tlbg-schulung-app1! DB OK (172.30.0.21), Besuche: N`, `/health` returns `ok`, port 5432 closed from the host, second run `changed=0`.

Known harmless warning on the first run: `Module remote_tmp /var/lib/postgresql/.ansible/tmp did not exist ...` (becoming user postgres). A `remote_tmp` workaround was tried and reverted because the warning stayed.
