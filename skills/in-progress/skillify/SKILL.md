---
name: skillify
description: 'Distill the session that just went well into a reusable skill: the principles that actually caused the good result — the decisions it hinged on, the corrections that redirected the agent, the checks that proved it done — lifted from this instance to its task family, so a fresh agent reproduces the outcome reliably. Use at the end of a conversation that implemented a feature, solved a novel problem, or ran a process notably well, when the user wants to capture it, replicate it, or "make this a skill".'
argument-hint: "[what made it good, or the task family to target]"
disable-model-invocation: true
---

# skillify

Objective: a skill that lets a fresh agent, with none of this session's context, reach this session's result on the next instance of the same kind of task. Capture the **delta** — what this session did that a capable agent would not do by default, and that the result depended on. What the agent does anyway is noise in a skill; what belongs only to this instance is noise too.

## Evidence, by signal

Mine two layers — the **solution** (what made the output good) and the **execution** (how the agent got there: where it gathered context, what it verified, when it asked and when it proceeded) — from these sources, strongest first:

1. **Corrections** — every place the user redirected, rejected, or tightened, and every approach the agent abandoned or rewrote. Each marks a default that fails; the correction is the rule.
2. **Pivotal decisions** — choices among real alternatives that the result hinged on, with the reason the alternative lost.
3. **Proof of done** — the check, evidence, or acceptance criterion that showed the result was good, in the conversation or in the live state it left (a merged PR, green CI, a deployed page). Re-check that state: a defect that slipped through is the strongest evidence for the check that would have caught it.
4. **Discovered constraints** — facts learned mid-session that changed the approach: version traps, renamed APIs, environment quirks.
5. **The user's bar** — standards they enforced or praised, made explicit.

Chronology and routine tool use carry almost no signal.

## Axioms

1. **Delta over transcript** — a line that doesn't change what a fresh agent does costs context on every load and buys nothing. Test each one: without it, would the agent act differently? If not, delete it.
2. **Cause, not coincidence** — a good session is full of steps that didn't cause the good result. Keep a principle only when you can point to the session moment showing the result would have been worse without it, or that the next run would trip without knowing it.
3. **Class, not instance** — the skill serves the task family. Lift every literal that would differ on the next instance — file names, products, values — to the role it played, then check each rule against a second, different instance: a rule that fits only this one is an example, not an axiom.
4. **Every rule carries its why** — without a reason, a rule gets applied where it doesn't fit and dropped where it does. One clause of why lets the next agent extend it to cases this session never met.
5. **Freedom matches fragility** — judgment becomes principles; a sequence that breaks when improvised (command order, migration steps, byte-exact config) becomes a script or an exact checklist. Scripted judgment turns brittle; a fragile sequence left to judgment turns unreliable.
6. **Done is gradeable** — replication is only reliable when success is defined the same way every time. Lift the done check from what actually proved this session done, phrased so a stranger can grade it pass/fail.
7. **Faithful to evidence** — capture what was observed to work, at the scope it was observed. Untested hunches stay out or are marked untested; a success under specific conditions is stated with those conditions, not as law.
8. **Date the perishable** — version-bound facts rot. Record the version and date verified, and make the skill re-verify against the live environment instead of trusting the record.
9. **Extend before adding** — if an existing skill already covers this task family, the lessons amend it (or, when it isn't the user's to edit, the new skill references it); two skills for one job split the triggering and drift apart. Lessons that are facts rather than a way of working (a project quirk, a stale memory) go to the memory or project instructions the next session loads. Skills the session invoked are referenced (`use X for Y`), never restated.
10. **Shareable by default** — skills get synced, published, and handed to teammates. Replace secrets, credentials, and personal or client data with the roles they played — always; internal hosts and absolute paths too, unless the destination is as private as they are.

## Procedure

