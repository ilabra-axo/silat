// GET /api/geocode?q=<query> — proxy to Nominatim (avoids browser CORS)
// No auth required — geocoding is public.

import { VercelRequest, VercelResponse } from "@vercel/node";
import { cors } from "../../lib/auth";

export default async function handler(
  req: VercelRequest,
  res: VercelResponse,
) {
  cors(res);
  if (req.method === "OPTIONS") return res.status(200).end();
  if (req.method !== "GET") return res.status(405).json({ error: "GET only" });

  const q = typeof req.query.q === "string" ? req.query.q.trim() : "";
  if (q.length < 3) return res.status(200).json([]);

  const url = new URL("https://nominatim.openstreetmap.org/search");
  url.searchParams.set("q", q);
  url.searchParams.set("format", "json");
  url.searchParams.set("limit", "5");
  url.searchParams.set("addressdetails", "1");

  try {
    const upstream = await fetch(url.toString(), {
      headers: {
        "User-Agent": "silat-arrahim/1.0 (silat.ooo)",
        Accept: "application/json",
      },
    });
    if (!upstream.ok) {
      return res.status(upstream.status).json({ error: "geocode upstream error" });
    }
    const data = await upstream.json() as any[];
    const results = data.map((item: any) => ({
      display_name: item.display_name as string,
      lat: item.lat as string,
      lon: item.lon as string,
      city: (item.address?.city
          || item.address?.town
          || item.address?.village
          || item.address?.municipality
          || item.address?.county) as string | null ?? null,
      country: (item.address?.country) as string | null ?? null,
    }));
    // Cache for 1 hour — same query always returns same places
    res.setHeader("Cache-Control", "public, max-age=3600, s-maxage=3600");
    return res.status(200).json(results);
  } catch (err) {
    console.error("[geocode]", err);
    return res.status(502).json({ error: "geocode unavailable" });
  }
}
