# Blueprint · Sistema interno de marcenaria de móveis planejados

Documento de replicação. Descreve **tudo** que o sistema Alpha Móveis Planejados faz e como fazer de novo para outra marcenaria, do zero.

Use como prompt inicial em uma sessão nova de Claude Code (ou outra IA de código), ou como especificação para um dev humano. Onde diz `⇢`, é decisão sua — troque pelo valor da sua marcenaria antes de mandar executar.

---

## 0. Como usar este documento

**Como prompt para IA de código:**

> Você vai construir um sistema interno para uma marcenaria de móveis planejados. Ele já existe pronto para outra marcenaria (Alpha), e este documento descreve a arquitetura completa. Leia inteiro antes de escrever qualquer código. Faça uma versão nova, do zero, para a marcenaria `⇢ NOME DA MARCENARIA`, seguindo cada seção. Onde tiver marcadores `⇢`, use os valores que eu forneço no fim. Onde não tiver marcador, mantenha idêntico ao original.

**Como especificação para humano:**
Leia da seção 1 à 12 na ordem. As decisões arquiteturais já estão tomadas — se quiser mudar alguma, veja primeiro o "por quê" na seção 11 (Gotchas). Trocar algo sem entender esses aprendizados custa dias de retrabalho.

**O que você precisa preparar antes:**
- Uma conta Supabase (gratuita)
- Uma conta Google Cloud (gratuita)
- Uma conta Vercel (gratuita)
- Uma conta GitHub (gratuita)
- Domínio próprio (opcional; Vercel dá subdomínio grátis)
- Logo da marcenaria em SVG (preferencialmente monocromático)
- Paleta de cores da marca (2–3 cores base)

---

## 1. Visão geral

Sistema de gestão interna para uma marcenaria de móveis planejados. Substitui planilhas espalhadas, WhatsApp para lembrete e "está aqui" para "sei onde está".

### Personas
- **Gestor (proprietário/gestora):** dono da conta, vê tudo, toca em tudo.
- **Colaborador (marceneiro/instalador):** vê só as etapas atribuídas a ele, muda status dela.

### Funcionalidades principais
1. Cadastro e acompanhamento de projetos (do cliente à instalação)
2. Kanban de produção com etapas customizáveis por projeto
3. Gestão financeira (contratos, parcelas, custos por camada)
4. Agenda integrada ao Google Calendar (bidirecional real)
5. Relatório para o cliente em PDF e HTML compartilhável via WhatsApp
6. Painel diário do colaborador (mobile-first) com foco na etapa atual
7. Meu Dia — visão consolidada de todas as etapas ativas em todos os projetos

### Não é
- Não é ERP. Sem NF-e, sem estoque profundo, sem folha de pagamento.
- Não é CRM. Sem funil de vendas, sem prospecção.
- Não é software de projetação. Sem CAD, sem cortes automáticos.

Se você precisa de algo dessa lista, use as ferramentas certas e integre depois.

---

## 2. Stack e decisões arquiteturais

### Stack final
- **Frontend:** HTML + CSS + JavaScript vanilla em **um único arquivo `index.html`** de ~13.000 linhas. Nada de React, Vue, Next. Zero build step. Vite serve o arquivo como dev server, e a Vercel serve como HTML estático.
- **Banco:** Supabase Postgres com RLS. Realtime opcional para etapas.
- **Auth:** Supabase Auth (email + senha).
- **Integrações:** Google Identity Services para OAuth do Calendar; Google Calendar API v3 para eventos.
- **Deploy:** GitHub → Vercel (deploy automático a cada push em `main`).

### Por que arquivo único
- **Onboarding:** o único jeito de fazer com que outra pessoa entenda o sistema em 30 minutos é ela conseguir ler todo o código de uma vez. Framework SPA obriga navegar por 40 arquivos para entender um botão.
- **Zero build friction:** dev abre `npm run dev` e edita. Não tem "cannot find module", não tem "peer dependency mismatch", não tem "run npm audit".
- **Vercel serve como estático:** custo 0, deploy em 15 segundos, edge cache automático.
- **Trade-off aceito:** o arquivo é grande. Se crescer além de 20k linhas, dividir por seções com `<script src=...>`, sem framework. Até lá, `<script>` inline.

### Por que Supabase
- Postgres real (não NoSQL).
- RLS embarcado — segurança fica no banco, não no app.
- Auth pronto.
- Realtime nativo com WebSocket.
- Storage para arquivos.
- Alternativa se não puder usar Supabase: Neon + Auth.js + Uploadthing. Mais peças, mais falhas.

### Por que sem build step no frontend
Você não precisa de tree-shaking em um app de 13k linhas que carrega uma vez. HTTP/2 + gzip resolvem. O único build que faz sentido é o do Vite quando ele injeta `import.meta.env` — e ele faz isso mesmo sem `vite.config.js`.

