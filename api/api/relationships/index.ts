// GET /api/relationships — included in GET /api/members, but available standalone
// POST /api/relationships — create a relationship

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
    const { rows } = await sql.query(
      `SELECT * FROM relationships WHERE tree_id = ANY($1::text[]) ORDER BY created_at`,
      [trees],
    );
    return res.status(200).json({ relationships: rows });
  }

  if (req.method === "POST") {
    const b = req.body as Record<string, unknown>;
    const tree_id = await getPrimaryTree(user.id);
    const now = new Date().toISOString();

    const id = b.id as string;
    if (!id || !b.source_id || !b.target_id || !b.rel_type) {
      return res.status(400).json({ error: "id, source_id, target_id, rel_type required" });
    }

    try {
      await sql`
        INSERT INTO relationships (
          id, source_id, target_id, rel_type,
          last_contact_at, rel_notes, salience, intervention_mode,
          created_at, tree_id
        ) VALUES (
          ${id},
          ${b.source_id as string},
          ${b.target_id as string},
          ${b.rel_type as string},
          ${(b.last_contact_at as string) ?? null},
          ${(b.notes as string) ?? null},
          ${(b.salience as number) ?? 0.5},
          ${(b.intervention_mode as string) ?? 'passive'},
          ${(b.created_at as string) ?? now},
          ${tree_id}
        )
        ON CONFLICT (source_id, target_id, rel_type) DO NOTHING
      `;
    } catch (err: any) {
      if (err?.code === "23505") {
        return res.status(409).json({ error: "Relationship already exists" });
      }
      throw err;
    }

    const { rows } = await sql`SELECT * FROM relationships WHERE id = ${id}`;
    if (!rows.length) return res.status(409).json({ error: "Relationship already exists" });
    return res.status(200).json(rows[0]);
  }

  return res.status(405).json({ error: "Method not allowed" });
}
