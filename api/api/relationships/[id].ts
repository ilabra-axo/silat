// DELETE /api/relationships/:id — delete a relationship
// PUT /api/relationships/:id — update last_contact_at, notes, salience

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

  const { rows: check } = await sql.query(
    `SELECT id FROM relationships WHERE id = $1 AND tree_id = ANY($2::text[])`,
    [id, trees],
  );
  if (!check.length) {
    return res.status(404).json({ error: "Relationship not found" });
  }

  if (req.method === "PUT") {
    const b = req.body as Record<string, unknown>;
    await sql`
      UPDATE relationships SET
        last_contact_at  = COALESCE(${(b.last_contact_at as string) ?? null}, last_contact_at),
        rel_notes        = COALESCE(${(b.notes as string) ?? null}, rel_notes),
        salience         = COALESCE(${(b.salience as number) ?? null}, salience),
        intervention_mode = COALESCE(${(b.intervention_mode as string) ?? null}, intervention_mode)
      WHERE id = ${id}
    `;
    const { rows } = await sql`SELECT * FROM relationships WHERE id = ${id}`;
    return res.status(200).json(rows[0]);
  }

  if (req.method === "DELETE") {
    await sql`DELETE FROM relationships WHERE id = ${id}`;
    return res.status(200).json({ ok: true });
  }

  return res.status(405).json({ error: "Method not allowed" });
}
