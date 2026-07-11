# Skills

A personal collection of agent skills for Claude Code, organized by category and
installable as a Claude Code plugin.

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

## Local usage

- `scripts/list-skills.sh` — list every skill in the repo.
- `scripts/link-skills.sh` — symlink published skills into `~/.claude/skills`
  so Claude Code picks them up without installing the plugin.
