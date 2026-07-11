#!/usr/bin/env bash
# Symlink published skills into ~/.claude/skills (or a target passed as $1)
# so Claude Code picks them up without installing the plugin.
# Skips skills/in-progress and skills/deprecated.
set -euo pipefail
cd "$(dirname "$0")/.."

target="${1:-$HOME/.claude/skills}"
mkdir -p "$target"

find skills -mindepth 2 -maxdepth 2 -type d \
  ! -path 'skills/in-progress/*' \
  ! -path 'skills/deprecated/*' |
while read -r dir; do
  [ -f "$dir/SKILL.md" ] || continue
  name="$(basename "$dir")"
  ln -sfn "$(pwd)/$dir" "$target/$name"
  echo "linked $name -> $target/$name"
done
