// api/auth.js
const bcrypt = require('bcryptjs');

/**
 * Helper: read JSON body (works on Vercel serverless & plain Node)
 */
async function readJsonBody(req) {
  if (req.body) return req.body; // some platforms already parse
  return await new Promise((resolve, reject) => {
    let data = '';
    req.on('data', chunk => { data += chunk; });
    req.on('end', () => {
      if (!data) return resolve({});
      try { resolve(JSON.parse(data)); }
      catch (err) { reject(err); }
    });
    req.on('error', reject);
  });
}

module.exports = async function handler(req, res) {
  // Allow only POST
  if (req.method !== 'POST') {
    res.setHeader('Allow', 'POST');
    return res.status(405).json({ ok: false, error: 'Method not allowed' });
  }

  try {
    const body = await readJsonBody(req);
    const code = body && body.code;

    if (!code || typeof code !== 'string') {
      return res.status(400).json({ ok: false, error: 'Bad request: missing code' });
    }

    const secretHash = process.env.SECRET_HASH;
    if (!secretHash) {
      console.error('SECRET_HASH not set in environment');
      return res.status(500).json({ ok: false, error: 'Server misconfigured' });
    }

    // Use bcryptjs compareSync to keep code simple (bcryptjs is pure JS)
    const match = bcrypt.compareSync(code, secretHash);

    if (!match) {
      // Optional: you can log attempts, throttle, etc.
      return res.status(401).json({ ok: false, error: 'Invalid secret' });
    }

    // success: return flag from env var (do NOT hardcode flag in repo)
    const FLAG = process.env.FLAG || 'CYBERDUNE{REPLACE_WITH_FLAG}';
    return res.status(200).json({ ok: true, flag: FLAG });
  } catch (err) {
    console.error('Auth error', err);
    return res.status(500).json({ ok: false, error: 'Internal server error' });
  }
};
