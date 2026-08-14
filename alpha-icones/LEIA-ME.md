# Alpha Móveis Planejados — Ícones do Aplicativo

Conjunto completo de ícones no estilo aprovado: símbolo dourado sólido (#a78159)
sobre fundo com gradiente diagonal grafite (#191715 → #352f2d), borda fina com
gradiente das cores da marca (taupe → areia), cantos arredondados.

Gerados a partir dos SVGs oficiais — nitidez vetorial em todas as dimensões.

## Como aplicar no projeto

1. Descompacte este zip na RAIZ do projeto (mesma pasta do index.html).
2. Copie o conteúdo de `head-snippet.html` e cole dentro da tag <head> do index.html.
3. git add . && git commit -m "Ícones do app" && git push
   (o Vercel faz o deploy automático)

## Estrutura

```
/
├── favicon.ico                 ← multi-resolução 16/32/48
├── apple-touch-icon.png        ← 180×180 iOS
├── icon-1024.png               ← master
├── icon-1024-square.png        ← master sem alfa (App Store)
├── manifest.json               ← PWA
├── browserconfig.xml           ← tiles Windows
├── head-snippet.html           ← cole no <head>
├── favicon/                    ← 16 a 196
├── ios/                        ← apple-touch 20 a 180
├── android/                    ← chrome 36-512 + maskable 192/512
├── pwa/                        ← 192, 512
└── web/                        ← mstile 70, 150, 310
```

## Verificação pós-deploy

- Aba do navegador → favicon dourado
- iPhone Safari → Compartilhar → Adicionar à Tela de Início
- Android Chrome → Instalar app
- https://realfavicongenerator.net/favicon_checker → auditar
