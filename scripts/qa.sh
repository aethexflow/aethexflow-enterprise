#!/usr/bin/env bash
# Automated smoke QA for AethexFlow Enterprise
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

PASS=0
FAIL=0

check() {
  local name="$1"
  local cmd="$2"
  if eval "$cmd" >/dev/null 2>&1; then
    echo "  ✓ $name"
    PASS=$((PASS+1))
  else
    echo "  ✗ $name"
    FAIL=$((FAIL+1))
  fi
}

echo "=== AethexFlow QA ==="

check "public/index.html exists" "test -f public/index.html"
check "public/owner.html exists" "test -f public/owner.html"
check "public/chat/index.html exists" "test -f public/chat/index.html"
check "workers/index.js exists" "test -f workers/index.js"
check "wrangler.toml exists" "test -f wrangler.toml"
check "migration exists" "test -f migrations/0001_init.sql"
check "style.css has red brand" "grep -q '#e8232a' public/assets/style.css"
check "Grok proxy present" "grep -q 'api.x.ai' workers/index.js"
check "Aethi intent present" "grep -q 'blind intent' workers/index.js"
check "6-digit code logic" "grep -q 'generateCode' workers/index.js"

echo ""
echo "Result: $PASS passed, $FAIL failed"
if [ "$FAIL" -gt 0 ]; then
  exit 1
fi
echo "All critical checks passed."