---

## 3. Design system

O sistema é sóbrio, elegante, sem chamar atenção para si — porque quem usa é uma pessoa cansada, no fim do dia, tomando decisões sobre dinheiro. Design que se apaga para deixar o conteúdo aparecer.

### Tipografia

Duas famílias, uma serifada e uma sans:

```html
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Fraunces:opsz,wght@9..144,340;9..144,360&family=Archivo:wght@400;450;500;600;700&display=swap" rel="stylesheet">
```

**Fraunces** (serif) é reservada para títulos com peso 340 — vira `--font-serif`. Só onde tem "voz de marca" (hero de tela, saudação, título do relatório do cliente).

**Archivo** (sans) é a família de trabalho — vira `--font-ui`. Usada em 100% do resto: botões, formulários, listas, dados.

⇢ **Se quiser trocar as fontes** para outra marcenaria: substitua Fraunces por outra serifada com peso extra-fino disponível (Frank Ruhl Libre, GT Sectra, Instrument Serif). Archivo por outra sans neutra (Inter, Söhne, Neue Haas Grotesk). Nunca use fontes de personalidade forte no corpo — o usuário vai olhar 8 horas.

### Cores

Paleta clara, tons quentes de bege/marrom com detalhe cobre. Modo escuro é opcional.

```css
:root {
  --bg: #F7F4EE;              /* fundo geral */
  --surface: #F5F1EA;         /* fundo de cards */
  --surface-2: #E8E3D5;       /* fundo de cards elevados */
  --ink: #211D19;             /* texto principal */
  --ink-muted: #6B655D;       /* texto secundário */
  --ink-subtle: #A69F94;      /* texto terciário */
  --border: #D9CDBA;
  --border-strong: #A9825A;
  --brand: #6D6250;
  --brand-ink: #F7F4EE;
  --accent: #A9825A;          /* cobre — usado com moderação */
  --accent-ink: #211D19;
  --deep: #2F332B;

  /* Semânticos */
  --status-liberado: #2F332B;
  --status-em-andamento: #A9825A;
  --status-bloqueado: #8B857D;
  --status-atrasado: #8B3A2E;
  --status-concluido: #6D6250;
  --status-critico: #3D2A24;
}
```

⇢ **Para outra marcenaria:** troque `--brand`, `--accent`, `--border-strong`. Mantenha os semânticos (`--status-*`) — eles vieram de anos de tinta em placa e são universais. Se sua marca é fria (azul/cinza), inverta os pesos: `--bg` fica levemente azulado, `--accent` vira o azul da marca.

### Espaçamento

Escala de 8 níveis, todos múltiplos de 4:

```css
--sp-1: 4px;  --sp-2: 8px;  --sp-3: 12px; --sp-4: 16px;
--sp-5: 24px; --sp-6: 32px; --sp-7: 48px; --sp-8: 64px; --sp-9: 96px;
```

**Regra prática:** 90% dos gaps são `--sp-3` ou `--sp-4`. `--sp-5` para separar seções. `--sp-6+` só em headers de tela.

### Raios e sombras

```css
--radius-sm: 4px; --radius-md: 8px; --radius-lg: 12px; --radius-xl: 20px;

--shadow-sm: 0 1px 2px rgb(33 29 25 / 0.04);
--shadow-md: 0 4px 12px rgb(33 29 25 / 0.06);
--shadow-lg: 0 12px 32px rgb(33 29 25 / 0.08);

--ease: cubic-bezier(0.25, 1, 0.5, 1);
```

### Fundos translúcidos (sidebar/navbar flutuantes)

```css
background: color-mix(in oklch, var(--surface) 96%, transparent);
backdrop-filter: saturate(180%) blur(18px);
-webkit-backdrop-filter: saturate(180%) blur(18px);
```

---

## 4. Estrutura de arquivos

```
/
├── index.html                    ← 100% do app
├── package.json                  ← só devDependency: vite
├── SIMBOLO SISTEMA .svg          ← logo (símbolo) da marca
├── LOGO ALPHA.svg                ← logo (wordmark) da marca [opcional]
├── migration.sql                 ← todas as migrations do Supabase
├── .gitignore                    ← .env.local, node_modules, dist, .DS_Store
├── .env.example                  ← template das variáveis (sem valores)
├── docs/
│   ├── BLUEPRINT.md              ← este documento
│   └── FASE-*.md                 ← propostas de refatoração
└── README.md                     ← como rodar e onde estão os valores
```

O `index.html` é composto por 4 seções que aparecem nessa ordem:

