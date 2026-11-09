# Architecture of the lab environment

## Idea

We do not know for sure what the GFU lab desktop offers, and the client's OpenStack is not available. So the "servers" are Docker containers that behave like small VMs:

- Image `docker/Dockerfile`: Ubuntu 24.04 with systemd as PID 1, OpenSSH, Python 3, sudo, acl
- Containers run privileged with `cgroupns_mode = "host"`, `/sys/fs/cgroup` mounted read-write and tmpfs on `/run`, `/run/lock` (needed for systemd)
- `/usr/sbin/policy-rc.d` returns 101, so services do not auto-start during `apt install`. Ansible starts them after configuration. This also avoids nginx failing on containers without IPv6
- SSH keys: Terraform generates an ED25519 key (`tls_private_key`), uploads the public key to `/root/.ssh/authorized_keys`, writes the private key to `<root>/.ssh/id_lab` (0600)
- Ansible connects as root over SSH to `127.0.0.1:<port>`. `become: true` stays in playbooks for realism

## Flow

```
Terraform root (umgebung/ or miniprojekt/terraform/)
  -> docker_image (build from docker/)
  -> docker_network (fixed subnet)
  -> module "linux-server" per server (docker_container)
  -> local_file inventory.ini from a templatefile
Ansible (lab03, lab05, miniprojekt/ansible)
  -> reads inventory.ini, connects via SSH, configures the containers
```

## Shared module

`modules/linux-server` creates one container. Inputs: `name`, `image_id`, `network_name`, `ipv4_address`, `ssh_port`, `public_key`, `weitere_ports` (list of `{intern, extern}`). Outputs: `name`, `ssh_port`, `ipv4_address`. Used by `umgebung/` and `miniprojekt/terraform/`.

## Ports and subnets

| Thing | Value |
| --- | --- |
| `umgebung` network | `tlbg-umgebung`, 172.31.0.0/24 |
| `server1` | 172.31.0.11, SSH on 127.0.0.1:2211 |
| `server2` | 172.31.0.12, SSH on 127.0.0.1:2212 |
| Mini project network | `tlbg-schulung-netz`, 172.30.0.0/24 (`var.netz`) |
| `tlbg-schulung-app1` | 172.30.0.11, SSH on 127.0.0.1:2201, app on 127.0.0.1:8080 |
| `tlbg-schulung-db1` | 172.30.0.21, SSH on 127.0.0.1:2202, PostgreSQL 5432 only inside the network |
| Image name | `tlbg-linux:lab` |

All published ports bind to 127.0.0.1 only. `umgebung` and `miniprojekt` can run at the same time (different ports and subnets).

## Generated files (gitignored)

| File | Written by |
| --- | --- |
| `lab02-terraform-variablen/out/*` | lab 2 |
| `lab03-ansible-grundlagen/inventory.ini` | `umgebung/` (also used by lab 5) |
| `umgebung/.ssh/id_lab` | `umgebung/` |
| `miniprojekt/ansible/inventory.ini` | `miniprojekt/terraform/` |
| `miniprojekt/terraform/.ssh/id_lab` | `miniprojekt/terraform/` |

## Mapping to OpenStack (taught in 2.4 and 2.5)

| In the course | On OpenStack |
| --- | --- |
| `docker_network` with subnet | network and subnet |
| `docker_container` from an image | instance from image and flavor |
| DB port not published | security group: 5432 only from the app network |
| `tls_private_key` + upload | keypair |
| port forward to 127.0.0.1 | floating IP or load balancer |
| inventory from Terraform template | same, or the `openstack.cloud.openstack` inventory plugin |

## Requirements inside the GFU environment

- Linux control node: WSL2 or a Linux VM (Ansible does not run natively on Windows)
- Docker inside that Linux environment, user in group `docker`
- Terraform >= 1.6, the full `ansible` package (needs `community.postgresql`), Git, Python 3, SSH client, VS Code
- Internet: registry.terraform.io, github.com, Docker Hub (`ubuntu:24.04`), archive.ubuntu.com and security.ubuntu.com (apt inside the containers)

## Variants if the environment differs

- **A, Docker available:** everything as designed
- **B, GFU provides Linux VMs instead of Docker:** labs 1, 2, 4 unchanged. Skip `umgebung/` and `miniprojekt/terraform/`, write the inventory by hand (non-root user with sudo), set `db_host`, `app_netz`, `app_port` in the inventory. Ansible roles unchanged
- **C, no internet:** Terraform provider filesystem mirror, plus an apt proxy or mirror for the containers. Needs GFU Technik
