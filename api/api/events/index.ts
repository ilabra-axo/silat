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

  const tree_id = user.id;

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
        INSERT INTO events (id, stream_id, stream_type, event_type, payload_json, actor_id, tree_id, occurred_at)
        VALUES (
          ${event.id},
          ${event.stream_id},
          ${event.stream_type},
          ${event.event_type},
          ${JSON.stringify(event.payload)},
          ${user.id},
          ${tree_id},
          ${event.occurred_at}
        )
        ON CONFLICT (id) DO NOTHING
      `;

      // Project onto read model
      await project(event, tree_id);
      applied.push(event.id);
    } catch (err: unknown) {
      const msg = err instanceof Error ? err.message : String(err);
      console.error("[events] failed to apply", event.id, msg);
      failed.push({ id: event.id, error: msg });
    }
  }

  return res.status(200).json({ applied, failed });
}

async function project(event: ClientEvent, tree_id: string): Promise<void> {
  const p = event.payload as Record<string, unknown>;

  switch (event.event_type) {
    case "MemberAdded":
    case "MemberUpdated": {
      await sql`
        INSERT INTO members (
          id, first_name, last_name, birth_date, death_date,
          gender, location_label, latitude, longitude, residence_h3,
          birth_location_label, birth_latitude, birth_longitude, birth_h3,
          notes, photo_url, phone, whatsapp, is_urgent,
          claim_state, owner_user_id, claim_token,
          stewardship_state, steward_user_id, steward_claim_token,
          created_at, updated_at, tree_id
        )
        VALUES (
          ${p.id as string},
          ${p.first_name as string},
          ${(p.last_name as string) ?? null},
          ${(p.birth_date as string) ?? null},
          ${(p.death_date as string) ?? null},
          ${(p.gender as string) ?? ""},
          ${(p.location_label as string) ?? null},
          ${(p.latitude as number) ?? null},
          ${(p.longitude as number) ?? null},
          ${(p.residence_h3 as string) ?? null},
          ${(p.birth_location_label as string) ?? null},
          ${(p.birth_latitude as number) ?? null},
          ${(p.birth_longitude as number) ?? null},
          ${(p.birth_h3 as string) ?? null},
          ${(p.notes as string) ?? null},
          ${(p.photo_url as string) ?? null},
          ${(p.phone as string) ?? null},
          ${(p.whatsapp as string) ?? null},
          ${(p.is_urgent as boolean) ?? false},
          ${(p.claim_state as string) ?? "seeded"},
          ${(p.owner_user_id as string) ?? null},
          ${(p.claim_token as string) ?? null},
          ${(p.stewardship_state as string) ?? "none"},
          ${(p.steward_user_id as string) ?? null},
          ${(p.steward_claim_token as string) ?? null},
          ${(p.created_at as string) ?? new Date().toISOString()},
          ${(p.updated_at as string) ?? new Date().toISOString()},
          ${tree_id}
        )
        ON CONFLICT (id) DO UPDATE SET
          first_name           = EXCLUDED.first_name,
          last_name            = EXCLUDED.last_name,
          birth_date           = EXCLUDED.birth_date,
          death_date           = EXCLUDED.death_date,
          gender               = EXCLUDED.gender,
          location_label       = EXCLUDED.location_label,
          latitude             = EXCLUDED.latitude,
          longitude            = EXCLUDED.longitude,
          residence_h3         = EXCLUDED.residence_h3,
          birth_location_label = EXCLUDED.birth_location_label,
          birth_latitude       = EXCLUDED.birth_latitude,
          birth_longitude      = EXCLUDED.birth_longitude,
          birth_h3             = EXCLUDED.birth_h3,
          notes                = EXCLUDED.notes,
          photo_url            = EXCLUDED.photo_url,
          phone                = EXCLUDED.phone,
          whatsapp             = EXCLUDED.whatsapp,
          is_urgent            = EXCLUDED.is_urgent,
          claim_state          = EXCLUDED.claim_state,
          owner_user_id        = EXCLUDED.owner_user_id,
          claim_token          = EXCLUDED.claim_token,
          stewardship_state    = EXCLUDED.stewardship_state,
          steward_user_id      = EXCLUDED.steward_user_id,
          steward_claim_token  = EXCLUDED.steward_claim_token,
          updated_at           = EXCLUDED.updated_at
      `;
      break;
    }

    case "MemberDeleted": {
      await sql`DELETE FROM members WHERE id = ${p.id as string} AND tree_id = ${tree_id}`;
      break;
    }

    case "RelationshipCreated": {
      await sql`
        INSERT INTO relationships (
          id, source_id, target_id, rel_type,
          last_contact_at, rel_notes, salience, intervention_mode,
          created_at, tree_id
        )
        VALUES (
          ${p.id as string},
          ${p.source_id as string},
          ${p.target_id as string},
          ${p.rel_type as string},
          ${(p.last_contact_at as string) ?? null},
          ${(p.notes as string) ?? null},
          ${(p.salience as number) ?? 0.5},
          ${(p.intervention_mode as string) ?? "passive"},
          ${(p.created_at as string) ?? new Date().toISOString()},
          ${tree_id}
        )
        ON CONFLICT (source_id, target_id, rel_type) DO UPDATE SET
          last_contact_at   = EXCLUDED.last_contact_at,
          rel_notes         = EXCLUDED.rel_notes,
          salience          = EXCLUDED.salience,
          intervention_mode = EXCLUDED.intervention_mode
      `;
      break;
    }

    case "RelationshipDeleted": {
      await sql`DELETE FROM relationships WHERE id = ${p.id as string} AND tree_id = ${tree_id}`;
      break;
    }

    case "ClaimInviteSent": {
      await sql`
        UPDATE members
        SET claim_state = 'claim_pending', claim_token = ${p.token as string}
        WHERE id = ${p.id as string} AND tree_id = ${tree_id}
      `;
      break;
    }

    case "ProfileClaimed": {
      await sql`
        UPDATE members
        SET claim_state = 'claimed', owner_user_id = ${p.claimed_by as string}, claim_token = NULL
        WHERE id = ${p.id as string} AND tree_id = ${tree_id}
      `;
      break;
    }

    case "ClaimRevoked": {
      await sql`
        UPDATE members
        SET claim_state = 'seeded', claim_token = NULL
        WHERE id = ${p.id as string} AND tree_id = ${tree_id}
      `;
      break;
    }

    case "StewardshipInviteSent": {
      await sql`
        UPDATE members
        SET stewardship_state = 'pending', steward_claim_token = ${p.steward_token as string}
        WHERE id = ${p.id as string} AND tree_id = ${tree_id}
      `;
      break;
    }

    case "StewardshipClaimed": {
      await sql`
        UPDATE members
        SET stewardship_state = 'active',
            steward_user_id = ${p.steward_user_id as string},
            steward_claim_token = NULL
        WHERE id = ${p.id as string} AND tree_id = ${tree_id}
      `;
      break;
    }

    case "StewardshipRevoked": {
      await sql`
        UPDATE members
        SET stewardship_state = 'none', steward_user_id = NULL, steward_claim_token = NULL
        WHERE id = ${p.id as string} AND tree_id = ${tree_id}
      `;
      break;
    }

    default:
      console.warn("[events] unknown event type:", event.event_type);
  }
}
