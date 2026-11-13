# Agenda

Times assume 09:00 to 16:30. Each block has a Notion page with learning goals, content, lab steps, solution and trainer notes (see `08-notion.md`).

## Day 1: Fundamentals (Thursday 12 November)

| Time | Block | Lab folder |
| --- | --- | --- |
| 09:00 to 09:30 | 1.1 Kickoff and lab check | `lab00-check` |
| 09:30 to 10:15 | 1.2 IaC concepts (declarative, idempotence, Terraform vs Ansible) | none |
| 10:15 to 10:30 | Break | |
| 10:30 to 12:00 | 1.3 Terraform basics: providers, resources, init/plan/apply/destroy, state. Starts with a 10 minute command line warm-up | `erste-schritte/terraform`, then `lab01-terraform-grundlagen` |
| 12:00 to 13:00 | Lunch | |
| 13:00 to 14:15 | 1.4 Variables, locals, outputs, for_each, templatefile | `lab02-terraform-variablen` |
| 14:15 to 14:30 | Break | |
| 14:30 to 16:00 | 1.5 Ansible basics: inventory, ad-hoc, module overview, playbooks, templates, handlers | `umgebung` (start the apply first, the image build takes minutes), `erste-schritte/ansible` against localhost while it builds, then `lab03-ansible-grundlagen` |
| 16:00 to 16:30 | 1.6 Recap and quiz | none |

## Day 2: Ansible and mini project (Friday 13 November)

Replanned after day 1 (only labs 1 and 2 were finished, the pace was too high). Day 2 ends at 16:00 and focuses on lab 3 and the mini project. Labs 4 and 5 are shown briefly as walkthroughs. They are complete on `start` and serve as reference for the mini project.

| Time | Block | Lab folder |
| --- | --- | --- |
| 09:00 to 09:15 | 2.1 Recap of day 1 (state, variables, for_each in five minutes). Start the `umgebung` apply first, the image build takes minutes | `umgebung` |
| 09:15 to 10:15 | 2.2 Ansible concepts: inventory, ad-hoc, modules, idempotence. `erste-schritte/ansible` against localhost while the build runs, then `ansible web -m ping` and an ad-hoc command | `erste-schritte/ansible`, start of `lab03-ansible-grundlagen` |
| 10:15 to 10:30 | Break | |
| 10:30 to 12:00 | 2.3 Lab 3: fill the playbook gaps, run, second run `changed=0`, check/diff, change the port and see the handler | `lab03-ansible-grundlagen` |
| 12:00 to 13:00 | Lunch | |
| 13:00 to 13:25 | 2.4 Walkthrough of modules (lab 4, about 12 minutes) and roles (lab 5, about 12 minutes). Run them, read the code, no coding. Both are reference for the project | `lab04-terraform-module`, `lab05-ansible-rolle` |
| 13:25 to 15:40 | 2.5 Mini project: app server with remote DB server (phases below) | `miniprojekt` |
| 15:40 to 16:00 | 2.6 Short review, what to take home, feedback | none |

## Mini project phases (2.5)

| Time | Phase | What participants do |
| --- | --- | --- |
| 13:25 | Intro (5 min) | Scenario in one picture, OpenStack comparison in two sentences |
| 13:30 | Phase 1: Terraform (30 min) | Write `versions.tf`, `variables.tf`, `outputs.tf` and fill the `TODO` gaps in `main.tf` (private key resource, Dockerfile path, db1 entry, network subnet, module inputs, inventory values), then apply. Every gap names its reference (`umgebung/main.tf`, lab 2) |
| 14:00 | Phase 2: role postgresql (40 min) | Write the first two plays of `site.yml`, the postgresql handler and fill the gaps in the role tasks. Every gap names its reference (lab 3, lab 5) or the `ansible-doc` call |
| 14:40 | Break (15 min) | |
| 14:55 | Phase 3: role app (30 min) | Write the app handler and the smoke test tasks, fill the gaps in the role tasks, templates are given |
| 15:25 | Phase 4 (15 min) | Smoke test, compare with `main` if something fails. Destroy and rebuild only as trainer demo if time allows |

## Cutting plan if time runs short

1. Bonus and stretch tasks in all labs
2. OpenStack outlook, OpenTofu demo, best-practices block (day 1 recap covers the basics)
3. Destroy and rebuild in the mini project as trainer demo
4. Walkthrough of lab 4 and lab 5 (only if lab 3 overruns, the mini project then explains modules and roles on the fly)

Never cut: lab 3, the mini project.

Deliberately left out as beyond "basics only" (decided 2026-11-10): Terraform import, `moved`, workspaces, pipeline workflows, Ansible dynamic inventory.
