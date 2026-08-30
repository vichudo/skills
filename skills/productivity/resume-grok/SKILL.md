---
name: resume-grok
description: >
  Resume or continue work from a recent Grok (Grok Build / grok CLI) session.
  Use when the user switched from Grok, says "continue from Grok" or "resume my
  Grok session", or names a Grok session by description, path, or native ID.
  Distinct from Grok's builtin /resume, which reloads a Grok session in place.
metadata:
  short-description: "Continue from a recent Grok session"
argument-hint: "[words describing the session | session id]"
---

Set `TOOL=grok`. Set
`SHARED_DIR="${SKILL_DIR}/../resume-session"`. Read and follow
`${SHARED_DIR}/CORE.md`, using `$ARGUMENTS` unchanged as the optional session
reference.
