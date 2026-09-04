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
[[condition the goal assumes],] By [deadline],
[quantified primary outcome as accomplished fact],
[produced with / supported by / coordinated through] [enablers].
```

The leading condition appears only when an outside party's action is
load-bearing; nothing else may precede the deadline.

## Philosophy

A list of objectives is not a goal. The skill forces four collapses:

- **From plan to sentence.** One breath, one goal — the compression is what
  forces prioritization, because only one outcome survives the main clause.
- **From effort to accomplished fact.** The goal is phrased as the retrospective
  answer to "what happened by the deadline?", so "work on X" becomes X's
  finished state with a number attached.
- **From conjunction to system.** Parallel workstreams are not conjuncts; they
  attach to the primary outcome as instruments ("produced with...", "coordinated
  through..."), so the reader perceives one system with a hierarchy rather than
  three competing priorities.
- **From dependent to controllable.** The outcome must be one our own actions
  produce. If the verdict belongs to someone else — a client signs, users
  convert, a reviewer approves — the goal moves downstream to the furthest thing
  we deliver ("the signed-ready contract is delivered and defended in the
  buyer's review", not "the contract is signed"), and the dependent metric stays
  a result to track. When the dependency is load-bearing and cannot be designed
  away, it is neither dropped nor chased: it becomes the condition the goal
  assumes ("Once the partner ships API v2 on October 15, by October 31 the
  integration is live for every customer..."), so the main clause stays on our
  side of it. The wording is free — "Given...", "Once...", "With..." — the
  position is not. "Follow up weekly until they sign" never enters the sentence:
  it makes diligence look like success. A stated condition also fails usefully —
  when it breaks, the goal is restated rather than silently missed.

Thresholds are explicit and realistic (70% beats an implicit 100% that will be
silently missed), and every claim must be verifiable by a number or a yes/no —
on the deadline, with the stated condition held and nothing else going our way.

See the skill's [worked examples](../../skills/personal/phrase-goal/EXAMPLES.md)
for how raw task lists reduce to a single sentence.
