#!/usr/bin/env bash
# List every skill in the repo (any directory under skills/ containing a SKILL.md).
set -euo pipefail
cd "$(dirname "$0")/.."

find skills -name SKILL.md -type f | sort | while read -r file; do
  dirname "$file"
done
