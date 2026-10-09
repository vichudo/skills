#!/usr/bin/env bash
# Make every skill in this repo available to every agent on this machine:
#
#   pnpm skills      (or: bash scripts/link-skills.sh)
#
# Safe to re-run any time — it converges on the same state:
#   1. fetches origin and fast-forwards the checkout when it is behind
#   2. checks out each open PR from this repo (never forks), detached, under
#      .pr-worktrees/<number>, so skills that exist only on a PR branch stay
#      linked whatever branch you have checked out
#   3. links every skill — published and drafts, never deprecated — into the
#      shared ~/.agents/skills store (the checkout wins over PRs), then points
#      every agent that keeps a skills directory at it — the layout
#      `npx skills add` uses
#   4. removes links this repo left behind (renamed, deleted, merged skills)
#   5. verifies every agent resolves every skill; exits non-zero if not
set -euo pipefail

repo="$(git -C "$(dirname "$0")" worktree list --porcelain | sed -n '1s/^worktree //p')"
cd "$repo"
store="$HOME/.agents/skills"
agents=("$HOME"/.claude "$HOME"/.codex "$HOME"/.cursor "$HOME"/.gemini "$HOME"/.grok)
prs=.pr-worktrees
warn() { echo "warning: $*" >&2; }

# 1. Up to date. A fast-forward never touches uncommitted work: git refuses instead.
if git fetch --quiet --prune origin; then
  if [ "$(git rev-list --count 'HEAD..@{u}' 2>/dev/null || echo 0)" -gt 0 ]; then
    git merge --ff-only --quiet '@{u}' || warn "could not fast-forward $(git branch --show-current); update it by hand"
  fi
else
  warn "fetch failed (offline?): linking what is on disk"
fi

# 2. One detached checkout per open PR from this repo.
git worktree prune
if open=$(gh pr list --state open --limit 100 --json number,headRefName,isCrossRepository \
    -q '.[] | select(.isCrossRepository | not) | "\(.number) \(.headRefName)"' 2>/dev/null); then
  nums=" "
  while read -r n branch; do
    [ -n "$n" ] || continue
    nums="$nums$n "
    wt="$prs/$n"
    if [ ! -e "$wt" ]; then
      git worktree add --quiet --detach "$wt" "origin/$branch" || warn "PR #$n: could not check out origin/$branch"
    elif [ -e "$wt/.git" ]; then
      git -C "$wt" checkout --quiet --detach "origin/$branch" || warn "PR #$n: could not refresh $wt (local changes?)"
    else
      warn "$wt is not a worktree; skipped"
    fi
  done <<< "$open"
  for wt in "$prs"/*; do
    [ -d "$wt" ] || continue
    case "$nums" in
      *" $(basename "$wt") "*) ;;
      *) git worktree remove "$wt" || warn "$wt has local changes; not removed" ;;
    esac
  done
else
  warn "gh unavailable or not logged in: open PRs not refreshed"
fi

# 3. Link: first source to provide a name wins, so the checkout beats PRs.
mkdir -p "$store"
linked=" "
has() { case "$linked" in *" $1 "*) return 0 ;; esac; return 1; }
for src in . "$prs"/*; do
  [ -d "$src/skills" ] || continue
  from=checkout; [ "$src" = . ] || from="PR #$(basename "$src")"
  for dir in "$src"/skills/*/*/; do
    dir="${dir%/}"; name="$(basename "$dir")"
    [ -f "$dir/SKILL.md" ] || continue
    case "$dir" in */skills/deprecated/*) continue ;; esac
    has "$name" && continue
    if [ -e "$store/$name" ] && [ ! -L "$store/$name" ]; then
      warn "$store/$name is an installed copy, not a link; left as is"; continue
    fi
    ln -sfn "$repo/${dir#./}" "$store/$name"
    linked="$linked$name "
    printf '  %-20s %s\n' "$name" "$from"
  done
done
for a in "${agents[@]}"; do
  [ -d "$a/skills" ] || continue
  for name in $linked; do
    if [ -e "$a/skills/$name" ] && [ ! -L "$a/skills/$name" ]; then
      warn "$a/skills/$name is not a link; left as is"; continue
    fi
    ln -sfn "../../.agents/skills/$name" "$a/skills/$name"
  done
done

# 4. Prune links into this repo that no longer name a skill, and agent links
#    whose store entry is gone. Only symlinks are ever removed.
for l in "$store"/*; do
  [ -L "$l" ] || continue
  case "$(readlink "$l")" in "$repo"/*) has "$(basename "$l")" || { rm "$l"; echo "  removed stale $(basename "$l")"; } ;; esac
done
for a in "${agents[@]}"; do
  for l in "$a"/skills/*; do
    [ -L "$l" ] || continue
    case "$(readlink "$l")" in
      "$repo"/*) has "$(basename "$l")" || rm "$l" ;;
      ../../.agents/skills/*) [ -e "$l" ] || rm "$l" ;;
    esac
  done
done
if [ -d "$HOME/.codex/vendor_imports/skills/skills/.curated" ]; then
  for name in $linked; do
    if [ -e "$HOME/.codex/vendor_imports/skills/skills/.curated/$name" ]; then
      warn "$name collides with a skill Codex vendors; Codex will load only one"
    fi
  done
fi

# 5. Verify.
fail=0 ready=""
for a in "$HOME/.agents" "${agents[@]}"; do
  [ -d "$a/skills" ] || continue
  ready="$ready ${a#"$HOME"/}"
  for name in $linked; do
    [ -f "$a/skills/$name/SKILL.md" ] || { warn "$a/skills/$name does not resolve"; fail=1; }
  done
done
echo "$(echo $linked | wc -w | tr -d ' ') skills ready in:$ready"
exit "$fail"