1. **`<head>`** — meta, fontes, preload do símbolo, script inline que lê `import.meta.env.VITE_*` e joga em `window.ENV_*`.
2. **`<style>` inline** (linhas ~60 a ~3800) — todo o CSS. Sem arquivo separado.
3. **`<body>`** com views — cada seção principal do sistema é uma `<section class="view" id="view-XYZ">`. Só uma tem `.active` por vez.
4. **`<script>` inline** (linhas ~6100 até o fim) — todo o JS.

---

## 5. Modelo de dados (Supabase)

### Schema `public` — 8 tabelas

**`clientes`**
```sql
create table clientes (
  id uuid primary key default gen_random_uuid(),
  nome text not null,
  cpf text,
  nascimento date,
  email text,
  telefone text,
  cep text,
  endereco text,
  created_at timestamptz default now()
);
```

**`projetos`**
```sql
create table projetos (
  id uuid primary key default gen_random_uuid(),
  codigo text not null,               -- ex: 'P-2026-836'
  cliente_id uuid references clientes(id),
  valor numeric,                      -- valor contratado
  prazo date,                         -- entrega prevista
  descricao text,
  status text default 'ativo',        -- ativo | producao | instalacao | concluido
  progresso numeric default 0,
  project_file_path text,             -- projeto/apresentação em PDF/DWG
  arquivo_url text,                   -- alias legado
  created_at timestamptz default now()
);
```

**`ambientes`** (cômodos do projeto)
```sql
create table ambientes (
  id uuid primary key default gen_random_uuid(),
  nome text not null,
  percentual numeric not null,        -- peso no cálculo de progresso
  projeto_id uuid references projetos(id),
  created_at timestamptz default now()
);
```

**`production_templates`** (catálogo de etapas padrão do fluxo de fabricação)
```sql
create table production_templates (
  id uuid primary key default gen_random_uuid(),
  stage_key text not null,            -- 'medicao', 'projeto_3d', 'compra_mdf'...
  name text not null,
  category text not null,             -- 'PRE-PRODUÇÃO', 'PRODUÇÃO', 'INSTALAÇÃO'
  description text,
  "order" integer not null,           -- 1..23 ordem no fluxo
  depends_on_order integer,
  is_required boolean default false,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);
```

Semeie com as 23 etapas do catálogo (ver seção "Semear catálogo de etapas" no README do projeto original).

**`production_tasks`** (etapas reais de cada projeto)
```sql
create table production_tasks (
  id uuid primary key default gen_random_uuid(),
  project_id uuid references projetos(id),  -- nullable: etapas "internas" da empresa
  template_id uuid references production_templates(id),
  name text not null,
  stage_key text,
  category text,
  "order" integer,
  status text not null default 'pending',   -- pending | in_progress | completed | blocked
  is_applicable boolean not null default true,
  depends_on_order integer,
  started_at timestamptz,
  completed_at timestamptz,
  notes text,
  prazo date,
  prioridade text default 'normal',         -- normal | alta
  ambiente text,                            -- cômodo (texto livre)
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  unique (project_id, "order")
);
```

**`custos`**
```sql
create table custos (
  id uuid primary key default gen_random_uuid(),
  projeto_id uuid references projetos(id) not null,
  camada text not null,               -- 'materiais' | 'mao_de_obra' | 'logistica' | ...
  item text not null,
  valor numeric not null default 0,
  data date not null,
  ambiente text,
  origem text,
  descricao text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);
```

**`parcelas_pagamento`** (recebimentos do cliente)
```sql
create table parcelas_pagamento (
  id uuid primary key default gen_random_uuid(),
  projeto_id uuid references projetos(id),
  descricao text,
  percentual numeric,
  valor_parcela numeric,
  data_pagamento date,
  comprovante_url text,
  comprovante_path text,
  pago boolean default false,
  created_at timestamptz default now()
);
```

**`compromissos`** (agenda interna, espelhada no Google Calendar)
```sql
create table compromissos (
  id uuid primary key default gen_random_uuid(),
  projeto_id uuid references projetos(id),  -- nullable: compromissos internos
  tipo text not null default 'projeto',     -- 'projeto' | 'interno'
  titulo text not null,
  data date not null,
  hora time,
  prioridade text default 'normal',
  descricao text,
  concluido boolean default false,
  concluido_em timestamptz,
  google_event_id text,                     -- id do evento no Calendar
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);
```

### Auth e RLS

**Preparado para multi-usuário via Supabase Auth** com dois papéis: gestor e colaborador. Modelo:

```sql
create table profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  nome text not null,
  role text not null check (role in ('gestor', 'colaborador')),
  ativo boolean default true,
  criado_em timestamptz default now()
);

-- Etapas atribuíveis
alter table production_tasks add column assigned_to uuid references profiles(id);
```

Policies (nível banco, não frontend):

