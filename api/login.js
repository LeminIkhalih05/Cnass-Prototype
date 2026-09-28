// Vérifie l'identifiant et le mot de passe, puis pose un cookie de session signé (12 h).
const crypto = require('crypto');

const SESSION_HOURS = 12;

function safeEqual(a, b) {
  const ba = Buffer.from(String(a)), bb = Buffer.from(String(b));
  return ba.length === bb.length && crypto.timingSafeEqual(ba, bb);
}

module.exports = async (req, res) => {
  if (req.method !== 'POST') { res.status(405).json({ ok: false }); return; }
  const { CNASS_USER, CNASS_PASSWORD, SESSION_SECRET } = process.env;
  if (!CNASS_USER || !CNASS_PASSWORD || !SESSION_SECRET) {
    res.status(500).json({ ok: false, error: 'Configuration manquante sur le serveur.' }); return;
  }
  let body = req.body || {};
  if (typeof body === 'string') { try { body = JSON.parse(body); } catch { body = {}; } }

  const good = safeEqual(body.user || '', CNASS_USER) & safeEqual(body.password || '', CNASS_PASSWORD);
  if (!good) {
    await new Promise(r => setTimeout(r, 800)); // ralentit les essais au hasard
    res.status(401).json({ ok: false, error: 'Identifiant ou mot de passe incorrect.' }); return;
  }
  const exp = String(Date.now() + SESSION_HOURS * 3600 * 1000);
  const sig = crypto.createHmac('sha256', SESSION_SECRET).update(exp).digest('hex');
  res.setHeader('Set-Cookie', `cnass_session=${exp}.${sig}; Path=/; HttpOnly; Secure; SameSite=Lax; Max-Age=${SESSION_HOURS * 3600}`);
  res.status(200).json({ ok: true });
};
