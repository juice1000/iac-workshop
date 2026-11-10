# Open points

Status 2026-11-11. Workshop starts Thursday 12 November (moved by one day).

## Blocking

- [ ] **Access test of the GFU lab environment.** RDP client and browser variants, from the teaching setup. Find out: is WSL or a Linux VM available, is Docker available, which tools are installed, admin rights, outbound internet (Terraform registry, GitHub, Docker Hub, Ubuntu mirrors), do desktops persist between day 1 and day 2, can the trainer prepare the desktop in advance, are trainer and participant accounts different from the test account
- [ ] **Run `bash scripts/dry-run.sh` inside the GFU environment** once the access test passes
- [ ] **Pick the variant** (A Docker, B VMs, C offline) based on the test, see `03-architecture.md`

## To clarify with GFU Technik

- [ ] Is the machine behind `rdp.gfu.cloud:44400` powered on? On 2026-11-09 TCP connects but the server does not answer the RDP handshake (`scripts/gfu-reach.sh`). Ask GFU to start it once so the login can be tested with an RDP client

- [ ] Linux control node (WSL or VM) available?
- [ ] Docker available inside it?
- [ ] Preinstalled tools, can missing ones be installed?
- [ ] Outbound internet access
- [ ] Is OpenTofu installed (only needed for the optional demo)?

## To clarify with the client

- [ ] Their typical database and application stack (mini project uses PostgreSQL and Python until told otherwise)
- [ ] Outbound TCP 43000 to 45999 open in their firewall for the RDP client (else browser access), Zoom test
- [ ] Inform them that the course teaches Terraform, OpenTofu only if time allows
- [ ] Confirm daily times

## Trainer preparation

- [x] Slides built (see `08-notion.md`): present the slides, Notion pages for depth
- [ ] Study checklist (Notion workshop page): walk through every lab timed, explain core concepts without notes, know the mini project failure modes
- [ ] Decide whether `docs/` and `CLAUDE.md` should be removed from the `start` branch
- [ ] Optional: write a short German Ansible handout instead of (or in addition to) the book recommendation
- [ ] Notion page title says "TLGW", the client is TLBG (typo?)

## Nice to have

- [x] Try the dry run on the Mac with OrbStack (passed 2026-11-09)
- [ ] Windows-friendly variant of `lab00-check` (PowerShell) if participants have no Linux shell