```sql
-- Gestor faz tudo
create policy "gestor_all" on production_tasks
  for all to authenticated
  using (exists (select 1 from profiles where id = auth.uid() and role = 'gestor'))
  with check (exists (select 1 from profiles where id = auth.uid() and role = 'gestor'));

-- Colaborador vê só as próprias etapas
create policy "colab_select_proprias" on production_tasks
  for select to authenticated
  using (assigned_to = auth.uid());

-- Colaborador só altera status (não pode mudar título, prazo, etc.)
-- Regra reforçada por trigger BEFORE UPDATE que anula qualquer coluna
-- diferente de status se auth.uid() não é gestor.
```

Aplique padrão análogo em `projetos`, `custos`, `clientes`, `parcelas_pagamento`, `compromissos`: gestor faz tudo, colaborador tem SELECT negado exceto via view controlada.

⇢ **Se sua marcenaria é uma pessoa só (você)**, comece com policies `using (true)` e migre para papéis quando tiver o segundo usuário. Mas anote a data — vira dívida técnica.

### Realtime

Habilite realtime só em `production_tasks`. Isso resolve o caso "mudei uma etapa no celular no galpão, o gestor vê no escritório na mesma hora". Nas outras tabelas o custo do WebSocket não compensa.

---

## 6. Funcionalidades — uma por uma

### 6.1 Navegação e layout

- **Sidebar flutuante à esquerda** no desktop (≥721px). Ilha com 16px de margem, cantos arredondados, fundo translúcido com blur, sombra.
- **Bottom nav flutuante no mobile** (<720px). Mesma linguagem: ilha com 16px de margem, cantos arredondados, translúcida com blur. 4 destinos fixos (Painel, Projetos, Meu Dia, Financeiro) + "Mais" que abre um sheet com o resto.
- **Ambas somem** ao rolar (opacidade 55%) e voltam ao interagir ou ao parar 900ms. `:hover` só em `@media (hover: hover)` para não grudar no touch.
- **Toggle claro/escuro** no topo da sidebar (desktop) e da topbar (mobile). Persistido em `localStorage`. Bug clássico: em telefones o navegador impõe cor de tema — sempre setar `<meta name="theme-color">` para as duas variantes.

### 6.2 Painel (home do gestor)

- Saudação por horário: madrugada/manhã/tarde/noite.
- Cartão de destaque com KPI principal (ex.: total de receitas do mês, ou etapas concluídas hoje).
- Lista "Precisa da sua atenção": projetos com etapas atrasadas, sem próxima etapa definida, ou aguardando entrada financeira.
- Cada item leva ao detalhe do projeto.

### 6.3 Projetos

**Lista** — grade de cards com código, cliente, endereço, valor, progresso, prazo. Filtros: em andamento / concluídos / todos.

**Detalhe** — quatro blocos:
1. **Dados do cliente** (telefone, CPF, endereço) — grid rótulo/valor
2. **Contratos e documentos** — anexar/substituir contrato e projeto
3. **Resumo financeiro** — valor contratado, total recebido, saldo, %
4. **Entradas recebidas** — tabela editável com linhas de `parcelas_pagamento`
5. **Acompanhamento da produção** — o kanban de etapas (ver 6.4)
6. **Ambientes** — cômodos com percentual

Botões no header: **Relatório para o cliente** (ver 6.7), **Editar projeto**, **Excluir projeto**.

**Novo projeto** — wizard de 4 passos: Cliente, Projeto, Pagamento, Revisão. Cria também parcelas iniciais e cômodos.

### 6.4 Acompanhamento da produção

O núcleo operacional. Renderiza as `production_tasks` de um projeto.

**Cabeçalho:**
- Status geral ("Em produção · Acabamento fino"), pill colorida.
- Barra de progresso: 47% · 51 de 109 concluídas
- Botão "+ Nova etapa"

**Visão geral em duas colunas:**
- **Coluna esquerda** — lista rolável de cômodos com contagem `X/Y concluídas · Z%` e mini-barra. Ordenada por menor progresso (o que precisa de atenção sobe).
- **Coluna direita** — donut chart do escopo selecionado (todo o projeto ou o cômodo escolhido na esquerda), com legenda: Concluídas, Em andamento, Pendentes, Bloqueadas. Donut feito com `conic-gradient` puro, sem lib.

**Chips de filtro** — Todas · Pendentes · Em andamento · Concluídas · Prioridade alta. Paginação: 25 etapas por vez com "Mostrar mais".

**Cada etapa (linha)** — grid de 4 colunas: handle de drag · ícone de status · texto (nome, ambiente, categoria, badges de prazo/prioridade) · ações (↑↓, Editar, Não se aplica/Aplicar, Iniciar/Concluir/Reabrir).

**Drag & drop** entre etapas (desktop). No mobile some, botões ↑↓ ficam. Reordenação faz update em duas fases no banco para não violar o índice único.

