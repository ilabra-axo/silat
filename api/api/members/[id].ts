// GET /api/members/:id — fetch a single member + their relationships

import { VercelRequest, VercelResponse } from "@vercel/node";
import { sql } from "@vercel/postgres";
import { cors, requireAuth } from "../../lib/auth";

export default async function handler(
  req: VercelRequest,
  res: VercelResponse,
) {
  cors(res);
  if (req.method === "OPTIONS") return res.status(200).end();
  if (req.method !== "GET") return res.status(405).json({ error: "GET only" });

  const user = await requireAuth(req, res);
  if (!user) return;

  const { id } = req.query;

  const memberResult = await sql`
    SELECT * FROM members WHERE id = ${id as string}
  `;

  if (memberResult.rows.length === 0) {
    return res.status(404).json({ error: "Not found" });
  }

  const relsResult = await sql`
    SELECT * FROM relationships
    WHERE source_id = ${id as string} OR target_id = ${id as string}
    ORDER BY created_at
  `;

  return res.status(200).json({
    member: memberResult.rows[0],
    relationships: relsResult.rows,
  });
}
