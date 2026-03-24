// GET /api/members — fetch all members (with relationships) for the authed user's tree

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

  const membersResult = await sql`
    SELECT * FROM members ORDER BY last_name, first_name
  `;

  const relsResult = await sql`
    SELECT * FROM relationships ORDER BY created_at
  `;

  return res.status(200).json({
    members: membersResult.rows,
    relationships: relsResult.rows,
  });
}