**Modal "Nova/Editar etapa"** — dois modos: "Vinculada a um projeto" ou "Interna". Campos: nome, projeto (se vinculada), ambiente (sugestões dos cômodos existentes), status, categoria, prazo (date), prioridade (normal/alta), observações. Sem sugestões de autocomplete no nome — usuário reclamou que atrapalhava.

### 6.5 Meu Dia (fluxo de produção geral)

Visão consolidada de todas as etapas ativas de todos os projetos, agrupadas por etapa do fluxo (kanban horizontal no desktop, acordeão vertical no mobile — antes rolava 90k px de altura, virou 6k).

- **Painel de status** — atrasadas, vencem hoje, em andamento, prioridade alta, concluídas hoje. Cada uma é um botão que filtra o board.
- **Foco agora** — cards da etapa em andamento + próximas pendentes.
- **Compromissos do dia** — do Supabase, sincronizados com Google Calendar.
- **Etapas internas** — trabalho da empresa fora do pipeline (comprar prego, atender fornecedor).
- **Board** — colunas por etapa do fluxo. No mobile vira acordeão fechado com busca por cômodo/cliente/código e botão "Expandir tudo".

### 6.6 Financeiro

Três camadas:

1. **Receitas por projeto** — soma das `parcelas_pagamento` com `pago = true`.
2. **Custos por camada e projeto** — CRUD completo. Camadas: materiais, mão de obra, logística, terceirizados, outros.
3. **Consolidado da empresa** — filtros: mês, ano, tudo. Compara receita vs custos totais. Margem média.

Tabela responsiva: no mobile a tabela rola horizontalmente em vez de espremer.

### 6.7 Relatório para o cliente

O toque de brilho para o cliente. Botão "Relatório para o cliente" no detalhe do projeto abre um modal com:

- **Painel de edição à esquerda** — título, mensagem de abertura (pré-preenchida com saudação completa: `"Olá, <cliente>. Este é o relatório de andamento do seu projeto..."`), data prevista de entrega (com cálculo automático de dias restantes: "Faltam 30 dias", "É hoje", "3 dias de atraso"), fotos (galeria ou câmera do celular; imagens reduzidas a 1100px/72% no canvas antes de guardar), seções ligáveis (resumo, ambientes, concluídas, próximas, financeiro — este último desmarcado por padrão), observações, assinatura.

- **Pré-visualização A4 à direita** — é o mesmo nó que vai impresso. O que se vê é o que sai.

Três saídas:
1. **Gerar PDF** — `window.print()` com `@media print` dedicado. Nome do arquivo padrão: `STATUS PROJETO - CLIENTE - ALPHA PLANEJADOS - DATA POR EXTENSO` (o navegador usa `document.title`, trocado durante impressão e restaurado depois).
2. **Baixar HTML** — arquivo autocontido com CSS embutido, logo em SVG inline, fotos em base64. ~21KB sem fotos.
3. **Enviar no WhatsApp** — no celular usa `navigator.share` com o arquivo (o WhatsApp pergunta a conversa). No desktop baixa o arquivo e abre `wa.me/<telefone_cliente>` com mensagem pronta.

### 6.8 Agenda

- Visão semanal / mensal / lista, semelhante ao Google Calendar.
- Cria compromisso local; se sincronização estiver ligada, cria também no Google Calendar (bidirecional).
- Compromisso pode ser vinculado a projeto ou interno.
- Prioridade e conclusão.

### 6.9 Google Calendar (o "definitivo")

OAuth 2.0 via Google Identity Services (GIS), scope `calendar.events + userinfo.email`. Detalhes na seção 7.

### 6.10 Painel do colaborador (mobile-first)

Tela separada, tema escuro, para o marceneiro/instalador ver o dia. Cai direto no login → `#meu-dia`.

- Saudação contextual.
- Barra "Progresso do dia" (X de Y concluídas).
- Filtros Hoje / Esta semana / Tudo (por `prazo` da etapa).
- **Foco agora** — etapa em andamento OU mais urgente pendente.
- Lista agrupada por projeto.
- Modal ao tocar etapa: metadados read-only + botões de status (Começar / Concluir / Pausar / Reabrir).
- Guardrail "só uma em andamento por vez".
- Botão sticky no rodapé: "Falar com Jhonata no WhatsApp".
- Nada de financeiro, contratos, valores, dados do cliente.

Ver arquivo `prototipo_painel_colaborador.html` no repositório original para o desenho aprovado.

### 6.11 Tela de entrada (welcome)

Aparece uma vez por dia. Palco escuro da marca:
- Símbolo se desenha em dourado, ganha preenchimento.
- Saudação entra palavra por palavra, nome em itálico dourado.
- Três números do dia contam do zero.
- Botão "Entrar no sistema" com brilho passando.
- Enter/Esc entram.
- Saída: conteúdo recua, palco sobe como cortina.
- Movimento reduzido: tudo aparece de uma vez.

