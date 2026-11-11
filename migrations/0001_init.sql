-- AethexFlow Enterprise — initial schema
CREATE TABLE IF NOT EXISTS users (
  id TEXT PRIMARY KEY,
  code TEXT UNIQUE NOT NULL,
  role TEXT DEFAULT 'user',
  created_at INTEGER NOT NULL,
  last_seen INTEGER
);

CREATE INDEX IF NOT EXISTS idx_users_code ON users(code);

CREATE TABLE IF NOT EXISTS teams (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  owner_id TEXT,
  created_at INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS sessions (
  id TEXT PRIMARY KEY,
  user_id TEXT,
  token_hash TEXT,
  expires_at INTEGER,
  created_at INTEGER
);
