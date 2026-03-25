// GET  /api/attachments?member_id=<id>  — list attachments for a member
// POST /api/attachments                 — upload file to Vercel Blob + record in DB
//
// Multipart POST body:
//   member_id: string
//   file:      binary (the attachment)
//   caption:   string (optional)
//
// Returns: { id, member_id, blob_url, filename, mime_type, byte_size, caption, created_at }

import { VercelRequest, VercelResponse } from "@vercel/node";
import { put } from "@vercel/blob";
import { nanoid } from "nanoid";
import { cors, requireAuth, getUserTrees, getPrimaryTree } from "../../lib/auth";
import { sql } from "@vercel/postgres";

export const config = { api: { bodyParser: false } };

export default async function handler(req: VercelRequest, res: VercelResponse) {
  cors(res);
  if (req.method === "OPTIONS") return res.status(200).end();

  const user = await requireAuth(req, res);
  if (!user) return;

  if (req.method === "GET") return handleGet(req, res, user.id);
  if (req.method === "POST") return handlePost(req, res, user.id);
  return res.status(405).json({ error: "Method not allowed" });
}

async function handleGet(req: VercelRequest, res: VercelResponse, userId: string) {
  const memberId = typeof req.query.member_id === "string" ? req.query.member_id : null;
  if (!memberId) return res.status(400).json({ error: "member_id required" });

  const trees = await getUserTrees(userId);
  if (trees.length === 0) return res.status(200).json([]);

  const { rows } = await sql.query(
    `SELECT id, member_id, blob_url, filename, mime_type, byte_size, caption, created_by, created_at
     FROM attachments
     WHERE member_id = $1 AND tree_id = ANY($2::text[])
     ORDER BY created_at ASC`,
    [memberId, trees]
  );
  return res.status(200).json(rows);
}

async function handlePost(req: VercelRequest, res: VercelResponse, userId: string) {
  // Parse multipart manually using raw body + headers
  const buffers: Buffer[] = [];
  await new Promise<void>((resolve, reject) => {
    req.on("data", (chunk: Buffer) => buffers.push(chunk));
    req.on("end", resolve);
    req.on("error", reject);
  });
  const rawBody = Buffer.concat(buffers);

  const contentType = req.headers["content-type"] ?? "";
  const boundaryMatch = contentType.match(/boundary=([^\s;]+)/);
  if (!boundaryMatch) return res.status(400).json({ error: "Expected multipart/form-data" });

  const boundary = boundaryMatch[1];
  const parts = parseMultipart(rawBody, boundary);

  const memberId = parts["member_id"]?.text;
  const caption = parts["caption"]?.text ?? null;
  const filePart = parts["file"];

  if (!memberId || !filePart) {
    return res.status(400).json({ error: "member_id and file required" });
  }

  // Verify user has access to this member's tree
  const trees = await getUserTrees(userId);
  const { rows: memberRows } = await sql.query(
    "SELECT tree_id FROM members WHERE id = $1 AND tree_id = ANY($2::text[])",
    [memberId, trees]
  );
  if (memberRows.length === 0) {
    return res.status(403).json({ error: "member not found or access denied" });
  }
  const treeId = memberRows[0].tree_id as string;

  const id = nanoid(12);
  const filename = sanitizeFilename(filePart.filename ?? `upload-${id}`);
  const mimeType = filePart.contentType ?? "application/octet-stream";

  // Upload to Vercel Blob
  const blob = await put(`silat/${treeId}/${memberId}/${id}-${filename}`, filePart.data, {
    access: "public",
    contentType: mimeType,
    addRandomSuffix: false,
  });

  await sql.query(
    `INSERT INTO attachments (id, member_id, tree_id, blob_url, filename, mime_type, byte_size, caption, created_by)
     VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)`,
    [id, memberId, treeId, blob.url, filename, mimeType, filePart.data.length, caption, userId]
  );

  const { rows } = await sql.query(
    "SELECT id, member_id, blob_url, filename, mime_type, byte_size, caption, created_by, created_at FROM attachments WHERE id = $1",
    [id]
  );
  return res.status(201).json(rows[0]);
}

// ── Minimal multipart parser ────────────────────────────────────────────────

interface Part {
  text?: string;
  data?: Buffer;
  filename?: string;
  contentType?: string;
}

function parseMultipart(body: Buffer, boundary: string): Record<string, Part> {
  const parts: Record<string, Part> = {};
  const delim = Buffer.from(`--${boundary}`);
  let pos = 0;

  while (pos < body.length) {
    const start = indexOf(body, delim, pos);
    if (start === -1) break;
    pos = start + delim.length;

    if (body[pos] === 0x2d && body[pos + 1] === 0x2d) break; // --boundary--

    // Skip \r\n after boundary
    if (body[pos] === 0x0d) pos += 2;

    // Read headers until \r\n\r\n
    const headerEnd = indexOf(body, Buffer.from("\r\n\r\n"), pos);
    if (headerEnd === -1) break;
    const headersRaw = body.slice(pos, headerEnd).toString("latin1");
    pos = headerEnd + 4;

    const nextBound = indexOf(body, delim, pos);
    const dataEnd = nextBound === -1 ? body.length : nextBound - 2; // strip \r\n before boundary
    const data = body.slice(pos, dataEnd);
    pos = nextBound === -1 ? body.length : nextBound;

    // Parse headers
    const name = headersRaw.match(/name="([^"]+)"/)?.[1];
    if (!name) continue;
    const filename = headersRaw.match(/filename="([^"]+)"/)?.[1];
    const ctMatch = headersRaw.match(/Content-Type:\s*([^\r\n]+)/i);
    const contentType = ctMatch?.[1]?.trim();

    parts[name] = filename
      ? { data, filename, contentType }
      : { text: data.toString("utf8") };
  }
  return parts;
}

function indexOf(haystack: Buffer, needle: Buffer, start = 0): number {
  for (let i = start; i <= haystack.length - needle.length; i++) {
    let found = true;
    for (let j = 0; j < needle.length; j++) {
      if (haystack[i + j] !== needle[j]) { found = false; break; }
    }
    if (found) return i;
  }
  return -1;
}

function sanitizeFilename(name: string): string {
  return name.replace(/[^a-zA-Z0-9._-]/g, "_").slice(0, 120);
}