---

## 7. Integrações externas

### 7.1 Google Calendar (sessão contínua sem servidor)

O truque decisivo. OAuth implicit no navegador dá token de 1h sem refresh — parece impossível ter sessão que dura. **Mas dá.**

**Como:** `google.accounts.oauth2.initTokenClient({ ... })` permite `requestAccessToken({ prompt: '', hint: email })`. Se o usuário continua logado no Google no navegador, o token renova sem popup em ~200ms. É o mesmo mecanismo do Gmail e do Google Meet.

**Implementação:**
1. Timer agenda renovação 5 min antes de expirar (`agendarRenovacaoToken`).
2. `setInterval` de 60s como rede de segurança para laptops que dormem.
3. `visibilitychange` revalida ao voltar para a aba.
4. Wrapper `_fetchGoogle(url, opts)` injeta o `Authorization`; se voltar 401, renova e refaz.
5. `restaurarSessaoGoogle()` na inicialização tenta renovação silenciosa antes de desconectar.

**Setup no Google Cloud (obrigatório para funcionar):**
1. Criar projeto no Google Cloud Console.
2. APIs & Services → Credentials → Create Credentials → OAuth Client ID → Web application.
3. Authorized JavaScript origins: adicionar `http://localhost:5173` e a URL da Vercel.
4. **OAuth consent screen → Publishing status: In production.** Se ficar em "Testing", força reautorização a cada 7 dias, e a renovação silenciosa falha. Ignore o aviso amarelo de "Seu aplicativo precisa ser verificado" — é opcional para uso interno.
5. Adicionar o Client ID no `.env.local` e nas env vars da Vercel como `VITE_GOOGLE_CLIENT_ID`.

**Escopos:** `https://www.googleapis.com/auth/calendar.events` e `https://www.googleapis.com/auth/userinfo.email`. Nada mais.

**Um limite honesto:** sessão é por navegador. Se você usa no Mac e no iPhone, cada um autoriza uma vez. Se quiser sessão realmente perpétua entre dispositivos, precisa de backend com refresh token (Supabase Edge Function). Não implementado, mas o gancho está lá.

### 7.2 WhatsApp

Sem API. Só links `wa.me/<numero>?text=<mensagem_urlencoded>`. O `<numero>` vem de `profiles.telefone` do gestor (para o colaborador falar com ele) ou de `clientes.telefone` (para o gestor mandar o relatório).

No celular usamos `navigator.share({ files, title, text })` — abre a folha do sistema e o WhatsApp pergunta a conversa. É o mais próximo de "escolher o cliente" que dá para fazer sem API.

---

## 8. Responsividade

Breakpoints:
- **1024px+** — desktop pleno
- **721–1024px** — tablet, sidebar mais estreita (208px)
- **≤720px** — mobile, sidebar some, bottom nav aparece
- **≤380px** — muito pequeno, tipografia e rótulos encolhem

**Regra que evita 90% dos bugs:** todo grid item que segura conteúdo precisa de `min-width: 0`. Padrão do CSS é `auto`, que impede encolher abaixo da largura do conteúdo. É o que fazia a página inteira estourar no celular.

```css
.main, .view, .painel-grid, .projetos-grid { min-width: 0; }
.detalhe-grid > *, .detalhe-grid .card, .detalhe-grid .stack { min-width: 0; }
```

**Tabelas** rolam horizontalmente dentro de um container `.tabela-scroll` em vez de espremer.

**Toques** no mobile: alvos mínimos de 34px. Chips e botões primários ≥40px.

**Safe area** do iPhone: `padding-bottom: env(safe-area-inset-bottom, 0px)` em navbar, toast, sheet.

---

## 9. Dark mode

Tokens semânticos são invertidos via `[data-theme="dark"]`. Modo escuro é opcional — usuário escolhe pelo toggle.

Regras:
- **Nunca** definir cor só dentro de `@media (prefers-color-scheme: dark)`. Definir sempre no `:root` e sobrescrever no `[data-theme="dark"]`.
- Body precisa de `background` explícito (viewer sem token pinta atrás e vaza).
- `color-scheme: light dark` no `:root`.

---

## 10. Segurança e credenciais

**Regra:** nunca comitar credenciais em texto plano no `index.html`. Mesmo a chave publishable do Supabase (que "pode ser pública") só é segura se as RLS policies estiverem gate-de-role. Enquanto forem `using (true)`, publishable = acesso total.

**Setup:**
1. Env vars na Vercel: `VITE_SUPABASE_URL`, `VITE_SUPABASE_ANON_KEY`, `VITE_GOOGLE_CLIENT_ID`. Todas em Production + Preview + Development.
2. `.env.example` no repo com placeholders. `.env.local` no `.gitignore`.
3. Script no `<head>` lê `import.meta.env.VITE_*` e joga em `window.ENV_*`.
4. `getConfig()` no runtime: `localStorage → window.ENV_* → vazio`. Sem defaults hardcoded.

