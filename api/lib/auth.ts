// Auth helpers — token encode/decode + middleware

import { VercelRequest, VercelResponse } from "@vercel/node";
import { sql } from "@vercel/postgres";

export interface TokenPayload {
  userId: string;
  email: string;
  exp: number;
}

export interface AuthUser {
  id: string;
  email: string;
  name: string;
}

export function encodeToken(payload: TokenPayload): string {
  return Buffer.from(JSON.stringify(payload)).toString("base64url");
}

export function decodeToken(token: string): TokenPayload | null {
  try {
    const payload = JSON.parse(
      Buffer.from(token, "base64url").toString("utf8"),
    ) as TokenPayload;
    if (payload.exp < Date.now()) return null;
    return payload;
  } catch {
    return null;
  }
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
  const payload = decodeToken(token);

  if (!payload) {
    res.status(401).json({ error: "Token expired or invalid" });
    return null;
  }

  const result = await sql`
    SELECT id, email, name FROM users WHERE id = ${payload.userId}
  `;

  if (result.rows.length === 0) {
    res.status(401).json({ error: "User not found" });
    return null;
  }

  return result.rows[0] as AuthUser;
}
