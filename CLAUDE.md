# Working in this repo

This is a skills repository: a collection of agent skills for Claude Code,
published as a plugin via `.claude-plugin/plugin.json`.

## Conventions

- One skill per kebab-case directory; the entry point is always `SKILL.md`.
- `SKILL.md` frontmatter has `name` (matching the directory) and `description`
  (what it does + when to trigger it). Keep descriptions specific — they are
  what the agent uses to decide relevance.
- Keep `SKILL.md` short. Move long reference material into sibling files
  (e.g. `FORMAT.md`, `examples.md`) and link to them from `SKILL.md` so they
  load only when needed.
- Supporting scripts live in a `scripts/` folder inside the skill directory.

## Lifecycle

- New skills start in `skills/in-progress/` and are not listed in the manifest.
  Test them locally with `scripts/link-skills.sh --drafts` (symlinks — edits
  are live; new skills register on the next session).
- Published skills live in a category folder (`engineering`, `productivity`,
  `misc`, `personal`) and MUST be listed in `.claude-plugin/plugin.json`.
- Retired skills move to `skills/deprecated/` and are removed from the manifest.

## When editing skills

- Never rename a skill directory without updating the manifest and its
  frontmatter `name`.
- If a skill gets a human-facing doc, it lives at
  `docs/<category>/<skill-name>.md` and should stay in sync with `SKILL.md`.
