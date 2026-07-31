#!/usr/bin/env bash
# Symlink skills into ~/.claude/skills (or a target passed as an argument) so
# Claude Code picks them up straight from the repo — edits are live, no
# reinstall. Deprecated skills are never linked.
#
#   --drafts   also link skills/in-progress, for testing new skills before they
#              graduate to a category
#   --agents   link into the shared ~/.agents/skills store instead, then point
#              every agent installed on this machine (Claude Code, Codex,
#              Cursor, Gemini) at it — the layout `npx skills add` uses
set -euo pipefail
cd "$(dirname "$0")/.."

drafts=false
agents=false
target="$HOME/.claude/skills"
for arg in "$@"; do
  case "$arg" in
    --drafts) drafts=true ;;
    --agents) agents=true; target="$HOME/.agents/skills" ;;
    *) target="$arg" ;;
  esac
done
mkdir -p "$target"

exclude=( ! -path 'skills/deprecated/*' )
$drafts || exclude+=( ! -path 'skills/in-progress/*' )

names=()
while read -r dir; do
  [ -f "$dir/SKILL.md" ] || continue
  name="$(basename "$dir")"
  names+=( "$name" )
  ln -sfn "$(pwd)/$dir" "$target/$name"
  echo "linked $name -> $target/$name"
done < <(find skills -mindepth 2 -maxdepth 2 -type d "${exclude[@]}")

$agents || exit 0

# Fan the shared store out to every agent that already keeps a skills directory.
for agent_dir in "$HOME"/.claude "$HOME"/.codex "$HOME"/.cursor "$HOME"/.gemini; do
  [ -d "$agent_dir/skills" ] || continue
  for name in "${names[@]}"; do
    ln -sfn "../../.agents/skills/$name" "$agent_dir/skills/$name"
  done
  echo "pointed $(basename "$agent_dir") at ${#names[@]} shared skills"
done
