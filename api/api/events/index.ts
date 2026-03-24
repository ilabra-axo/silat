// POST /api/events — receive batched events from client, project onto read model
// This is the sync endpoint: client pushes unsynced local events here.

import { VercelRequest, VercelResponse } from "@vercel/node";
import { sql } from "@vercel/postgres";
import { cors, requireAuth } from "../../lib/auth";

interface ClientEvent {
  id: string;
  stream_id: string;
  stream_type: "member" | "relationship";
  event_type: string;
  payload: Record<string, unknown>;
  actor_id: string;
  occurred_at: string;
}

export default async function handler(
  req: VercelRequest,
  res: VercelResponse,
) {
  cors(res);
  if (req.method === "OPTIONS") return res.status(200).end();
  if (req.method !== "POST") return res.status(405).json({ error: "POST only" });

  const user = await requireAuth(req, res);
  if (!user) return;

  const { events } = req.body as { events: ClientEvent[] };

  if (!Array.isArray(events) || events.length === 0) {
    return res.status(400).json({ error: "events array required" });
  }

  const applied: string[] = [];
  const failed: { id: string; error: string }[] = [];

  for (const event of events) {
    try {
      // Append to event log (idempotent via ON CONFLICT DO NOTHING)
      await sql`
        INSERT INTO events (id, stream_id, stream_type, event_type, payload_json, actor_id, occurred_at)
        VALUES (
          ${event.id},
          ${event.stream_id},
          ${event.stream_type},
          ${event.event_type},
          ${JSON.stringify(event.payload)},
          ${user.id},
          ${event.occurred_at}
        )
        ON CONFLICT (id) DO NOTHING
      `;

      // Project onto read model
      await project(event);
      applied.push(event.id);
    } catch (err: unknown) {
      const msg = err instanceof Error ? err.message : String(err);
      console.error("[events] failed to apply", event.id, msg);
      failed.push({ id: event.id, error: msg });
    }
  }

  return res.status(200).json({ applied, failed });
}

async function project(event: ClientEvent): Promise<void> {
  const p = event.payload as Record<string, unknown>;

  switch (event.event_type) {
    case "MemberAdded":
    case "MemberUpdated": {
      await sql`
        INSERT INTO members (
          id, first_name, last_name, birth_year, death_year,
          gender, location_label, latitude, longitude,
          notes, photo_url, created_at, updated_at
        )
        VALUES (
          ${p.id as string},
          ${p.first_name as string},
          ${(p.last_name as string) ?? null},
          ${(p.birth_year as number) ?? null},
          ${(p.death_year as number) ?? null},
          ${(p.gender as string) ?? ""},
          ${(p.location_label as string) ?? null},
          ${(p.latitude as number) ?? null},
          ${(p.longitude as number) ?? null},
          ${(p.notes as string) ?? null},
          ${(p.photo_url as string) ?? null},
          ${(p.created_at as string) ?? new Date().toISOString()},
          ${(p.updated_at as string) ?? new Date().toISOString()}
        )
        ON CONFLICT (id) DO UPDATE SET
          first_name     = EXCLUDED.first_name,
          last_name      = EXCLUDED.last_name,
          birth_year     = EXCLUDED.birth_year,
          death_year     = EXCLUDED.death_year,
          gender         = EXCLUDED.gender,
          location_label = EXCLUDED.location_label,
          latitude       = EXCLUDED.latitude,
          longitude      = EXCLUDED.longitude,
          notes          = EXCLUDED.notes,
          photo_url      = EXCLUDED.photo_url,
          updated_at     = EXCLUDED.updated_at
      `;
      break;
    }

    case "MemberDeleted": {
      await sql`DELETE FROM members WHERE id = ${p.id as string}`;
      break;
    }

    case "RelationshipCreated": {
      await sql`
        INSERT INTO relationships (id, source_id, target_id, rel_type, created_at)
        VALUES (
          ${p.id as string},
          ${p.source_id as string},
          ${p.target_id as string},
          ${p.rel_type as string},
          ${(p.created_at as string) ?? new Date().toISOString()}
        )
        ON CONFLICT (source_id, target_id, rel_type) DO NOTHING
      `;
      break;
    }

    case "RelationshipDeleted": {
      await sql`DELETE FROM relationships WHERE id = ${p.id as string}`;
      break;
    }

    default:
      console.warn("[events] unknown event type:", event.event_type);
  }
}
