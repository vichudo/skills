#!/usr/bin/env bash
# Symlink skills into ~/.claude/skills (or a target passed as an argument) so
# Claude Code picks them up straight from the repo — edits are live, no
# reinstall. Pass --drafts to also link skills/in-progress for testing new
# skills before they graduate. Deprecated skills are never linked.
set -euo pipefail
cd "$(dirname "$0")/.."

drafts=false
target="$HOME/.claude/skills"
for arg in "$@"; do
  case "$arg" in
    --drafts) drafts=true ;;
    *) target="$arg" ;;
  esac
done
mkdir -p "$target"

exclude=( ! -path 'skills/deprecated/*' )
$drafts || exclude+=( ! -path 'skills/in-progress/*' )

find skills -mindepth 2 -maxdepth 2 -type d "${exclude[@]}" |
while read -r dir; do
  [ -f "$dir/SKILL.md" ] || continue
  name="$(basename "$dir")"
  ln -sfn "$(pwd)/$dir" "$target/$name"
  echo "linked $name -> $target/$name"
done