**Se a chave já vazou no git público:** rotacione na Supabase (Settings → API Keys), atualize env var na Vercel, redeploy. Se as policies eram abertas, considere o banco comprometido — inspecione tabela `auth.audit_log_entries` do Supabase.

---

## 11. Gotchas (aprendizados que custaram tempo)

Cada bullet é uma tarde ou mais que perdi. Leia antes de replicar.

### 11.1 CSS

- **Grid item com `min-width: auto`** é a causa de 90% dos "por que rola de lado no celular". Fix: `min-width: 0` em `.main`, `.view`, e nos filhos de `.grid-container`.
- **`display: none` do `[hidden]`** perde para `display: flex` do container. Se usar `hidden` como boolean visual, adicionar `[hidden] { display: none !important }`.
- **`:hover` gruda em touch.** Toda regra `:hover` que precisa "desligar" ao tirar o dedo deve ficar em `@media (hover: hover)`.
- **`text-fill-color` em Safari** com fonte carregada tardiamente cria flash. Solução: `font-display: swap` + fallback de sistema no CSS.
- **`box-shadow` com `border-radius: 999px`** e `overflow: hidden` no filho causam glitch de renderização em Chrome/Safari. Preferir uma coisa ou outra.

### 11.2 JavaScript

- **`window.print()` usa `document.title` como nome do PDF sugerido.** Se você quer nome padronizado, troque `document.title` antes de chamar `print()` e restaure no `afterprint`.
- **`navigator.share` recusa `File` sem `type` correto.** Sempre setar `type: 'text/html'` explicitamente.
- **`fetch` com corpo grande em Safari mobile** trava por ~30s antes de responder. Reduzir imagens antes de enviar.
- **`localStorage` em iframe** ou em modo privado do Safari lança exceção. Sempre envolver em try/catch.
- **`scroll` events não disparam para `window.scrollTo` programático em headless browsers.** Testar dispatchando `Event('scroll')` manual.

### 11.3 Supabase

- **RLS ativo com policy `using (true)`** é apenas segurança nominal. Se ninguém vai gerar bug hoje, gera amanhã.
- **Índice único `(project_id, "order")`** obriga reordenação em duas fases: primeiro joga todos para valores altos (`20000+i`), depois assenta na ordem final.
- **`select: '*'` sem `.limit()`** pode retornar 10k+ linhas quando você espera 20. Sempre limite.
- **Realtime cobra por WebSocket ativo.** Um só é grátis; múltiplos podem ir para plano pago. Reutilize um canal para todas as tabelas se possível.

### 11.4 Google OAuth

- **Publishing status "Testing"** força re-consentimento a cada 7 dias, independentemente de qualquer código. Só "In production" resolve.
- **Origem sem barra final.** `https://alpha-sistema-six.vercel.app` — não `https://alpha-sistema-six.vercel.app/`.
- **`prompt: ''` para renovação** só funciona se o email do `hint` bate com o usuário logado no navegador.
- **`Sign in with Google` popup** falha em incognito. Sempre ter mensagem de erro amigável.

### 11.5 Vercel

- **Env vars não são aplicadas retroativamente.** Cadastrou depois do último deploy? Precisa redeployar (com "Use existing Build Cache" é rápido).
- **Preview URLs** têm o hash no domínio. Se você usar OAuth, cada preview precisa da origem cadastrada — inviável. Solução: só teste OAuth em produção ou local.

### 11.6 Impressão / PDF

- **`@media print` herda tamanhos em `rem`.** Se seu `html { font-size: 16px }` for reduzido, a impressão sai pequena. Definir tamanhos em `pt` no CSS de impressão.
- **`break-inside: avoid`** em elementos maiores que a página é ignorado. Fotos precisam ter `max-height` em mm.
- **`background-image` não imprime por padrão** no Chrome. Usuário precisa marcar "Background graphics" no diálogo. Prefira `background-color` para blocos importantes.

---

## 12. Checklist de replicação (ordem de execução)

Cada item é um marco entregável. Não pule.

**Fase preparatória:**
- [ ] Escolher nome do repositório (⇢ `nome-marcenaria-sistema`)
- [ ] Criar organização/repo no GitHub
- [ ] Criar projeto no Supabase (⇢ `nome-marcenaria`)
- [ ] Criar projeto no Google Cloud, OAuth Client ID Web application
- [ ] Cadastrar origens autorizadas: localhost:5173 e a futura URL da Vercel
- [ ] OAuth consent screen → Publish app → In production
- [ ] Criar projeto na Vercel apontando para o repo GitHub

