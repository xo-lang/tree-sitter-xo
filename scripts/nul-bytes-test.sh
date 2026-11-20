#!/bin/bash
# nul-bytes-test.sh: raw NUL bytes inside b"..." parse as bytes_content (the external scanner's _bytes_nul token;
# the internal lexer reads a lookahead of 0 as the end of input). The corpus cannot hold the raw bytes without git
# treating it as binary, so this writes them at test time. Needs `npm install` first (tree-sitter-cli).
set -euo pipefail
here=$(cd "$(dirname "$0")/.." && pwd)
f=$(mktemp -t nul-bytes.XXXXXX)
trap 'rm -f "$f" "$f.xo"' EXIT
printf 'fn f() {\n  b.write(b"\0\0\0")\n  b.write(b"a\0b")\n}\n' > "$f.xo"
cd "$here"
out=$(node_modules/.bin/tree-sitter parse "$f.xo" 2>&1 || true)
if echo "$out" | grep -qE 'ERROR|MISSING'; then
	echo "FAIL raw NUL bytes in a bytes literal:"; echo "$out"; exit 1
fi
n=$(echo "$out" | grep -c 'bytes_content' || true)
[ "$n" -ge 3 ] || { echo "FAIL raw NUL bytes: want 3 or more bytes_content nodes, got $n"; echo "$out"; exit 1; }
echo "ok raw NUL bytes in a bytes literal"
