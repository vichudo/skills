# phrase-goal — worked examples

## 1. Parallel workstreams

**Raw input:** Prepare research structure for each client question; finish
answering the questions; in parallel, set up a task management tool for the team
(or evaluate an off-the-shelf option); in parallel, maintain and improve the two
internal tools we depend on.

**Primary outcome:** the client questions are answered — nothing else saves the
week if that slips. The tooling and the task system are instruments.

**Result:**

> By Friday, 70% of the client questions carry a complete, sourced answer,
> produced with upgraded internal tools and coordinated through a working task
> system for the team.

Why it passes: deadline first (3), 70% is a graded threshold (4, 9), "carry a
complete, sourced answer" is an accomplished fact (2), and the two parallel
tracks became instrumental clauses instead of conjuncts (5, 10).

## 2. Effort goal → outcome goal

**Raw input:** Keep working on the onboarding flow, do some user interviews, and
try to reduce drop-off.

**Result:**

> By March 14, the rebuilt onboarding flow is live for all new signups with the
> three highest drop-off steps removed, identified in five completed user
> interviews.

"Keep working on" named no finished state (anti-pattern: effort goal); "reduce
drop-off" was unfalsifiable until it named countable artifacts. And "drop-off
below 25%" would have handed the verdict to how users behave in March (11) — we
control which steps ship removed; the percentage is a result to track.

## 3. List goal → connected goal

**Raw input:** Migrate the database, write the migration runbook, and train the
on-call team.

**Result:**

> By the end of Q3, production runs on Postgres 16 with zero unplanned downtime,
> executed from a written runbook the on-call team has rehearsed once.

The three items were `A ∧ B ∧ C`. Only the migration is the outcome; the runbook
and the rehearsal are how it is achieved safely — and each stays countable
("written", "rehearsed once").

## 4. Hostage goal → controllable goal

**Raw input:** Close the Acme enterprise deal, get their security questionnaire
approved, and land a case study with them.

**Primary outcome:** not the signature — Acme's buying committee owns that date,
and no amount of our work moves it on demand.

**Result:**

> By November 30, Acme's buying committee holds a complete decision package —
> priced proposal, answered security questionnaire, and a case study draft
> submitted for their approval.

Every element is something we hand over, so a stranger can grade it on November
30 without asking Acme anything (11). The signature stays on the dashboard as a
result to track; making it the goal would mean failing the quarter over a
meeting someone else reschedules.

## 5. Unavoidable dependency → stated condition

**Raw input:** Launch the partner integration once they ship API v2 — they keep
slipping, so chase them weekly; meanwhile write the migration guide and brief
support.

**Primary outcome:** the integration is live. The partner's release is not ours
to produce, but nothing downstream exists without it, so it cannot be dropped
either.

**Result:**

> Once the partner ships API v2 on October 15, by October 31 the integration is
> live for every customer on the new endpoint, with the migration guide
> published and support briefed on it.

The dependency is named once, in the frame, so everything graded on October 31
is ours (11). "Once" carries no special weight — "Given the partner ships...",
"With v2 released..." do the same job; the position is what matters. "Chase them
weekly" disappears: activity aimed at someone else would make diligence look
like success. If the ship date moves, the goal is restated on the new condition
rather than silently missed.
