// Google OAuth — redirect flow (web-compatible)
// Step 1: /api/auth/oauth?provider=google  → redirect to Google
// Step 2: Google callback → exchange code → redirect to APP_URL?silat_token=...&silat_user=...
// Flutter app reads the params on startup (main.dart) to complete sign-in.

import { VercelRequest, VercelResponse } from "@vercel/node";
import { cors, encodeToken } from "../../lib/auth";

const REDIRECT_URI = "https://silat-api.vercel.app/api/auth/oauth";
const APP_URL = "https://silat.ooo";
const TOKEN_TTL_MS = 30 * 24 * 60 * 60 * 1000; // 30 days

export default async function handler(
  req: VercelRequest,
  res: VercelResponse,
) {
  cors(res);

  if (req.method === "OPTIONS") return res.status(200).end();

  try {
    const { provider, code, state } = req.query;

    // ── Step 1: initiate redirect to Google ───────────────────────────────
    if (!code) {
      if (provider !== "google") {
        return res.status(400).json({ error: "Only Google OAuth supported" });
      }

      const clientId = process.env.GOOGLE_CLIENT_ID?.trim();
      if (!clientId) {
        return res.status(500).json({ error: "GOOGLE_CLIENT_ID not set" });
      }

      const authUrl =
        `https://accounts.google.com/o/oauth2/v2/auth` +
        `?client_id=${clientId}` +
        `&redirect_uri=${encodeURIComponent(REDIRECT_URI)}` +
        `&response_type=code` +
        `&scope=${encodeURIComponent("openid profile email")}` +
        `&state=google`;

      res.writeHead(307, { Location: authUrl });
      return res.end();
    }

    // ── Step 2: callback from Google ──────────────────────────────────────
    if (state !== "google") {
      return res.status(400).json({ error: "Invalid state" });
    }

    const { sql } = await import("@vercel/postgres");
    const clientId = process.env.GOOGLE_CLIENT_ID?.trim();
    const clientSecret = process.env.GOOGLE_CLIENT_SECRET?.trim();

    const tokenRes = await fetch("https://oauth2.googleapis.com/token", {
      method: "POST",
      headers: { "Content-Type": "application/x-www-form-urlencoded" },
      body: new URLSearchParams({
        code: code as string,
        client_id: clientId!,
        client_secret: clientSecret!,
        redirect_uri: REDIRECT_URI,
        grant_type: "authorization_code",
      }),
    });

    const tokens = (await tokenRes.json()) as { access_token?: string };
    if (!tokens.access_token) {
      throw new Error("No access token from Google");
    }

    const userRes = await fetch(
      "https://www.googleapis.com/oauth2/v2/userinfo",
      { headers: { Authorization: `Bearer ${tokens.access_token}` } },
    );
    const userInfo = (await userRes.json()) as {
      email: string;
      name?: string;
    };

    const email = userInfo.email.toLowerCase();

    // Upsert user
    const existing = await sql`
      SELECT id, email, name FROM users WHERE email = ${email}
    `;

    let user: { id: string; email: string; name: string };

    if (existing.rows.length > 0) {
      user = existing.rows[0] as typeof user;
    } else {
      const created = await sql`
        INSERT INTO users (email, name, created_at)
        VALUES (${email}, ${userInfo.name ?? email.split("@")[0]}, NOW())
        RETURNING id, email, name
      `;
      user = created.rows[0] as typeof user;
    }

    const token = encodeToken({
      userId: user.id,
      email: user.email,
      exp: Date.now() + TOKEN_TTL_MS,
    });

    // ── Redirect back to Flutter app with token in query params ───────────
    // Flutter main.dart reads silat_token + silat_user on startup to sign in.
    const userB64 = Buffer.from(JSON.stringify(user)).toString("base64url");
    const callbackUrl =
      `${APP_URL}?silat_token=${encodeURIComponent(token)}` +
      `&silat_user=${encodeURIComponent(userB64)}`;

    res.writeHead(307, { Location: callbackUrl });
    return res.end();

  } catch (err: unknown) {
    const msg = err instanceof Error ? err.message : String(err);
    console.error("[oauth]", msg);
    // Redirect to app with error param so user sees a message
    res.writeHead(307, {
      Location: `${APP_URL}?silat_error=${encodeURIComponent(msg)}`,
    });
    return res.end();
  }
}
