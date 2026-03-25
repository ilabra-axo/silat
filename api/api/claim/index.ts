// POST /api/claim — server-side claim flow
// Body: { token: string, type?: 'steward' }
// Finds member by token, marks claimed, enrolls user in the member's tree.

import { VercelRequest, VercelResponse } from "@vercel/node";
import { sql } from "@vercel/postgres";
import { cors, requireAuth } from "../../lib/auth";

export default async function handler(
  req: VercelRequest,
  res: VercelResponse,
) {
  cors(res);
  if (req.method === "OPTIONS") return res.status(200).end();
  if (req.method !== "POST") return res.status(405).json({ error: "POST only" });

  const user = await requireAuth(req, res);
  if (!user) return;

  const { token, type } = req.body as { token: string; type?: string };
  if (!token) return res.status(400).json({ error: "token required" });

  const now = new Date().toISOString();

  if (type === "steward") {
    const { rows } = await sql`
      SELECT * FROM members WHERE steward_claim_token = ${token} LIMIT 1
    `;
    if (!rows.length) {
      return res.status(404).json({ error: "Invalid stewardship token" });
    }
    const member = rows[0];

    await sql`
      UPDATE members SET
        stewardship_state   = 'active',
        steward_user_id     = ${user.id},
        steward_claim_token = NULL,
        updated_at          = ${now}
      WHERE id = ${member.id}
    `;

    // Enroll user in the member's tree
    await sql`
      INSERT INTO tree_participants (user_id, tree_id, role)
      VALUES (${user.id}, ${member.tree_id}, 'member')
      ON CONFLICT DO NOTHING
    `;

    const { rows: updated } = await sql`SELECT * FROM members WHERE id = ${member.id}`;
    return res.status(200).json(updated[0]);
  } else {
    const { rows } = await sql`
      SELECT * FROM members WHERE claim_token = ${token} LIMIT 1
    `;
    if (!rows.length) {
      return res.status(404).json({ error: "Invalid or expired claim token" });
    }
    const member = rows[0];

    if (member.claim_state === "claimed") {
      return res.status(409).json({ error: "Profile already claimed" });
    }

    await sql`
      UPDATE members SET
        claim_state   = 'claimed',
        owner_user_id = ${user.id},
        claim_token   = NULL,
        updated_at    = ${now}
      WHERE id = ${member.id}
    `;

    // Enroll user in the member's tree
    await sql`
      INSERT INTO tree_participants (user_id, tree_id, role)
      VALUES (${user.id}, ${member.tree_id}, 'member')
      ON CONFLICT DO NOTHING
    `;

    const { rows: updated } = await sql`SELECT * FROM members WHERE id = ${member.id}`;
    return res.status(200).json(updated[0]);
  }
}
