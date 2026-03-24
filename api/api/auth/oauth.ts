// Google OAuth — identical pattern to ABW (uffp-backend)
// Redirect URI: https://silat-api.vercel.app/api/auth/oauth

import { VercelRequest, VercelResponse } from "@vercel/node";
import { cors, encodeToken } from "../../lib/auth";

const REDIRECT_URI = "https://silat-api.vercel.app/api/auth/oauth";
const TOKEN_TTL_MS = 30 * 24 * 60 * 60 * 1000; // 30 days

export default async function handler(
  req: VercelRequest,
  res: VercelResponse,
) {
  cors(res);

  if (req.method === "OPTIONS") return res.status(200).end();

  try {
    const { provider, code, state } = req.query;

    // Step 1 — initiate redirect
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

    // Step 2 — callback: exchange code for user info
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

    // Post token to opener and close popup (same as ABW pattern)
    const html = `<!DOCTYPE html><html><head><title>silat — signed in</title></head>
<body style="background:#0F1117;color:#F5F2ED;font-family:system-ui;padding:2rem">
  <p>Signing in…</p>
  <script>
    window.opener?.postMessage(
      { type: 'silat-oauth', user: ${JSON.stringify(user)}, token: '${token}' },
      '*'
    );
    setTimeout(() => window.close(), 800);
  </script>
</body></html>`;

    res.setHeader("Content-Type", "text/html");
    return res.status(200).send(html);
  } catch (err: unknown) {
    const msg = err instanceof Error ? err.message : String(err);
    console.error("[oauth]", msg);
    const html = `<!DOCTYPE html><html><body style="background:#0F1117;color:#B85450;font-family:system-ui;padding:2rem">
<p>Sign-in failed: ${msg}</p><button onclick="window.close()">close</button>
</body></html>`;
    res.setHeader("Content-Type", "text/html");
    return res.status(500).send(html);
  }
}
