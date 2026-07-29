# Alpha Móveis Planejados — Sistema Interno v1

Protótipo funcional do sistema de gestão da Alpha Móveis Planejados.
Aplicação single-page 100% estática, sem dependência de build ou servidor.

**Versão:** 1.0 · **Data:** 27 de julho de 2026

---

## O que está incluído

- `index.html` — a aplicação inteira (HTML + CSS + JavaScript inline)
- `README.md` — este arquivo

Sem build step. Sem `node_modules`. Sem dependências além dos fontes do Google Fonts (Fraunces + Inter), carregados via CDN em runtime.

---

## Rodando localmente

Abrir o `index.html` direto no navegador funciona. Se preferir um servidor local para testar navegação e histórico:

```bash
# Python 3
python3 -m http.server 8080

# Node
npx serve .
```

Acesse `http://localhost:8080`.

---

## Deploy

### Vercel (recomendado — mais simples)

1. Instale a CLI: `npm i -g vercel`
2. Na pasta do projeto: `vercel`
3. Aceite os padrões. Feito.

Ou pelo dashboard: arraste a pasta em https://vercel.com/new

### Netlify

1. Acesse https://app.netlify.com/drop
2. Arraste a pasta inteira
3. Pronto — URL gerada em segundos

### GitHub Pages

1. Crie um repositório novo (ex: `alpha-sistema`)
2. Suba os arquivos:
   ```bash
   git init
   git add .
   git commit -m "Alpha sistema v1"
   git remote add origin <url-do-repo>
   git push -u origin main
   ```
3. Em Settings → Pages: source = branch `main`, folder = `/ (root)`
4. URL será `https://<usuario>.github.io/alpha-sistema/`

### Cloudflare Pages

1. Conecte o repositório GitHub
2. Build command: (deixe vazio)
3. Output directory: `/`
4. Deploy

### Servidor próprio / VPS

Copie `index.html` para qualquer diretório servido pelo Nginx/Apache/Caddy. Nenhuma configuração especial necessária.

---

## Compatibilidade

- **Navegadores:** Chrome/Edge 105+, Firefox 105+, Safari 16+
- **Mobile:** iOS Safari 16+, Chrome Android 105+
- **Recursos usados:** CSS `color-mix()`, `clamp()`, Grid, Flexbox, Fetch API, ES2020 JS

O sistema é totalmente responsivo — sidebar vira drawer com hamburger em telas menores que 768px.

---

## Modos de operação

- **Modo Gestor** (padrão) — tema claro institucional, para dashboard e projetos
- **Modo Chão de Fábrica** — tema escuro para tablets no galpão. Ativado automaticamente ao entrar na view "Chão de Fábrica" ou manualmente pelo botão no rodapé do menu

---

## Próximos passos (v2)

Este é um protótipo funcional com dados mockados. Para virar produção:

1. Backend real (Supabase, Firebase, ou API própria) para persistência
2. Autenticação e perfis (gestor vs. marceneiro)
3. Integração OAuth com Google Agenda (o botão "Confirmar e sincronizar" hoje é mock)
4. Parser de PDF para importação de projeto arquitetônico
5. Fluxo de aprovação PJ para horas trabalhadas
6. Notificações push para alertas de reagendamento

---

## Suporte

Rossi Studio — sistema desenvolvido para Alpha Planejados Ltda.
