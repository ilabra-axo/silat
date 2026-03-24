-- silat ar rahim — Neon Postgres schema
-- Append-only CQRS: events table is the source of truth.
-- members + relationships are read-model projections.

-- ---------------------------------------------------------------------------
-- Users (auth)
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS users (
  id          TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
  email       TEXT UNIQUE NOT NULL,
  name        TEXT,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);

-- ---------------------------------------------------------------------------
-- Event log (append-only, never UPDATE or DELETE)
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS events (
  id           TEXT PRIMARY KEY,
  stream_id    TEXT NOT NULL,          -- member.id or relationship.id
  stream_type  TEXT NOT NULL,          -- 'member' | 'relationship'
  event_type   TEXT NOT NULL,          -- 'MemberAdded' | 'MemberUpdated' | ...
  payload_json JSONB NOT NULL,
  actor_id     TEXT NOT NULL REFERENCES users(id),
  occurred_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_events_stream    ON events(stream_id, occurred_at);
CREATE INDEX IF NOT EXISTS idx_events_type      ON events(event_type);
CREATE INDEX IF NOT EXISTS idx_events_actor     ON events(actor_id);
CREATE INDEX IF NOT EXISTS idx_events_occurred  ON events(occurred_at DESC);

-- ---------------------------------------------------------------------------
-- Members read model (projected from event log)
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS members (
  id              TEXT PRIMARY KEY,
  first_name      TEXT NOT NULL,
  last_name       TEXT,
  birth_year      INTEGER,
  death_year      INTEGER,
  gender          TEXT DEFAULT '',
  location_label  TEXT,
  latitude        DOUBLE PRECISION,
  longitude       DOUBLE PRECISION,
  notes           TEXT,
  photo_url       TEXT,
  created_at      TIMESTAMPTZ NOT NULL,
  updated_at      TIMESTAMPTZ NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_members_name ON members(last_name, first_name);

-- ---------------------------------------------------------------------------
-- Relationships read model
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS relationships (
  id          TEXT PRIMARY KEY,
  source_id   TEXT NOT NULL REFERENCES members(id) ON DELETE CASCADE,
  target_id   TEXT NOT NULL REFERENCES members(id) ON DELETE CASCADE,
  rel_type    TEXT NOT NULL,           -- 'parent-child' | 'partner'
  created_at  TIMESTAMPTZ NOT NULL,
  UNIQUE(source_id, target_id, rel_type)
);

CREATE INDEX IF NOT EXISTS idx_rel_source ON relationships(source_id);
CREATE INDEX IF NOT EXISTS idx_rel_target ON relationships(target_id);
