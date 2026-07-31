# phrase-goal

Collapses a pile of intentions, tasks, and parallel workstreams into a single
goal statement that a stranger could grade pass/fail on the deadline.

## Usage

```
/phrase-goal [raw intentions and deadline]
```

Paste the raw material — a week's task list, a quarter's objectives, a vague
goal that needs sharpening. If the deadline is missing, the skill asks for it
before writing, since an unbounded goal is unfalsifiable.

The output is one sentence:

```
By [deadline], [quantified primary outcome as accomplished fact],
[produced with / supported by / coordinated through] [enablers].
```

## Philosophy

A list of objectives is not a goal. The skill forces three collapses:

- **From plan to sentence.** One breath, one goal — the compression is what
  forces prioritization, because only one outcome survives the main clause.
- **From effort to accomplished fact.** The goal is phrased as the retrospective
  answer to "what happened by the deadline?", so "work on X" becomes X's
  finished state with a number attached.
- **From conjunction to system.** Parallel workstreams are not conjuncts; they
  attach to the primary outcome as instruments ("produced with...", "coordinated
  through..."), so the reader perceives one system with a hierarchy rather than
  three competing priorities.

Thresholds are explicit and realistic (70% beats an implicit 100% that will be
silently missed), and every claim must be verifiable by a number or a yes/no.

See the skill's [worked examples](../../skills/productivity/phrase-goal/EXAMPLES.md)
for how raw task lists reduce to a single sentence.
