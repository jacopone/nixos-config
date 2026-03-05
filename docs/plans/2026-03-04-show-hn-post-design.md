---
status: draft
created: 2026-03-04
updated: 2026-03-04
type: guide
lifecycle: persistent
---

# Show HN Post — Design & Draft

## Post Details

**URL field:** `https://github.com/jacopone/nixos-config`

**Title:** `Show HN: NixOS + Flakes + Claude Code – 450 commits of a non-dev's AI-native OS config`

---

## First Comment (post within 5 minutes of submission)

I'm not a developer. My background is data science and finance — stats degree from Yale, then worked at Google, cofounded a fintech in Milan. Six months ago I couldn't tell you what a Nix derivation was. I'd never touched NixOS.

I started because I wanted Claude Code to manage my system, not just my code. Tried it on Ubuntu first and it was a disaster — Claude would edit .bashrc and break my shell, install packages that conflicted with each other, no way to undo any of it cleanly. A friend mentioned NixOS, I installed it on my Framework laptop, and within a week I realized this is what AI-assisted system management should look like. The whole system is one git repo. Claude edits a .nix file, I rebuild, if it breaks I roll back in one command. No more "what did the AI just do to my system?"

It kind of snowballed from there. 450 commits later I'm running 6 machines off this config — my Framework 16 dev workstation, a ThinkPad, and a bunch of business laptops for people who've never opened a terminal. The config has two profiles: a "tech" profile with 350+ packages and a full AI toolchain (Claude Code, Cursor, local speech-to-text, the works), and a "business" profile with ~40 curated packages for office use. Adding a new machine is three lines in flake.nix.

Some things I built along the way that I didn't expect to need:

A script that spins up Claude Code in a sandboxed git worktree with bubblewrap + seccomp so it can work autonomously in the background. It runs in a tmux session and loops with fresh context up to 5 times. I use it for overnight refactoring.

Custom NixOS installer ISOs — I can ship a USB stick to someone, they plug it in, and they get a working system with Claude Code pre-configured as their "sysadmin." They ask Claude to install software, Claude edits the config, they rebuild. I manage their machines remotely via git push.

CI/CD with BATS tests, ShellCheck, security scanning. The repo has a two-branch model where personal (my dev branch) auto-syncs to master via CI with path sanitization so nothing personal leaks to the public repo.

The biggest thing I've learned: NixOS is the only OS I've used where AI can't permanently break anything. Declarative config means Claude always knows the exact system state. Atomic upgrades mean every rebuild either succeeds completely or doesn't happen at all. And if something goes wrong, I pick the previous generation from the boot menu. I've bricked my system maybe 15 times and recovered in under a minute every single time.

What still sucks: the Nix learning curve is real even with AI. Claude writes non-idiomatic Nix all the time and I can't always tell. Flake lock updates break things in ways that take hours to figure out. Error messages are famously terrible. And NixOS is not for everyone — it's a tradeoff between upfront complexity and long-term reliability.

Is anyone else doing something like this? Not just using AI to write code, but to manage and evolve their actual operating system. What are you running into?

Repo: https://github.com/jacopone/nixos-config

---

## Pre-Launch Checklist

- [ ] Make sure README on master branch is up to date and polished (this is the landing page)
- [ ] Verify the repo is public and master has recent synced content
- [ ] Remove any personal data that shouldn't be public (paths, usernames in examples)
- [ ] Block calendar for 24-48 hours post-submission — respond to every comment
- [ ] Post on Tuesday-Thursday, 8-10 AM Pacific Time
- [ ] Post first comment within 5 minutes of submission
- [ ] Have 5-10 people ready to genuinely try and leave real comments (not upvotes)
- [ ] Prepare answers for likely challenges:
  - "Why not Docker/Ansible?" — Docker is app isolation, not system management. Ansible runs scripts that can drift. NixOS is declarative system state.
  - "Isn't this just dotfiles?" — It's the entire OS: bootloader, kernel modules, packages, services, user config. Not just shell config.
  - "Claude Code must cost a fortune" — discuss actual spend if comfortable
  - "Why not just learn Nix properly?" — I am learning it, through AI. That's the point.
  - "This is just a NixOS config, lots of people have those" — Not many have 10 machine profiles, autonomous AI scripts, custom ISOs, and CI/CD. And the process of building it entirely through AI is the story.

## Strategic Notes

- Don't mention YC or Amatino in the post. Let partners discover the connection through the HN profile.
- Make sure HN profile links to relevant info (GitHub, personal site)
- The "non-developer" angle is the differentiator — lean into it, don't hide from it
- Be genuinely responsive in comments, especially to criticism. HN rewards humility.
- If the post doesn't take off, email hn@ycombinator.com for the second-chance pool
