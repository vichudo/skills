# handoff

Compresses the current session into an irreducible handoff document that a fresh
agent can act on immediately.

## Usage

```
/handoff [what the next session will be used for]
```

The optional argument sets the next session's focus: everything irrelevant to it
compresses to a line or a pointer; everything serving it keeps full precision.
The document is written to the OS temporary directory (not the project) and the
path is printed.

## Philosophy

Unlike a conventional session summary, this skill treats the handoff as a
compression problem in the spirit of `max-signal-to-noise`: the next agent's
context window is the scarce resource, so every sentence must change what that
agent does or be deleted. Session state — decisions with their rationale,
discovered constraints, verified vs in-flight vs broken work, ordered next
actions — is extracted as atoms; anything already recorded in an artifact
(commits, diffs, specs, issues) becomes a pointer instead of restated prose.
Secrets are redacted with a note, epistemic status is preserved exactly, and
the document is finished only when no further loss-free deletion exists.