1. **Recover the whole session** — the evidence is the full conversation, not its last screen. If earlier turns were compacted, read them back from the transcript (Claude Code: `~/.claude/projects/*/${CLAUDE_SESSION_ID}.jsonl`); tool results and injected skill bodies are logged as `user` entries beside the human's turns, and the evidence often sits in tool inputs and results, so don't truncate them.
2. **Name the task family** — one sentence: the class of problem this session was one instance of — what it *did*, not the subject of what it produced — at the highest altitude its evidence supports. Lower and the skill fits only this task; higher and the principles go generic or unproven.
3. **Mine** — list candidate principles from the evidence, each with a pointer to the session moment behind it.
4. **Filter, then decide** — run every candidate through axioms 1–3 and merge duplicates; most fail. Write a skill only when something proved the result good (a passing check, the user accepting it) and the survivors form a way of working. One easy step, an unverified result, or survivors that are mere facts mean no skill: route them per axiom 9 and say so — never pad a skill into existence.
5. **Survey the destination** — skills that already cover the family (axiom 9); the conventions where it will live (repo instructions, sibling skills' shape and voice, draft/publish lifecycle, and who can read it — a draft folder in a published repo is public); name collisions across every agent that loads skills on this machine, including plugin and built-in skills.
6. **Confirm the core** — one message: task family, proposed name and location (or where each survivor goes), any scripts or supporting files, and each surviving principle in a line with its evidence. The user knows which parts of the session were the point, and a correction here costs less than a wrong skill. Skip only when the argument settles all of them.
7. **Write** the skill in the shape below.
8. **Cold test** — give a fresh subagent the new skill — and nothing a fresh session wouldn't load anyway — plus a *different* instance of the task family, and ask for its plan. Every session decision the plan misses or contradicts is a gap in the skill; other quibbles are not. Fix the gaps and retest. Run the same instance once without the skill: lines that only drive decisions this control makes anyway fail axiom 1. Without subagents, walk the second instance yourself from the skill text alone.
9. **Install** per the destination's lifecycle; new skills usually register in the next session.

## Shape of the output

When the destination already holds the user's own skills, match their structure and voice. Otherwise:

- **Frontmatter** — `name` equals the directory: the action or outcome, not the session's topic. `description` leads with the key use case, then the situations and phrasings that should trigger it; lean slightly pushy, since agents under-trigger skills (Claude Code truncates it at 1,536 characters — verified 2026-10). `argument-hint` when it takes input. `disable-model-invocation: true` only for side-effecting or user-ritual skills; a captured way of working should usually fire on its own.
- **Body**, each section only when it has content: Objective (the outcome and the bar; a tension as `min(X) subject to Y`) · Ground truth (axiom 8) · Axioms (`**Name** — rule, then why`, with `❌ … · ✅ …` where the session showed the failure) · Procedure (imperative, in the order that worked) · Anti-patterns (`| Anti-pattern | Symptom | Fix |`) · Hard constraints · Done check (axiom 6) · Report.
- **Supporting files** — long reference in a sibling `.md` linked from `SKILL.md`; fragile sequences in `scripts/`, run against the session's own artifacts until they catch what the session caught by hand; examples in `EXAMPLES.md` — the session's case plus a second instance, verified or labeled hypothetical, so they illustrate the class instead of defining it.
- **Location** — the destination's conventions when it has them; otherwise a project skill (`.claude/skills/<name>/`) if the principles depend on one codebase, a personal skill (`~/.claude/skills/<name>/`) if not.

## Anti-patterns

| Anti-pattern | Symptom | Fix |
|---|---|---|
| Transcript replay | "Edit `auth.ts`, then run `pnpm db:push`" | Lift each step to the role it played |
| Platitude skill | "Write clean code", "test thoroughly" | Delete; keep only the delta |
| Victory lap | Narrative of the session, praise of the result | Rules and checks only; the story lives in git |
| Bare imperative | ALWAYS/NEVER with no reason | Add the why, or drop the rule |
| Overfit rule | Holds only under this session's exact conditions | Generalize it, or demote it to an example |
| Lost correction | The user's "no, not like that" is absent from the skill | Restore it as an axiom or anti-pattern |
| Sibling skill | Overlaps a skill that already exists | Amend that skill, or reference it when it isn't the user's |
| Leaked context | Client names, keys, home paths, internal URLs | Replace with roles |
| Vague done | "Done when it works" | The evidence that proved this session done |

## Done check

DONE when a fresh agent holding only the new skill, on a different instance of the task family, makes the decisions that made this session good — the cold test closes with no open gaps — and the no-skill control misses decisions that the skill drives. When no skill was warranted: every survivor sits where the next session will load it.

## Report

Paths written · task family · principles captured, one line each · what was left out and why · cold-test result · how to invoke it and when it becomes available.
