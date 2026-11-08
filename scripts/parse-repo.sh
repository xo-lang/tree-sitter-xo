#!/bin/bash
# parse-repo.sh XO_REPO: parses every .xo file of an Xo checkout with this grammar and prints the totals and the files
# with ERROR or MISSING nodes. Excluded because they are invalid on purpose: test/errorcheck (diagnostic tests) and
# testdata/habits (other languages' syntax). Needs `npm install` first (tree-sitter-cli).
set -euo pipefail
repo=${1:?usage: parse-repo.sh XO_REPO}
here=$(cd "$(dirname "$0")/.." && pwd)
list=$(mktemp)
trap 'rm -f "$list"' EXIT
find "$repo" -type f -name '*.xo' -not -path '*/node_modules/*' -not -path '*/test/errorcheck/*' -not -path '*/testdata/habits/*' > "$list"
cd "$here"
node_modules/.bin/tree-sitter parse --quiet --stat --paths "$list" 2>&1 | grep -E 'Total parses|\((ERROR|MISSING)' || true
