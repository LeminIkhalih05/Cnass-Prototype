// Supprime la session et renvoie vers la page de connexion.
module.exports = (req, res) => {
  res.setHeader('Set-Cookie', 'cnass_session=; Path=/; HttpOnly; Secure; SameSite=Lax; Max-Age=0');
  res.writeHead(302, { Location: '/login' });
  res.end();
};
