// GET /api/members — fetch all members + relationships for the user's trees
// POST /api/members — create a member in the user's primary tree

import { VercelRequest, VercelResponse } from "@vercel/node";
import { sql } from "@vercel/postgres";
import { cors, requireAuth, getUserTrees, getPrimaryTree } from "../../lib/auth";

export default async function handler(
  req: VercelRequest,
  res: VercelResponse,
) {
  cors(res);
  if (req.method === "OPTIONS") return res.status(200).end();

  const user = await requireAuth(req, res);
  if (!user) return;

  if (req.method === "GET") {
    const trees = await getUserTrees(user.id);

    const [membersResult, relsResult] = await Promise.all([
      sql.query(
        `SELECT * FROM members WHERE tree_id = ANY($1::text[]) ORDER BY last_name, first_name`,
        [trees],
      ),
      sql.query(
        `SELECT * FROM relationships WHERE tree_id = ANY($1::text[]) ORDER BY created_at`,
        [trees],
      ),
    ]);

    return res.status(200).json({
      members: membersResult.rows,
      relationships: relsResult.rows,
    });
  }

  if (req.method === "POST") {
    const b = req.body as Record<string, unknown>;
    const tree_id = await getPrimaryTree(user.id);
    const now = new Date().toISOString();

    const id = b.id as string;
    if (!id || !(b.first_name as string)) {
      return res.status(400).json({ error: "id and first_name required" });
    }

    await sql`
      INSERT INTO members (
        id, first_name, last_name, birth_date, death_date, gender,
        location_label, latitude, longitude, residence_h3,
        birth_location_label, birth_latitude, birth_longitude, birth_h3,
        notes, photo_url, phone, whatsapp, is_urgent,
        claim_state, owner_user_id, claim_token,
        stewardship_state, steward_user_id, steward_claim_token,
        created_at, updated_at, tree_id
      ) VALUES (
        ${id},
        ${b.first_name as string},
        ${(b.last_name as string) ?? null},
        ${(b.birth_date as string) ?? null},
        ${(b.death_date as string) ?? null},
        ${(b.gender as string) ?? ''},
        ${(b.location_label as string) ?? null},
        ${(b.latitude as number) ?? null},
        ${(b.longitude as number) ?? null},
        ${(b.residence_h3 as string) ?? null},
        ${(b.birth_location_label as string) ?? null},
        ${(b.birth_latitude as number) ?? null},
        ${(b.birth_longitude as number) ?? null},
        ${(b.birth_h3 as string) ?? null},
        ${(b.notes as string) ?? null},
        ${(b.photo_url as string) ?? null},
        ${(b.phone as string) ?? null},
        ${(b.whatsapp as string) ?? null},
        ${(b.is_urgent as boolean) ?? false},
        ${(b.claim_state as string) ?? 'seeded'},
        ${(b.owner_user_id as string) ?? null},
        ${(b.claim_token as string) ?? null},
        ${(b.stewardship_state as string) ?? 'none'},
        ${(b.steward_user_id as string) ?? null},
        ${(b.steward_claim_token as string) ?? null},
        ${(b.created_at as string) ?? now},
        ${now},
        ${tree_id}
      )
      ON CONFLICT (id) DO NOTHING
    `;

    const { rows } = await sql`SELECT * FROM members WHERE id = ${id}`;
    return res.status(200).json(rows[0]);
  }

  return res.status(405).json({ error: "Method not allowed" });
}
