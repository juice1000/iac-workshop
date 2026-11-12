# Context

## The engagement

| Item | Value |
| --- | --- |
| Client | TLBG (two participants, both very senior developers or admins) |
| Booked via | GFU (training provider), including the optional "complete cloud lab environment with remote access" |
| Trainer | Julien |
| Dates | Thursday 12 and Friday 13 November 2026 (moved by one day on 2026-11-11, originally 11 and 12), remote |
| Assumed daily hours | 09:00 to 16:30 with lunch 12:00 to 13:00 (not confirmed) |
| Language | German (participants), material in German |
| Video | Zoom |

## Goal

Give the participants a solid basic understanding of Terraform and Ansible. This is preparation for two later trainings: one from their data center about their own platform, then an extensive Terraform/Ansible course. So this is a compact intro, not a 5-day course squeezed into 2 days.

## Participants

- Two people, both very experienced in IT, both new to IaC
- They work on Windows and Linux machines
- One has no Git or GitHub experience (keep repo handling to clone and pull)
- Editors in use: VS Code, Notepad++

## Their target platform (later, not in this course)

- Fully in-house, OpenStack with Horizon, distribution OSISM
- They plan to use OpenTofu
- They have GitHub and want to use it
- Their own platform is not usable for this course (they get access only after their data center training)

## Constraints

- No AI usage inside the training
- The training runs in the GFU lab environment: a prepared Windows desktop reached via RDP (client or browser). Result of the 2026-11-12 test: WSL2 with Ubuntu 24.04 and Docker work inside it, see `09-windows-wsl-setup.md`
- Remote only

## Decision log

| Date | Decision | Why |
| --- | --- | --- |
| 2026-10-14 | Teach Terraform, OpenTofu only as an optional demo at the end | Same language and providers, trainer prefers Terraform; client was told OpenTofu is covered if time allows |
| 2026-10-14 | Linux only as target systems | Mixed OS would be too complex to teach in 2 days |
| 2026-10-14 | Exercises from the trainer's own GitHub, no Git intro | Simpler, participants are senior |
| 2026-11-09 | Mini project = application server with a remote DB server | This is the client's typical scenario (their answer) |
| 2026-11-09 | Mini project stack = PostgreSQL plus a small Python app | Client did not name a stack; generic and easy to read |
| 2026-11-09 | Lab servers are Docker containers with systemd and SSH, built by Terraform | Unknown GFU environment; Docker runs almost anywhere; containers behave like VMs for Ansible |
| 2026-11-09 | Material in Notion, code in this repo | Notion for teaching pages, repo for runnable code and CI |
| 2026-11-09 | `start` branch for participants with empty mini project role tasks | Solution stays on `main` |
| 2026-11-09 | Recommended German book for Ansible: Miesen, "Ansible" (Rheinwerk, 2nd ed.), chapters 1 to 5 only | Client wanted German material for Ansible; GFU material covers only Terraform. Writing an own handout was considered |

## Related

- A separate 3-day GKE workshop for another client also runs through GFU. Not part of this repo.
| 2026-11-11 | Workshop moved by one day: Thursday 12 and Friday 13 November | Schedule change, source not recorded |