**Setup do repositório:**
- [ ] `npm init -y`, `npm install --save-dev vite`
- [ ] Adicionar `"dev": "vite"` no scripts
- [ ] Criar `index.html` com o esqueleto base (head + CSS + body + views + script)
- [ ] Definir tokens de design em `:root` (⇢ trocar cores da marca)
- [ ] Substituir Fraunces + Archivo por suas fontes escolhidas (ou manter)
- [ ] Adicionar `SIMBOLO SISTEMA .svg` (o símbolo da marca) na raiz
- [ ] `.env.example` com as três variáveis vazias
- [ ] `.gitignore` completo

**Migrations do Supabase (na ordem):**
- [ ] `clientes`, `projetos`, `ambientes`, `parcelas_pagamento`
- [ ] `production_templates` (semear com 23 etapas padrão)
- [ ] `production_tasks` (com índice único (project_id, order))
- [ ] `custos`, `compromissos`
- [ ] `profiles` (para multi-user, mesmo se hoje for só você)
- [ ] Habilitar RLS em todas
- [ ] Escrever policies com gate `is_gestor()` (para começar, `using (true)` — depois refina)
- [ ] Habilitar Realtime em `production_tasks`

**Frontend, tela por tela (na ordem):**
- [ ] Layout base: sidebar flutuante + bottom nav + topbar
- [ ] View `painel` (home)
- [ ] View `projetos` (lista)
- [ ] View `novo-projeto` (wizard 4 passos)
- [ ] View `projeto-detalhe` (5 blocos + kanban de etapas)
- [ ] View `custos` (financeiro)
- [ ] View `chao` (Meu Dia — kanban geral, acordeão mobile)
- [ ] View `agenda`
- [ ] View `configuracao`
- [ ] Modal de nova/editar etapa
- [ ] Modal de novo compromisso
- [ ] Modal do relatório para o cliente
- [ ] Tela de welcome com animação

**Integrações:**
- [ ] Google Identity Services carregado no `<head>`
- [ ] `initGoogleAuth`, `_pedirTokenGoogle`, `renovarTokenGoogleSilencioso`, `_fetchGoogle`
- [ ] Timer de renovação + visibilitychange
- [ ] Pull de eventos a cada 10min
- [ ] CRUD de compromissos com espelhamento no Calendar

**Segurança:**
- [ ] Env vars cadastradas na Vercel (3 vars, 3 environments cada)
- [ ] Nenhum default hardcoded no `index.html`
- [ ] Rotacionar chaves publishable se foram expostas em algum momento

**Auth (opcional na V1, obrigatório na V2):**
- [ ] Substituir welcome por tela de login
- [ ] Roteamento por `profiles.role`
- [ ] Painel do colaborador (`#meu-dia`)
- [ ] CRUD de colaboradores na aba Equipe
- [ ] Testar policies com token de colaborador — não pode ver dados de outros

**Deploy:**
- [ ] Push para `main`
- [ ] Vercel builda automaticamente
- [ ] Testar em produção: cadastrar projeto, criar etapa, conectar Google, gerar relatório

---

## 13. Valores da sua marcenaria

Preencha aqui antes de mandar para IA de código executar. Cada `⇢` é uma decisão sua.

- ⇢ **Nome da marcenaria:** `_______________`
- ⇢ **Slogan curto** (aparece na tela de welcome): `_______________`
- ⇢ **Cor principal (brand):** `#______`
- ⇢ **Cor de acento (dourado/cobre equivalente):** `#______`
- ⇢ **Fontes** (se mudar): Serif `_______________` / Sans `_______________`
- ⇢ **URL da Vercel** (produção): `https://______.vercel.app`
- ⇢ **Telefone do gestor** (para WhatsApp do colaborador): `+55 ___________`
- ⇢ **Nome do gestor** (aparece na saudação): `_______________`
- ⇢ **Etapas padrão do fluxo** (as 23 da Alpha estão em `migration.sql`, seção "seed production_templates"):
  - Você quer as mesmas? `Sim / Não`
  - Se não, liste as suas na ordem: `_______________`

---

## 14. Um pedido honesto para a IA que vai executar isto

Antes de escrever qualquer linha:

1. **Leia inteiro este documento.** Não pule para "vamos começar". Muita decisão aqui depende de decisão que veio antes.
2. **Confirme com o usuário** os valores `⇢` da seção 13 antes de tocar em código.
3. **Faça o setup na ordem da seção 12.** Cada marco é entregável. Não avance sem checkpoint.
4. **Antes de escrever CSS, escreva os tokens.** Antes de escrever HTML, escreva a estrutura de views. Antes de escrever JS, mapeie os handlers.
5. **Teste em 375px** enquanto codifica cada tela. Se não funciona no celular, refaça.
6. **Não invente frameworks.** O sistema é vanilla por decisão consciente. Se sentir tentação de trazer React, releia a seção 2.

Boa construção.
