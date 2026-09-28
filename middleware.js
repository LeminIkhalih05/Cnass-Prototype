// Protège tout le site : sans session valide, redirection vers /login.
// Variables à définir dans Vercel : SESSION_SECRET (et CNASS_USER / CNASS_PASSWORD pour api/login.js)

export const config = {
  matcher: ['/((?!login|login\\.html|api/login|favicon\\.ico).*)'],
};

const enc = new TextEncoder();

async function sign(value, secret) {
  const key = await crypto.subtle.importKey('raw', enc.encode(secret), { name: 'HMAC', hash: 'SHA-256' }, false, ['sign']);
  const sig = await crypto.subtle.sign('HMAC', key, enc.encode(value));
  return Array.from(new Uint8Array(sig)).map(b => b.toString(16).padStart(2, '0')).join('');
}

function readCookie(header, name) {
  if (!header) return null;
  const m = header.split(/;\s*/).find(c => c.startsWith(name + '='));
  return m ? decodeURIComponent(m.slice(name.length + 1)) : null;
}

export default async function middleware(request) {
  const secret = process.env.SESSION_SECRET;
  const url = new URL(request.url);
  const toLogin = () => {
    const dest = new URL('/login', url);
    if (url.pathname !== '/') dest.searchParams.set('next', url.pathname);
    return Response.redirect(dest, 302);
  };
  if (!secret) return new Response('Configuration manquante : SESSION_SECRET', { status: 500 });

  const token = readCookie(request.headers.get('cookie'), 'cnass_session');
  if (!token) return toLogin();
  const [exp, sig] = token.split('.');
  if (!exp || !sig || Number(exp) < Date.now()) return toLogin();
  const expected = await sign(exp, secret);
  if (expected.length !== sig.length) return toLogin();
  let diff = 0;
  for (let i = 0; i < sig.length; i++) diff |= sig.charCodeAt(i) ^ expected.charCodeAt(i);
  if (diff !== 0) return toLogin();

  // Session valide : on laisse passer la requête.
  return new Response(null, { headers: { 'x-middleware-next': '1' } });
}
