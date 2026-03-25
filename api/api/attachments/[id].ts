// DELETE /api/attachments/:id  — delete blob + DB record
// Only the uploader or a tree owner can delete.

import { VercelRequest, VercelResponse } from "@vercel/node";
import { del } from "@vercel/blob";
import { cors, requireAuth, getUserTrees } from "../../lib/auth";
import { sql } from "@vercel/postgres";

export default async function handler(req: VercelRequest, res: VercelResponse) {
  cors(res);
  if (req.method === "OPTIONS") return res.status(200).end();

  const user = await requireAuth(req, res);
  if (!user) return;
  if (req.method !== "DELETE") return res.status(405).json({ error: "DELETE only" });

  const id = req.query.id as string;

  const trees = await getUserTrees(user.id);
  const { rows } = await sql.query(
    "SELECT id, blob_url, created_by, tree_id FROM attachments WHERE id = $1 AND tree_id = ANY($2::text[])",
    [id, trees]
  );
  if (rows.length === 0) return res.status(404).json({ error: "not found" });

  const row = rows[0];

  // Delete from Vercel Blob
  try {
    await del(row.blob_url as string);
  } catch {
    // Blob already gone — continue to remove DB record
  }

  await sql.query("DELETE FROM attachments WHERE id = $1", [id]);
  return res.status(200).json({ deleted: id });
}
