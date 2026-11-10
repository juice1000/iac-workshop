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

### Lecturer's Edition (trainer only, English, questions and challenges in German)

| Page | Content | URL |
| --- | --- | --- |
| Lecturer's Edition | how to use, where the workshop leads, recurring threads, how participants submit challenges, parking lot, follow-ups after the workshop | https://app.notion.com/p/4147a614759581aeb9ffe0d04ca17dd5 |
| Day 1: Lecturer notes | per chapter 1.1 to 1.6: gist, points to land, questions with expected answers, challenge with "Abgabe", pitfalls, bridge to the next chapter | https://app.notion.com/p/4147a614759581bcac60e72aa2565201 |
| Day 2: Lecturer notes | same for 2.1 to 2.5 | https://app.notion.com/p/4147a6147595812db5caef0c34011dc2 |

When a chapter changes, check whether its block in the Lecturer's Edition still fits (questions and challenges reference lab commands).

### Slides (shown to participants)

Not in Notion: a Claude Slides artifact, "Terraform & Ansible: Workshop-Folien", https://claude.ai/artifact/XAihkrchhuq9Sg2pcG15hg (private until shared). German, visual-first, one section per block (1.1 to 2.5), divider slide per block, lab slides with the commands, short English trainer notes per slide. Exports to PPTX and PDF. Lab commands on the slides mirror the lab folders, so when a lab command changes, update the matching lab slide too.

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
| Glossar | all terms A to Z with chapter reference | https://app.notion.com/p/4137a61475958100865aeade0d5bc51a |
| Repository und Lernumgebung | repo layout, prep checklist, clone command, requirements, variants, Dockerfile, module and `umgebung` code | https://app.notion.com/p/4137a614759581ca956ef0b4a2519df2 |
| Cheat Sheet Terraform und Ansible | commands and skeletons | https://app.notion.com/p/4137a6147595816b840af9657947ee1c |
| Trainer-Notizen und FAQ | test status, dry run checklist, pitfalls, FAQ for senior admins, cutting plan | https://app.notion.com/p/4137a614759581358a80d04dd06a7685 |

## Structure of every chapter page (book style, since 2026-11-10)

1. Blue overview callout ("In diesem Kapitel ...", with duration)
2. Table of contents block
3. Lernziele as a to-do checklist
4. Numbered sections with narrative prose, Mermaid diagrams, annotated code, comparison tables and side-by-side columns
5. Lab section: steps, then "Was ihr sehen solltet" in a toggle, bonus with answer toggle, full solution in a toggle
6. "Das Wichtigste in Kuerze" summary and "Kontrollfragen" (answers in toggles)
7. Divider, then "Fuer den Trainer" gray callout (schedule, pitfalls, test status)

Callout legend: blue book = overview, blue bulb = Merke, yellow warning = Achtung, gray magnifier = Hintergrund, gray teacher = trainer notes.

## Notion formatting gotchas

- Use `<toggle>` with the title on the first line, a blank line, then tab-indented children. `<details>` gets auto-converted
- Code blocks inside toggles and columns work when every line is indented with the right number of tabs (blank lines need the tabs too)
- Bold or plain filenames ending in a real TLD (`.tf`, `.sh`, `.py`) get auto-linked (`http://main.tf`). Always wrap filenames in inline code
- Fetched pages show inline code as `<code>` and bold as `<b>`; build `old_str` for edits from a fresh fetch
- Validate Mermaid diagrams locally with `mmdc -i file.mmd -o file.svg` before publishing
