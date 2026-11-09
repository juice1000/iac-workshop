# Notion

The teaching material (German participant pages, trainer notes) lives in Notion, workspace "Workshops". Code lives here. When lab code changes, update the matching Notion page.

With the Notion MCP in Claude Code, fetch a page by URL, then use targeted search-and-replace edits. Fetched pages render inline code as `<code>` tags and bold as `<b>`, so build `old_str` from a fresh fetch.

## Page tree

| Page | URL |
| --- | --- |
| Terraform & Ansible - TLGW (overview, plan, access test, agenda, risks) | https://app.notion.com/p/3ff7a614759580689b85e90dd972dc82 |
| Material Tag 1: Grundlagen | https://app.notion.com/p/4127a61475958188b59ae6576ecf0781 |
| Material Tag 2: Praxis und Miniprojekt | https://app.notion.com/p/4127a6147595817ea6a8ff4585c97074 |
| Material Allgemein | https://app.notion.com/p/4127a614759581e3a093f94d2dd91fc8 |

### Day 1

| Page | Repo folder | URL |
| --- | --- | --- |
| 1.1 Kickoff und Lab-Check | `lab00-check` | https://app.notion.com/p/4137a6147595810f97eaeee794bfccf4 |
| 1.2 IaC-Konzepte | none | https://app.notion.com/p/4137a6147595810c9b0dc083ccd2ed83 |
| 1.3 Terraform-Grundlagen und Lab 1 | `lab01-terraform-grundlagen` | https://app.notion.com/p/4137a614759581ff8580e4b3e9fa2476 |
| 1.4 Variablen, Outputs, for_each und Lab 2 | `lab02-terraform-variablen` | https://app.notion.com/p/4137a614759581e9a6f3d5a54bc5a8d5 |
| 1.5 Ansible-Grundlagen und Lab 3 | `umgebung`, `lab03-ansible-grundlagen` | https://app.notion.com/p/4137a614759581bb9e9ede1c21c1c9c2 |
| 1.6 Recap Tag 1 | none | https://app.notion.com/p/4137a6147595819aaf80e785cfe47113 |

### Day 2

| Page | Repo folder | URL |
| --- | --- | --- |
| 2.1 Recap und Fragen | none | https://app.notion.com/p/4137a614759581499e1fffbef3a02a0b |
| 2.2 Terraform in der Praxis und Lab 4 | `lab04-terraform-module` | https://app.notion.com/p/4137a614759581ca9789e74e36541679 |
| 2.3 Ansible in der Praxis und Lab 5 | `lab05-ansible-rolle` | https://app.notion.com/p/4137a61475958150b5e3d0a27c5d0f8b |
| 2.4 Miniprojekt | `miniprojekt` (task description) | https://app.notion.com/p/4137a614759581c38c05f6c7b1d758b9 |
| 2.4b Loesung Miniprojekt | `miniprojekt` (full code) | https://app.notion.com/p/4137a61475958139a606f1e1c1073403 |
| 2.5 Review und Wrap-up | none | https://app.notion.com/p/4137a6147595817c840ad933b9c2f989 |

### General

| Page | Content | URL |
| --- | --- | --- |
| Repository und Lernumgebung | repo layout, prep checklist, clone command, requirements, variants, Dockerfile, module and `umgebung` code | https://app.notion.com/p/4137a614759581ca956ef0b4a2519df2 |
| Cheat Sheet Terraform und Ansible | commands and skeletons | https://app.notion.com/p/4137a6147595816b840af9657947ee1c |
| Trainer-Notizen und FAQ | test status, dry run checklist, pitfalls, FAQ for senior admins, cutting plan | https://app.notion.com/p/4137a614759581358a80d04dd06a7685 |

## Structure of every block page

Lernziele, Ablauf, Inhalte, Demo, Lab (Schritte, Erwartete Ergebnisse, Bonus), Loesung (code), Trainer-Notizen (gray callout).
