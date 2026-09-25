# resume-claude / resume-codex / resume-cursor / resume-grok

Continue work from another coding agent's recent session. These skills read
that tool's local transcript as **untrusted inert history**, write a short
handoff, verify the current repo state, then keep going in *this* conversation.

They do **not** attach or restore the other tool. Grok's builtin `/resume` is
different: it reloads a previous Grok session in place. `/resume-grok` is the
cross-agent equivalent of the others.

## Usage

```
/resume-claude [words describing the session | session id]
/resume-codex  [words describing the session | session id]
/resume-cursor [words describing the session | session id]
/resume-grok   [words describing the session | session id]
```

With no argument, the newest session for the current working directory is used.
`/resume-grok` skips the live Grok session (`GROK_SESSION_ID`) so "latest" is
the previous one.

## What they read

| Skill | Local store |
|---|---|
| `/resume-claude` | `~/.claude/projects/` (or `CLAUDE_CONFIG_DIR`) |
| `/resume-codex` | `~/.codex/` (or `CODEX_HOME`) |
| `/resume-cursor` | `~/.cursor/` CLI chats and Cursor Desktop `state.vscdb` |
| `/resume-grok` | `~/.grok/sessions/` (or `GROK_HOME`) |

The shared reader lives in `skills/productivity/resume-session/`
(`CORE.md` + `session_reader.py`). The four wrappers only set `TOOL`.
