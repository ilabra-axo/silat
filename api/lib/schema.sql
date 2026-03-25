-- silat ar rahim — Neon Postgres schema
-- Append-only CQRS: events table is the source of truth.
-- members + relationships are read-model projections.
-- Multi-tenancy: tree_id = user_id (each user owns one tree, v1).

-- ---------------------------------------------------------------------------
-- Users (ABW identity)
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS users (
  id           TEXT PRIMARY KEY,          -- ABW user_id, e.g. "google_abc123"
  email        TEXT,
  display_name TEXT,
  created_at   TIMESTAMPTZ DEFAULT NOW()
);

-- ---------------------------------------------------------------------------
-- Event log (append-only, never UPDATE or DELETE)
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS events (
  id           TEXT PRIMARY KEY,
  stream_id    TEXT NOT NULL,             -- member.id or relationship.id
  stream_type  TEXT NOT NULL,             -- 'member' | 'relationship'
  event_type   TEXT NOT NULL,             -- 'MemberAdded' | 'MemberUpdated' | ...
  payload_json JSONB NOT NULL,
  actor_id     TEXT NOT NULL,             -- ABW user_id (no FK — ABW is external)
  tree_id      TEXT NOT NULL,
  occurred_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_events_stream   ON events(stream_id);
CREATE INDEX IF NOT EXISTS idx_events_tree     ON events(tree_id);
CREATE INDEX IF NOT EXISTS idx_events_occurred ON events(occurred_at DESC);

-- ---------------------------------------------------------------------------
-- Members read model (projected from event log)
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS members (
  id                   TEXT PRIMARY KEY,
  first_name           TEXT NOT NULL,
  last_name            TEXT,
  birth_date           TIMESTAMPTZ,
  death_date           TIMESTAMPTZ,
  gender               TEXT DEFAULT '',
  location_label       TEXT,
  latitude             DOUBLE PRECISION,
  longitude            DOUBLE PRECISION,
  residence_h3         TEXT,
  birth_location_label TEXT,
  birth_latitude       DOUBLE PRECISION,
  birth_longitude      DOUBLE PRECISION,
  birth_h3             TEXT,
  notes                TEXT,
  photo_url            TEXT,
  phone                TEXT,
  whatsapp             TEXT,
  is_urgent            BOOLEAN DEFAULT false,
  claim_state          TEXT DEFAULT 'seeded',
  owner_user_id        TEXT,
  claim_token          TEXT,
  stewardship_state    TEXT DEFAULT 'none',
  steward_user_id      TEXT,
  steward_claim_token  TEXT,
  created_at           TIMESTAMPTZ NOT NULL,
  updated_at           TIMESTAMPTZ NOT NULL,
  tree_id              TEXT NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_members_name ON members(last_name, first_name);
CREATE INDEX IF NOT EXISTS idx_members_tree ON members(tree_id);

-- ---------------------------------------------------------------------------
-- Relationships read model
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS relationships (
  id                TEXT PRIMARY KEY,
  source_id         TEXT,
  target_id         TEXT,
  rel_type          TEXT,
  last_contact_at   TIMESTAMPTZ,
  rel_notes         TEXT,
  salience          DOUBLE PRECISION DEFAULT 0.5,
  intervention_mode TEXT DEFAULT 'passive',
  created_at        TIMESTAMPTZ NOT NULL,
  tree_id           TEXT NOT NULL,
  UNIQUE(source_id, target_id, rel_type)
);

CREATE INDEX IF NOT EXISTS idx_rel_source ON relationships(source_id);
CREATE INDEX IF NOT EXISTS idx_rel_target ON relationships(target_id);
CREATE INDEX IF NOT EXISTS idx_rel_tree   ON relationships(tree_id);

-- ---------------------------------------------------------------------------
-- Life events read model
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS life_events (
  id          TEXT PRIMARY KEY,
  member_id   TEXT,
  event_type  TEXT,
  occurred_at TIMESTAMPTZ,
  notes       TEXT,
  created_at  TIMESTAMPTZ,
  tree_id     TEXT NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_life_events_member ON life_events(member_id);
CREATE INDEX IF NOT EXISTS idx_life_events_tree   ON life_events(tree_id);
