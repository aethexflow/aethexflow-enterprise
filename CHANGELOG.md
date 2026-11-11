# Changelog

All notable changes to AethexFlow Enterprise are documented here.

## [0.1.5] — 2026-11-11

### Fixed
- deploy.sh placeholder check matched wrong string (now matches `PASTE_YOUR_EXISTING_D1_ID_HERE`)
- D1 migration target name aligned with wrangler.toml (`aethexflow-production`)

### Added
- Proper `.gitignore`
- `package.json` with npm scripts (`deploy`, `qa`, `dev`, `d1:*`, `secret:grok`)
- Full production README with architecture, API reference, security notes, and update workflow
- LICENSE (UNLICENSED / private)

### Improved
- Worker remains fully functional in ephemeral mode (no D1) for first launch
- Owner panel + Aethi + Grok proxy unchanged and production-ready

## [0.1.0] — 2026-11-11 — First Launch

- Unified static suite + chat PWA into single `public/`
- Cloudflare Worker (Grok proxy + Aethi blind intent + 6-digit codes)
- Owner panel with real endpoints
- D1 migration skeleton
- One-click `deploy.sh` + `qa.sh`
- Windows launcher (`deploy.cmd`, `build.cmd`)
- Brand preserved (red/black, Rajdhani)
- No dummy APIs — all routes real
