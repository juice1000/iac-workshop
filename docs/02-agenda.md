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

Replanned after day 1 (only labs 1 and 2 were finished, the pace was too high). Day 2 focuses on lab 3 and the mini project. Labs 4 and 5 are shown briefly as walkthroughs. They are complete on `start` and serve as reference for the mini project.

| Time | Block | Lab folder |
| --- | --- | --- |
| 09:00 to 09:20 | 2.1 Recap of day 1 (state, variables, for_each in five minutes). Start the `umgebung` apply first, the image build takes minutes | `umgebung` |
| 09:20 to 10:15 | 2.2 Ansible concepts: inventory, ad-hoc, modules, idempotence. `erste-schritte/ansible` against localhost while the build runs, then `ansible web -m ping` and an ad-hoc command | `erste-schritte/ansible`, start of `lab03-ansible-grundlagen` |
| 10:15 to 10:30 | Break | |
| 10:30 to 12:00 | 2.3 Lab 3: fill the playbook gaps, run, second run `changed=0`, check/diff, change the port and see the handler | `lab03-ansible-grundlagen` |
| 12:00 to 13:00 | Lunch | |
| 13:00 to 13:30 | 2.4 Walkthrough of modules (lab 4, about 15 minutes) and roles (lab 5, about 15 minutes). Run them, read the code, no coding. Both are reference for the project | `lab04-terraform-module`, `lab05-ansible-rolle` |
| 13:30 to 15:40 | 2.5 Mini project: app server with remote DB server (phases below) | `miniprojekt` |
| 14:50 to 15:05 | Break (inside the mini project) | |
| 15:40 to 16:30 | 2.6 Review, best practices, OpenStack outlook, feedback | none |

## Mini project phases (2.5)

| Time | Phase | What participants do |
| --- | --- | --- |
| 13:30 | Intro (10 min) | Scenario, comparison with OpenStack |
| 13:40 | Phase 1: Terraform (30 min) | Fill the `TODO` gaps in `miniprojekt/terraform/main.tf` (db1 entry, network subnet, module inputs), then apply. Reference: lab 2 and lab 4 |
| 14:10 | Phase 2: role postgresql (40 min) | Write the role tasks. Reference: lab 3 playbook and lab 5 role, `ansible-doc` |
| 14:50 | Break (15 min) | |
| 15:05 | Phase 3: role app (35 min) | Write the role tasks, templates and handler are given. Reference: lab 5 role |
| 15:40 | Phase 4 (end of block) | Smoke test. Destroy and rebuild only as trainer demo if time allows |

## Cutting plan if time runs short

1. Bonus and stretch tasks in all labs
2. OpenTofu demo and OpenStack outlook
3. Destroy and rebuild in the mini project as trainer demo
4. Walkthrough of lab 4 and lab 5 (only if lab 3 overruns, the mini project then explains modules and roles on the fly)

Never cut: lab 3, the mini project.

Deliberately left out as beyond "basics only" (decided 2026-11-10): Terraform import, `moved`, workspaces, pipeline workflows, Ansible dynamic inventory.
