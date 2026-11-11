/**
 * AethexFlow Enterprise — Edge Worker
 * Grok = Blind Intent Phraser
 * Zero-trust 6-digit codes + secure Grok proxy
 */

export default {
  async fetch(request, env, ctx) {
    const url = new URL(request.url);
    const path = url.pathname;

    // CORS for local + production
    const cors = {
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
      "Access-Control-Allow-Headers": "Content-Type, Authorization, X-User-Code",
    };

    if (request.method === "OPTIONS") {
      return new Response(null, { headers: cors });
    }

    try {
      // ---------- Public API ----------
      if (path === "/api/health") {
        return json({ ok: true, service: "aethexflow-enterprise", ts: Date.now() }, cors);
      }

      // Generate or validate 6-digit code
      if (path === "/api/auth/code" && request.method === "POST") {
        return handleAuthCode(request, env, cors);
      }

      // Secure Grok proxy (key never leaves edge)
      if (path === "/api/grok" && request.method === "POST") {
        return handleGrok(request, env, cors);
      }

      // Aethi — Blind Intent → Grok
      if (path === "/api/aethi" && request.method === "POST") {
        return handleAethi(request, env, cors);
      }

      // Owner panel data
      if (path === "/api/owner" && request.method === "GET") {
        return handleOwner(request, env, cors);
      }

      // Serve static assets (Pages)
      if (env.ASSETS) {
        return env.ASSETS.fetch(request);
      }

      return new Response("Not found", { status: 404, headers: cors });
    } catch (err) {
      console.error(err);
      return json({ error: err.message || "Internal error" }, cors, 500);
    }
  },
};

// ---------- Helpers ----------

function json(data, cors = {}, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: { "Content-Type": "application/json", ...cors },
  });
}

function generateCode() {
  return String(Math.floor(100000 + Math.random() * 900000));
}

async function handleAuthCode(request, env, cors) {
  const body = await request.json().catch(() => ({}));
  const action = body.action || "generate"; // generate | validate
  const code = body.code;

  if (!env.DB) {
    // Fallback mode (no D1 yet) — still works for first launch
    if (action === "generate") {
      const c = generateCode();
      return json({ code: c, note: "D1 not bound — code is ephemeral" }, cors);
    }
    return json({ valid: !!code && code.length === 6 }, cors);
  }

  if (action === "generate") {
    const c = generateCode();
    const id = crypto.randomUUID();
    await env.DB.prepare(
      "INSERT INTO users (id, code, created_at, role) VALUES (?, ?, ?, ?)"
    ).bind(id, c, Date.now(), body.role || "user").run();
    return json({ code: c, id }, cors);
  }

  if (action === "validate") {
    const row = await env.DB.prepare(
      "SELECT id, role FROM users WHERE code = ?"
    ).bind(code).first();
    return json({ valid: !!row, user: row || null }, cors);
  }

  return json({ error: "unknown action" }, cors, 400);
}

async function handleGrok(request, env, cors) {
  if (!env.GROK_API_KEY) {
    return json({ error: "GROK_API_KEY not configured in Cloudflare secrets" }, cors, 500);
  }

  const body = await request.json().catch(() => ({}));
  const messages = body.messages || [{ role: "user", content: body.prompt || "" }];
  const model = body.model || env.GROK_MODEL || "grok-4";

  const res = await fetch("https://api.x.ai/v1/chat/completions", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${env.GROK_API_KEY}`,
    },
    body: JSON.stringify({
      model,
      messages,
      temperature: body.temperature ?? 0.4,
      max_tokens: body.max_tokens ?? 1024,
      stream: false,
    }),
  });

  if (!res.ok) {
    const errText = await res.text();
    return json({ error: "Grok API error", detail: errText }, cors, res.status);
  }

  const data = await res.json();
  return json(data, cors);
}

async function handleAethi(request, env, cors) {
  // Blind Intent Phraser
  // User text → Grok extracts pure intent → returns structured command or reply
  const body = await request.json().catch(() => ({}));
  const userText = body.text || body.message || "";

  if (!userText) {
    return json({ error: "text required" }, cors, 400);
  }

  if (!env.GROK_API_KEY) {
    return json({ error: "GROK_API_KEY missing" }, cors, 500);
  }

  const system = `You are Aethi, the blind intent phraser for AethexFlow.
Your only job: understand the user's real intent without adding opinions.
Return STRICT JSON only:
{
  "intent": "short clear intent",
  "action": "chat|command|query|help|unknown",
  "payload": {},
  "reply": "short honest response if needed"
}
Never invent capabilities that do not exist. Be truthful.`;

  const res = await fetch("https://api.x.ai/v1/chat/completions", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${env.GROK_API_KEY}`,
    },
    body: JSON.stringify({
      model: env.GROK_MODEL || "grok-4",
      messages: [
        { role: "system", content: system },
        { role: "user", content: userText },
      ],
      temperature: 0.2,
      max_tokens: 400,
    }),
  });

  if (!res.ok) {
    const t = await res.text();
    return json({ error: "Grok failed", detail: t }, cors, 500);
  }

  const data = await res.json();
  let parsed;
  try {
    const content = data.choices?.[0]?.message?.content || "{}";
    // extract JSON even if wrapped in markdown
    const match = content.match(/\{[\s\S]*\}/);
    parsed = JSON.parse(match ? match[0] : content);
  } catch {
    parsed = {
      intent: "parse_failed",
      action: "chat",
      payload: {},
      reply: data.choices?.[0]?.message?.content || "I understood the request but could not structure it.",
    };
  }

  return json({ aethi: parsed, raw: data }, cors);
}

async function handleOwner(request, env, cors) {
  // Simple owner view — list recent codes / users if D1 available
  if (!env.DB) {
    return json({
      mode: "ephemeral",
      message: "D1 not bound yet. Generate codes via /api/auth/code",
      users: [],
    }, cors);
  }

  const { results } = await env.DB.prepare(
    "SELECT id, code, role, created_at FROM users ORDER BY created_at DESC LIMIT 50"
  ).all();

  return json({ mode: "d1", users: results || [] }, cors);
}
