// PUT /api/members/:id — update a member
// DELETE /api/members/:id — delete a member + their relationships

import { VercelRequest, VercelResponse } from "@vercel/node";
import { sql } from "@vercel/postgres";
import { cors, requireAuth, getUserTrees } from "../../lib/auth";

export default async function handler(
  req: VercelRequest,
  res: VercelResponse,
) {
  cors(res);
  if (req.method === "OPTIONS") return res.status(200).end();

  const user = await requireAuth(req, res);
  if (!user) return;

  const { id } = req.query as { id: string };
  const trees = await getUserTrees(user.id);

  // Verify member belongs to a tree the user can access
  const { rows: check } = await sql.query(
    `SELECT id FROM members WHERE id = $1 AND tree_id = ANY($2::text[])`,
    [id, trees],
  );
  if (!check.length) {
    return res.status(404).json({ error: "Member not found" });
  }

  if (req.method === "PUT") {
    const b = req.body as Record<string, unknown>;
    const now = new Date().toISOString();

    await sql`
      UPDATE members SET
        first_name           = COALESCE(${b.first_name as string ?? null}, first_name),
        last_name            = ${(b.last_name as string) ?? null},
        birth_date           = ${(b.birth_date as string) ?? null},
        death_date           = ${(b.death_date as string) ?? null},
        gender               = COALESCE(${b.gender as string ?? null}, gender),
        location_label       = ${(b.location_label as string) ?? null},
        latitude             = ${(b.latitude as number) ?? null},
        longitude            = ${(b.longitude as number) ?? null},
        residence_h3         = ${(b.residence_h3 as string) ?? null},
        birth_location_label = ${(b.birth_location_label as string) ?? null},
        birth_latitude       = ${(b.birth_latitude as number) ?? null},
        birth_longitude      = ${(b.birth_longitude as number) ?? null},
        birth_h3             = ${(b.birth_h3 as string) ?? null},
        notes                = ${(b.notes as string) ?? null},
        photo_url            = ${(b.photo_url as string) ?? null},
        phone                = ${(b.phone as string) ?? null},
        whatsapp             = ${(b.whatsapp as string) ?? null},
        is_urgent            = COALESCE(${b.is_urgent as boolean ?? null}, is_urgent),
        claim_state          = COALESCE(${b.claim_state as string ?? null}, claim_state),
        owner_user_id        = COALESCE(${b.owner_user_id as string ?? null}, owner_user_id),
        claim_token          = ${(b.claim_token as string) ?? null},
        stewardship_state    = COALESCE(${b.stewardship_state as string ?? null}, stewardship_state),
        steward_user_id      = ${(b.steward_user_id as string) ?? null},
        steward_claim_token  = ${(b.steward_claim_token as string) ?? null},
        updated_at           = ${now}
      WHERE id = ${id}
    `;

    const { rows } = await sql`SELECT * FROM members WHERE id = ${id}`;
    return res.status(200).json(rows[0]);
  }

  if (req.method === "DELETE") {
    await sql`DELETE FROM relationships WHERE source_id = ${id} OR target_id = ${id}`;
    await sql`DELETE FROM members WHERE id = ${id}`;
    return res.status(200).json({ ok: true });
  }

  return res.status(405).json({ error: "Method not allowed" });
}
