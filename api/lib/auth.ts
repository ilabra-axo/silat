// Auth helpers — ABW token validation + CORS middleware + tree participant lookup

import { VercelRequest, VercelResponse } from "@vercel/node";
import { sql } from "@vercel/postgres";

export interface AuthUser {
  id: string;
  email: string;
  display_name: string;
}

export function cors(res: VercelResponse): void {
  res.setHeader("Access-Control-Allow-Origin", "*");
  res.setHeader("Access-Control-Allow-Methods", "GET,POST,PUT,DELETE,OPTIONS");
  res.setHeader(
    "Access-Control-Allow-Headers",
    "Authorization, Content-Type",
  );
}

export async function requireAuth(
  req: VercelRequest,
  res: VercelResponse,
): Promise<AuthUser | null> {
  const header = req.headers.authorization;
  if (!header?.startsWith("Bearer ")) {
    res.status(401).json({ error: "Unauthorized" });
    return null;
  }

  const token = header.slice(7);

  let abwUser: { user_id: string; email: string; display_name: string };
  try {
    const abwRes = await fetch("https://agent-bestiary.world/api/auth/me", {
      headers: { Authorization: `Bearer ${token}` },
    });
    if (!abwRes.ok) {
      res.status(401).json({ error: "Invalid or expired token" });
      return null;
    }
    abwUser = (await abwRes.json()) as {
      user_id: string;
      email: string;
      display_name: string;
    };
  } catch {
    res.status(401).json({ error: "Auth service unreachable" });
    return null;
  }

  const user: AuthUser = {
    id: abwUser.user_id,
    email: abwUser.email ?? "",
    display_name: abwUser.display_name ?? "",
  };

  // Upsert user into local users table
  try {
    await sql`
      INSERT INTO users (id, email, display_name)
      VALUES (${user.id}, ${user.email}, ${user.display_name})
      ON CONFLICT (id) DO UPDATE SET
        email        = EXCLUDED.email,
        display_name = EXCLUDED.display_name
    `;
  } catch (err) {
    console.error("[auth] users upsert failed:", err);
  }

  return user;
}

/// Returns all tree_ids the user can access:
/// - Trees they own (tree_id = user.id, auto-created on first member write)
/// - Trees they joined by claiming a profile
export async function getUserTrees(userId: string): Promise<string[]> {
  try {
    const r = await sql`
      SELECT tree_id FROM tree_participants WHERE user_id = ${userId}
    `;
    const joined = r.rows.map((row) => row.tree_id as string);
    // Always include own tree (even if empty / not yet enrolled)
    const all = [...new Set([...joined, userId])];
    return all;
  } catch {
    return [userId];
  }
}

/// Ensures the user is enrolled as owner of their own tree.
export async function ensureOwnTree(userId: string): Promise<void> {
  await sql`
    INSERT INTO tree_participants (user_id, tree_id, role)
    VALUES (${userId}, ${userId}, 'owner')
    ON CONFLICT DO NOTHING
  `;
}

/// Returns the tree_id new members should be created in.
/// Prefers the first joined external tree, falls back to own tree.
export async function getPrimaryTree(userId: string): Promise<string> {
  const r = await sql`
    SELECT tree_id FROM tree_participants
    WHERE user_id = ${userId}
    ORDER BY
      CASE WHEN tree_id = ${userId} THEN 1 ELSE 0 END, -- external trees first
      joined_at
    LIMIT 1
  `;
  if (r.rows.length > 0) return r.rows[0].tree_id as string;
  // No entry yet — use own tree
  await ensureOwnTree(userId);
  return userId;
}
