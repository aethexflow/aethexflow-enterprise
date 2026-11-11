#!/usr/bin/env bash
# One-click Cloudflare deploy for AethexFlow Enterprise
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

echo "=== AethexFlow Enterprise Deploy ==="

# Check wrangler
if ! command -v wrangler &>/dev/null; then
  echo "Installing wrangler…"
  npm install -g wrangler
fi

# Apply migrations if D1 ID is set
if grep -q "PASTE_YOUR_EXISTING_D1_ID_HERE" wrangler.toml; then
  echo "⚠  D1 ID still placeholder. Run:"
  echo "   wrangler d1 create aethexflow-db"
  echo "   then put the ID into wrangler.toml (replace PASTE_YOUR_EXISTING_D1_ID_HERE)"
  echo "Continuing without D1 binding…"
else
  echo "Applying D1 migrations…"
  wrangler d1 migrations apply aethexflow-production --local || true
  wrangler d1 migrations apply aethexflow-production || true
fi

echo "Deploying…"
wrangler deploy

echo ""
echo "✓ Deploy finished."
echo "  Set secret if not done:  wrangler secret put GROK_API_KEY"
echo "  Owner panel:  https://<your-domain>/owner.html"
echo "  Health:       https://<your-domain>/api/health"
