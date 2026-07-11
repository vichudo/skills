# Skills

A personal collection of agent skills for Claude Code, organized by category and
installable as a Claude Code plugin.

## Install

### Any agent, via [skills.sh](https://skills.sh)

```
npx skills add vichudo/skills
```

Works for Claude Code, Cursor, Codex, and other supported agents. Update later
with `npx skills update`.

### Claude Code, as a plugin

```
/plugin marketplace add vichudo/skills
/plugin install vichudo-skills@vichudo
```

Skills arrive namespaced (e.g. `/vichudo-skills:handoff`). New versions ship on
every commit to `main`; update with `/plugin marketplace update vichudo`.

## Repo layout

```
.claude-plugin/       Plugin manifest — every published skill must be listed here
.github/workflows/    CI / release automation
docs/                 Human-facing docs, mirroring the skill categories
scripts/              Repo utilities (list skills, link skills locally)
skills/
  engineering/        Skills for building and maintaining software
  productivity/       Skills for planning, writing, and thinking
  misc/               Skills that don't fit another category
  personal/           Skills tied to my own setup — not meant for reuse
  in-progress/        Drafts, not yet published in the plugin manifest
  deprecated/         Retired skills, kept for reference
```

## Anatomy of a skill

Each skill is a kebab-case directory containing a `SKILL.md`, plus any supporting
files it references:

```
skills/engineering/my-skill/
  SKILL.md            The skill itself (required)
  some-reference.md   Optional supporting material loaded on demand
  scripts/            Optional helper scripts
```

`SKILL.md` starts with YAML frontmatter:

```markdown
---
name: my-skill
description: One or two sentences saying what the skill does and when to use it.
---

Instructions for the agent go here.
```

## Adding a skill

1. Draft it under `skills/in-progress/<skill-name>/SKILL.md`.
2. When it's ready, move it into its category folder.
3. Register it in `.claude-plugin/plugin.json` under `"skills"`.
4. Optionally add a human-facing page under `docs/<category>/<skill-name>.md`.

## Local usage & testing

- `scripts/list-skills.sh` — list every skill in the repo.
- `scripts/link-skills.sh` — symlink published skills into `~/.claude/skills`
  so Claude Code loads them straight from the repo. Edits are live (symlinks,
  not copies); a brand-new skill registers on the next session.
- `scripts/link-skills.sh --drafts` — also link `skills/in-progress/`, for
  testing new skills before they graduate to a category.
- `claude plugin validate .` — check the plugin and marketplace manifests.

On the machine holding this repo, prefer the symlinks over `npx skills add` —
an installed copy and a linked copy of the same skill would collide. To test
the exact plugin install path end-to-end, add the repo as a local marketplace:
`claude plugin marketplace add ~/Documents/Github/skills`.
