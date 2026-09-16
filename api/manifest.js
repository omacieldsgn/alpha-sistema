// Manifesto do app do colaborador. Mesmo ícone e nome da Alpha, mas o atalho
// criado na tela de início abre direto no painel dele: o token vai no start_url.
// O app do gestor continua usando o /manifest.json estático.
const ICONES = [
  { src: '/android/android-chrome-192x192.png', sizes: '192x192', type: 'image/png' },
  { src: '/android/android-chrome-512x512.png', sizes: '512x512', type: 'image/png' },
  { src: '/android/maskable-192x192.png', sizes: '192x192', type: 'image/png', purpose: 'maskable' },
  { src: '/android/maskable-512x512.png', sizes: '512x512', type: 'image/png', purpose: 'maskable' }
];

module.exports = (req, res) => {
  const token = String((req.query && req.query.token) || '');
  const valido = /^[A-Za-z0-9_-]{8,128}$/.test(token);

  res.setHeader('Content-Type', 'application/manifest+json; charset=utf-8');
  res.setHeader('Cache-Control', 'no-store');
  res.status(200).send(JSON.stringify({
    id: valido ? `/colaborador/${token.slice(0, 12)}` : '/',
    name: 'Alpha · Minhas tarefas',
    short_name: 'Alpha',
    description: 'Tarefas do dia na Alpha Planejados',
    start_url: valido ? `/?token=${token}#meu-dia` : '/',
    scope: '/',
    display: 'standalone',
    background_color: '#191919',
    theme_color: '#191919',
    icons: ICONES
  }));
};
