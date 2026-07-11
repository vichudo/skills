---
name: new-branch-pr
description: 'Ship pending work as a PR to dev: verify everything is ok and clean, ensure dev exists (offering to make it the repository default), create a feature branch, commit conventionally by conceptual group, then open the PR.'
disable-model-invocation: true
---

# new-branch-pr

Turn the pending changes into a reviewable PR against `dev`.

1. **Pre-flight** — run the repo's cheap checks (lint, validators, fast tests — whatever exists); confirm `git status` shows only the expected changes. Abort and report if checks fail or something unexpected is dirty.
2. **Ensure `dev` exists** — if the repo has no `dev` branch, create it from the current default branch and push it. Then ask the user whether to make `dev` the repository default (`gh repo edit --default-branch dev`); change it only on their confirmation — never unprompted.
3. **Branch** — create a descriptive feature branch off `dev` (`feat/<topic>`, `fix/<topic>`, ...). If the changes build on an unmerged PR that touches the same files, stack on that branch instead and say so.
4. **Commit by conceptual group** — one conventional commit (`feat:`, `fix:`, `docs:`, `chore:`, ...) per concept, not per file. Keep coupled changes atomic (a change and the registration/config it requires land together). Bodies explain why, not what.
5. **Open the PR** — push with `-u`, then `gh pr create --base dev` with a summary of what and why per commit group. Report the PR URL and leave the working tree clean.
