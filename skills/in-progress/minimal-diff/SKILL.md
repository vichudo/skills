---
name: minimal-diff
description: 'Implement a change as the smallest diff that fully satisfies it — maximum reuse of what the repo already has, APIs verified current rather than remembered, one clean seam instead of scattered edits, zero drive-by churn. Use when asked for a minimal, surgical, tight, or clean implementation, when a change feels larger than the feature warrants, or to shrink a diff before review.'
argument-hint: "[feature to implement, or diff/branch to shrink]"
---

# minimal-diff

Objective: `min(diff) subject to feature complete ∧ practices current ∧ architecture clean`. A *constrained* minimization — the constraints are hard, so a shorter diff that drops a requirement, an error path, or a reader's understanding is a failed run, not a better one. What shrinks is the code someone must hold in their head; what grows is reuse.

## The metric

Lines are the proxy the reader sees; **net new concepts** are what you actually minimize — files, exports, parameters, config keys, dependencies, indirection layers, and idioms a reviewer had not already learned. Rank candidate implementations by concepts first, files touched second, lines third. Character-golfing scores nothing.

## Axioms

1. **The shortest code is the code already there** — survey for an existing helper, hook, primitive, or pattern before adding one. Every new file asserts that nothing in the repo fits; earn that assertion by looking first.
2. **Cut concepts, not characters** — nested ternaries, collapsed guards, and dropped error handling shorten the diff and lengthen the reading. Delete ideas, never whitespace or clarity.
3. **Change altitude, not call sites** — the same edit repeated across N files belongs one layer down. One edit at the right seam beats N correct edits at the wrong one.
4. **Current beats remembered** — verify every API against today's docs or a loaded skill, never memory. The current primitive usually replaces hand-rolled code, so latest practice and smallest diff point the same way; when they diverge, state which you chose and why.
5. **Two callers before an abstraction** — no options object, flag, wrapper, or extension point without a real caller today. Speculative generality is diff paid for now and deleted later.
6. **Consistency is free compression** — code shaped like its neighbors reads as a smaller change, because the reviewer already knows the shape. A pattern that is better in the abstract but foreign here costs more than it saves; introduce one deliberately, once, with the reason stated.
7. **Touch nothing else** — no reformatting, renaming, import reordering, or unrelated fixes. Churn inflates the diff and camouflages the real change; it belongs in its own commit.
8. **Aim net-negative** — the best feature diff deletes more than it adds. Always ask what the new path makes dead, and delete that in the same change.
9. **Prefer the platform** — a stdlib or framework primitive over a new dependency: one line in the diff, permanent cost in the project.
10. **Beautiful means reviewable** — the goal state is a diff a reviewer holds entirely in their head and explains hunk by hunk. Architecture is judged by that test, not by layer count.

## Procedure

1. **Fix the scope** — restate the feature as the observable behavior change plus the smallest true definition of done. Anything the ask does not imply is out.
2. **Survey before writing** — read the surrounding code, its idioms, and the seams it already offers; confirm the current API for every library involved. Spend real time here: this step, not the typing, decides diff size.
3. **Choose the seam** — enumerate candidate insertion points, pick the one minimizing (new concepts, files touched, call sites disturbed). If the right seam does not exist yet, creating it is itself a concept — justify it.
4. **Implement plainly** — reuse everything reusable, add nothing speculative, keep types and error paths honest, name from the domain vocabulary already in the code.
5. **Shrink pass** — per hunk: does removing it break the feature? does an existing helper or framework primitive already do it? is it at the right altitude? what does it make dead? Delete accordingly.
6. **Verify** — lint, typecheck, tests, and the real path if it is cheap to exercise. A smaller diff that fails the constraints is not a result.
7. **Read the diff cold** — `git diff` end to end, as a reviewer with no context. Every hunk explainable in one sentence; unexplainable hunks get deleted, not defended.

## Anti-patterns

| Anti-pattern | Symptom | Fix |
|---|---|---|
| Golfed diff | Fewer lines, more to decode; error handling gone | Restore clarity — count concepts, not characters |
| Drive-by churn | Reformatting, renames, import reorders inside the feature diff | Revert them; separate commit |
| New-file reflex | A util/service/helper created for one caller | Inline it at the seam it serves |
| Speculative option | A parameter or flag whose only caller passes the default | Delete the parameter |
| Call-site copy-paste | The same few lines added in many files | Move the change one layer down |
| Dependency for a one-liner | New package for what the platform already does | Use the platform |
| Parallel idiom | A second way to do what the codebase already does | Adopt the existing idiom, or migrate it wholesale and say why |
| Remembered API | Deprecated or invented call written from memory | Verify against current docs; the current API is usually shorter |
| Orphaned old path | New code added, superseded code left in place | Delete what the change obsoletes |
| Scope creep in disguise | "While I was in there…" | Report it, leave it out |

## Hard constraints

- **Never trade scope for size** — if the diff can only shrink by dropping a requirement, stop and say so. That trade is the user's call, not the compressor's.
- **Never trade correctness for size** — error paths, honest types, and existing tests stay. Deleting a test to shrink a diff is a defect, not an optimization.
- **Never widen the blast radius** — bugs, TODOs, and ugliness found outside the change are reported, not fixed here.

## Report

Close with the shape of the change, not a narrative: files touched · net lines (+/−) · new concepts introduced · what was reused instead of written · what was deleted · anything the constraints forced you to keep. Then any out-of-scope findings, one line each.
