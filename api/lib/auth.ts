// Auth helpers — ABW token validation + CORS middleware

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

  // Validate token by calling ABW /me
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
    // Non-fatal — continue even if upsert fails
    console.error("[auth] users upsert failed:", err);
  }

  return user;
}
