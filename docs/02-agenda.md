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

## Day 2: Practice and mini project (Friday 13 November)

| Time | Block | Lab folder |
| --- | --- | --- |
| 09:00 to 09:20 | 2.1 Recap, restart lab servers if the desktop was reset | `umgebung` |
| 09:20 to 10:15 | 2.2 Terraform in practice: modules, layout, shared state with locking (concept), secrets | `lab04-terraform-module` |
| 10:15 to 10:30 | Break | |
| 10:30 to 12:00 | 2.3 Ansible in practice: roles, layout, precedence, collections, Vault | `lab05-ansible-rolle` |
| 12:00 to 13:00 | Lunch | |
| 13:00 to 15:15 | 2.4 Mini project: app server with remote DB server | `miniprojekt` |
| 15:15 to 15:30 | Break | |
| 15:30 to 16:30 | 2.5 Review, best practices, OpenStack outlook, optional OpenTofu demo, feedback | none |

## Mini project phases (2.4)

| Time | Phase | What participants do |
| --- | --- | --- |
| 13:00 | Intro | Scenario, comparison with OpenStack |
| 13:10 | Phase 1: Terraform | Guided: read and run `miniprojekt/terraform` |
| 13:45 | Phase 2: role postgresql | Write the tasks (start branch has them as comments) |
| 14:20 | Phase 3: role app | Write the tasks, templates and handler are given |
| 14:55 | Phase 4 | Smoke test, destroy, rebuild from scratch |

## Cutting plan if time runs short

1. Bonus and stretch tasks in all labs
2. OpenTofu demo
3. Destroy and rebuild in the mini project as trainer demo

Never cut: state, modules, roles, mini project.

Deliberately left out as beyond "basics only" (decided 2026-11-10): Terraform import, `moved`, workspaces, pipeline workflows, Ansible dynamic inventory.
