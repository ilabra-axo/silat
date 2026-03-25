// GET /api/events/pull?since=<iso_timestamp>
// Returns events, members, and relationships scoped to the user's tree,
// optionally filtered by a cursor timestamp.

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

  const tree_id = user.id;
  const since =
    typeof req.query.since === "string" && req.query.since.length > 0
      ? req.query.since
      : "1970-01-01T00:00:00.000Z";

  const eventsResult = await sql`
    SELECT * FROM events
    WHERE tree_id = ${tree_id} AND occurred_at > ${since}::timestamptz
    ORDER BY occurred_at ASC
  `;

  const membersResult = await sql`
    SELECT * FROM members WHERE tree_id = ${tree_id} ORDER BY last_name, first_name
  `;

  const relsResult = await sql`
    SELECT * FROM relationships WHERE tree_id = ${tree_id} ORDER BY created_at
  `;

  return res.status(200).json({
    events: eventsResult.rows,
    members: membersResult.rows,
    relationships: relsResult.rows,
  });
}
