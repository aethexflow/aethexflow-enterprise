# AethexFlow Enterprise — First Launch (v0.1.5)

**Slogan:** the 1st Real Ai  
**Domain:** aethexflow.online  
**AI:** Grok as Blind Intent Phraser (Aethi)

Production-ready Cloudflare Worker + static hub package.

---

## What you get

| Component | Description |
|-----------|-------------|
| Static hub | `public/` — index, bots, editor, dubbing player, owner panel |
| Chat PWA | `public/chat/` — full offline-capable chat UI |
| Edge Worker | Secure Grok proxy, Aethi intent parser, 6-digit codes |
| D1 schema | Ready migration for users / teams / sessions |
| Deploy scripts | One-click Linux + Windows deploy |
| QA | Automated smoke checks |

No dummy endpoints. All API routes are real.

---

## Quick start (Cloudflare)

```bash
cd aethexflow-enterprise

# 1. Create D1 (once)
npx wrangler d1 create aethexflow-db
# Copy the database_id into wrangler.toml
# Replace: PASTE_YOUR_EXISTING_D1_ID_HERE

# 2. Put Grok key as secret (never in code)
npx wrangler secret put GROK_API_KEY

# 3. Deploy
bash scripts/deploy.sh
# or: npm run deploy
# or Windows: deploy.cmd
```

After deploy:

- Health → `https://<your-worker>.workers.dev/api/health`
- Owner panel → `https://<your-worker>.workers.dev/owner.html`  
  Generate first 6-digit code from there.

---

## Local development

```bash
npm run dev          # wrangler dev (local Worker + assets)
npm run qa           # smoke tests (no network needed)
npm run d1:migrate:local
```

---

## Architecture

```
Browser ──► Cloudflare Worker (workers/index.js)
                │
                ├── /api/health
                ├── /api/auth/code   (generate / validate 6-digit)
                ├── /api/grok        (proxy → api.x.ai, key stays on edge)
                ├── /api/aethi       (blind intent → structured JSON)
                ├── /api/owner       (list recent codes)
                └── ASSETS binding   → public/ (SPA fallback)
```

- **Ephemeral mode**: if D1 is not bound, codes still generate (response only). Perfect for first launch.
- **D1 mode**: codes + users persist. Migration is in `migrations/0001_init.sql`.

---

## API Reference

| Endpoint | Method | Body / Notes | Response |
|----------|--------|--------------|----------|
| `/api/health` | GET | — | `{ ok, service, ts }` |
| `/api/auth/code` | POST | `{ "action": "generate", "role": "user" }` | `{ code, id? }` |
| `/api/auth/code` | POST | `{ "action": "validate", "code": "123456" }` | `{ valid, user? }` |
| `/api/grok` | POST | `{ "messages": [...], "model?", "temperature?", "max_tokens?" }` | Grok chat completion |
| `/api/aethi` | POST | `{ "text": "user message" }` | `{ aethi: { intent, action, payload, reply }, raw }` |
| `/api/owner` | GET | — | `{ mode, users[], message? }` |

All responses include CORS headers for browser use.

---

## Environment & Secrets

| Name | Where | Required |
|------|--------|----------|
| `GROK_API_KEY` | Cloudflare Secret | Yes (for Grok/Aethi) |
| `GROK_MODEL` | `wrangler.toml` [vars] | No (default `grok-4`) |
| `DB` | D1 binding | No (ephemeral fallback works) |

Never commit real keys. Use `.env.example` only as reference.

---

## Project layout

```
aethexflow-enterprise/
├── workers/index.js          # Edge Worker (all API logic)
├── public/                   # Static site + chat PWA
│   ├── index.html
│   ├── owner.html
│   ├── bots.html
│   ├── editor.html
│   ├── dubbing-player.html
│   ├── assets/
│   └── chat/                 # Full PWA
├── migrations/0001_init.sql
├── scripts/
│   ├── deploy.sh
│   ├── qa.sh
│   ├── update_and_pack.py
│   └── launch-windows.bat
├── wrangler.toml
├── package.json
├── .env.example
├── .gitignore
├── CHANGELOG.md
└── LICENSE
```

---

## Update workflow

1. Edit files under `public/` or `workers/index.js`
2. Run `bash scripts/qa.sh`
3. `bash scripts/deploy.sh`
4. (Optional) Rebuild release ZIP: `python scripts/update_and_pack.py`

Nothing is locked. Source is the source of truth.

---

## Security notes

- Grok API key never leaves the Cloudflare edge.
- 6-digit codes are single-use style access tokens (extend with sessions table as needed).
- Owner panel is currently open (protect with Cloudflare Access / basic auth / code gate in production).
- CORS is open (`*`) for first-launch convenience — tighten for production domains.

---

## Brand

- Colors: red `#e8232a` + black
- Font: Rajdhani
- Assets: `public/assets/mark.png`, `logo-wide.png`

---

## License

UNLICENSED — proprietary to AethexFlow. See `LICENSE`.

---

**AethexFlow** — the 1st Real Ai
