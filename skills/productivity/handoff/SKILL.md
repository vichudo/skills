---
name: handoff
description: 'Compress the current session into an irreducible handoff document a fresh agent can act on — every sentence load-bearing, pointers instead of restated artifacts. Lossless compression of session state, not a conversation summary.'
argument-hint: "What will the next session be used for?"
disable-model-invocation: true
---

# handoff

Write a document letting a zero-context agent continue this work. Its context window is the scarce resource; the objective is `max(signal/noise) * max(clarity) * max(precision)` — a product, so zeroing any factor zeroes the handoff. A sentence earns its place only if deleting it would change what the next agent does (signal), reads cold without decoding (clarity), and carries exact identifiers over descriptions (precision). Compress session *state*, never the conversation.

## Procedure

1. **Extract the atoms** — what the next agent cannot recover on its own: decisions with their why (code shows *what*, never *why not the alternative*); failed approaches and discovered constraints; state as done-and-verified / in-flight / known-broken, never blurred; ordered next actions; unsettled open questions.
2. **Pointers over prose** — anything living in an artifact (code, diffs, commits, specs, issues) is referenced by path, URL, or hash, never restated: restatements bloat and drift, pointers do neither.
3. **Strip narrative** — chronology ("first we discussed") is noise; causality that constrains the future ("X fails because Y") is signal.
4. **Redact** secrets and PII, noting *what* was redacted so the next agent sources it from the environment instead of treating it as missing.
5. **Irreducibility test** — delete every sentence whose removal leaves the next agent acting identically; finished when no loss-free deletion remains, typically well under a page.

## Document

Sections, each only when non-empty: **Goal** (one sentence) · **Now** (imperative, ordered) · **State** (verified / in-flight / broken) · **Decisions & constraints** (each with its why) · **Pointers** (paths, commits, re-verification commands) · **Suggested skills** (what to invoke, for what).

## Hard constraints

- **Faithfulness over brevity** — N independent atoms in the session, N in the handoff; never drop a decision, constraint, or open question for compression.
- **No invention; preserve epistemic status** — in-flight is not done, "tests pass" only if observed, hypotheses stay hypotheses.
- **Cold reader** — no session shorthand or pronouns without referents, definitions before uses, absolute paths and dates, exact identifiers over descriptions of them. Density serves cold-start comprehension: clipped fragments the reader must decode are failure, not concision.
- **Save to the OS temp directory** (not the project) and print the path.
- **Honor the argument** — it sets the next session's focus: irrelevant atoms compress to a line or a pointer, serving atoms keep full precision.
