# Fase 1 — Fundação de credenciais

Documento de proposta. Ler, apontar dúvidas, aprovar. Só depois do teu OK eu toco em código.

**Duração estimada:** 3 commits pequenos, cada um deployable independente. ~40 min de trabalho meu, ~10 min tuas ações na Vercel.

**Meta:** tirar as credenciais do `localStorage` e do bundle público, sem mexer em nenhum comportamento visível para o gestor. Zero risco. Se algo der errado, revert de qualquer commit desta fase volta ao estado atual em <1 min.

**O que NÃO faz parte desta fase (para não confundir):**
- Nada de Auth, nada de `profiles`, nada de RLS nova, nada de tela de login, nada de tela `Meu Dia`. Tudo isso é Fase 2+.
- Nada de rotacionar chaves. Rotação acontece na Fase 7 junto com o corte de policies.
- Nada de tela nova de "Equipe". Fase 4.

---

## O estado atual, como referência

`index.html` linhas 6183–6207:

```javascript
const CONFIG_KEY = 'alpha-sistema-config-v1';

const DEFAULT_SUPABASE_URL = 'https://zfoatchkgfkilfymtyli.supabase.co';
const DEFAULT_SUPABASE_KEY = 'sb_publishable_jlMgcpLUuLam23t0ZZW_rg_pRDQgqi-';
const DEFAULT_GOOGLE_CLIENT_ID = '';

function getConfig() {
  try {
    const local = JSON.parse(localStorage.getItem(CONFIG_KEY) || '{}');
    return {
      supabaseUrl: local.supabaseUrl || window.ENV_SUPABASE_URL || DEFAULT_SUPABASE_URL || '',
      supabaseKey: local.supabaseKey || window.ENV_SUPABASE_KEY || DEFAULT_SUPABASE_KEY || '',
      googleClientId: local.googleClientId || window.ENV_GOOGLE_CLIENT_ID || DEFAULT_GOOGLE_CLIENT_ID || '',
    };
  } catch {
    return {
      supabaseUrl: window.ENV_SUPABASE_URL || DEFAULT_SUPABASE_URL || '',
      supabaseKey: window.ENV_SUPABASE_KEY || DEFAULT_SUPABASE_KEY || '',
      googleClientId: window.ENV_GOOGLE_CLIENT_ID || DEFAULT_GOOGLE_CLIENT_ID || '',
    };
  }
}
```

Precedência hoje: **localStorage → ENV → DEFAULT hardcoded**. Como o localStorage foi salvo em algum momento no teu navegador, o app pega dali. Como os defaults existem, o app funciona em qualquer navegador limpo. É por isso que "está funcionando" hoje sem env var nenhuma na Vercel — porque a chave está literalmente escrita no `index.html` que a Vercel serve.

## Comentário sobre a nomeação de variáveis

Teu prompt original pediu `VITE_GOOGLE_OAUTH_CLIENT_ID`. O código atual usa `VITE_GOOGLE_CLIENT_ID` (linha 51). Vou manter **`VITE_GOOGLE_CLIENT_ID`** porque o código já espera esse nome; renomear obriga a mexer no `<script type="module">` do topo e não traz benefício. Se preferir a versão longa, me diga e eu troco os dois lados.

Nomes finais que vou usar:

| Env var na Vercel | Onde é lida no código |
|---|---|
| `VITE_SUPABASE_URL` | `index.html:49` |
| `VITE_SUPABASE_ANON_KEY` | `index.html:50` (com fallback `VITE_SUPABASE_KEY`, já implementado) |
| `VITE_GOOGLE_CLIENT_ID` | `index.html:51` |

---

## Commit 1 — Cadastrar as env vars na Vercel

**Só ação tua na UI, zero código.**

### Passo a passo

1. Abrir `vercel.com/maciel1/alpha-sistema/settings/environment-variables`
2. Clicar em **"Add Environment Variable"** três vezes, uma por variável:

**Variável 1**
- Key: `VITE_SUPABASE_URL`
- Value: `https://zfoatchkgfkilfymtyli.supabase.co`
- Environments: marcar as três: **Production**, **Preview**, **Development**

**Variável 2**
- Key: `VITE_SUPABASE_ANON_KEY`
- Value: `sb_publishable_jlMgcpLUuLam23t0ZZW_rg_pRDQgqi-` (a mesma que está hoje no código; ainda não vamos rotacionar)
- Environments: **Production**, **Preview**, **Development**

**Variável 3**
- Key: `VITE_GOOGLE_CLIENT_ID`
- Value: o Client ID que você já cadastrou no Google Cloud (`864307536900-veetuo1rtke46mri1f5dkpmdaqeogl7o.apps.googleusercontent.com`)
- Environments: **Production**, **Preview**, **Development**

3. **Depois de criar as três, fazer um redeploy manual** para elas entrarem em vigor no build atual:
   - Vercel → Deployments → o mais recente → clicar nos 3 pontinhos → **Redeploy**
   - Marcar "Use existing Build Cache" para ser rápido.

### Como validar (5 min)

Abrir `alpha-sistema-six.vercel.app` em uma aba anônima do Chrome, DevTools aberto:

```javascript
// Cole no console:
console.log({
  url: window.ENV_SUPABASE_URL,
  key_prefix: (window.ENV_SUPABASE_KEY || '').slice(0, 20),
  google: (window.ENV_GOOGLE_CLIENT_ID || '').slice(0, 20)
});
```

Se retornar os três valores preenchidos, deu certo. Se algum vier `undefined`, a env var não subiu e precisa refazer.

**Nada quebrou nesta etapa** — o app continua funcionando com o `DEFAULT_*` do código como antes, mesmo se as env vars estiverem erradas. É por isso que este é o passo 1 seguro.

---

## Commit 2 — Retirar os defaults hardcoded do `index.html`

Agora as env vars estão populadas na Vercel. Podemos apagar os defaults. **Se as env vars não subirem certo, é aqui que o app quebra** — daí a importância de validar o Commit 1 antes.

### Mudanças no `index.html`

**Trocar o bloco 6185–6207 por:**

```javascript
const CONFIG_KEY = 'alpha-sistema-config-v1';

// As credenciais vêm das env vars da Vercel (VITE_SUPABASE_URL,
// VITE_SUPABASE_ANON_KEY, VITE_GOOGLE_CLIENT_ID). O localStorage é
// mantido como override durante desenvolvimento local — se você abrir
// o app fora do build do Vite, pode colar credenciais na aba
// Configuração para testar; caso contrário, ficam vazias e o app
// avisa que precisa configurar.
function getConfig() {
  let local = {};
  try {
    local = JSON.parse(localStorage.getItem(CONFIG_KEY) || '{}');
  } catch { /* localStorage inválido, ignora */ }
  return {
    supabaseUrl:    local.supabaseUrl    || window.ENV_SUPABASE_URL    || '',
    supabaseKey:    local.supabaseKey    || window.ENV_SUPABASE_KEY    || '',
    googleClientId: local.googleClientId || window.ENV_GOOGLE_CLIENT_ID || '',
  };
}
```

**Motivo de manter o override do `localStorage`:** Fase 3 vai introduzir Auth. Nesse dia, alguém pode precisar apontar para um projeto Supabase de staging temporariamente. Deixar o override existir é 3 linhas de código e me dá esse plano B. Se você preferir eliminar por completo, avise.

### O que fazer com o aviso amarelo do "Wagner" (index.html:5214–5217)

Hoje diz:
> ⚠ Sobre segurança
> Estas credenciais ficam em `localStorage` do navegador. Para produção real com múltiplos usuários, migre para variáveis de ambiente no servidor. Para uso pessoal do Wagner num único dispositivo, isso é aceitável.

**Depois desta fase esse aviso está desatualizado em dois pontos:** (1) as credenciais estão em env var, não localStorage; (2) o "Wagner" é resíduo.

**Trocar por:**

```html
<div class="config-status">
  <strong>Credenciais em uso</strong>
  Estas credenciais são carregadas das variáveis de ambiente da Vercel
  (<code>VITE_SUPABASE_URL</code>, <code>VITE_SUPABASE_ANON_KEY</code>,
  <code>VITE_GOOGLE_CLIENT_ID</code>). Os campos abaixo mostram o valor
  atualmente em uso, em modo somente-leitura.
</div>
```

E trocar a classe CSS `.config-warning` (amarela de alerta) por `.config-status` (neutra, informativa) — vou reaproveitar o estilo do `.card` que já existe.

### Reformular a tela `view-configuracao` para modo somente-leitura

O prompt original pedia: "Para o gestor: manter apenas o que ainda faz sentido (status das integrações, botão de teste de conexão, informações de projeto Supabase e Google — mas em modo somente-leitura, sem input de credenciais). Para o colaborador: essa tela nem aparece no menu."

Como colaborador não existe ainda (Fase 3), nesta fase eu implemento **só a parte do gestor**. A parte de esconder do colaborador entra na Fase 3 quando o `role` já existir.

**Mudanças específicas nos inputs (index.html:5222–5242):**

- Trocar `<input type="url">` por `<input readonly>` com atributo `disabled`
- Mudar o hint de "Em Supabase → Project Settings → API → Project URL" para "Definido pela variável `VITE_SUPABASE_URL` na Vercel"
- Remover os botões **Salvar credenciais** e **Limpar** (index.html:5246, 5249). Manter apenas **Testar conexões** (index.html:5248) — esse ainda é útil.
- Remover as funções `salvarConfiguracao`, `limparConfiguracao`, `carregarConfiguracaoUI` — código morto depois desta mudança. **Confirmar:** vou deletar essas funções ou só neutralizar? Prefiro deletar.

**Nova aparência da seção Supabase:**

```html
<div class="card" style="margin-bottom: var(--sp-5);">
  <h3 class="t-h3" style="margin-bottom: var(--sp-4);">Supabase</h3>

  <div class="credential-field">
    <div class="field-label">Project URL</div>
    <input type="text" class="input" id="cfg-supabase-url" readonly disabled>
    <div class="field-hint">Definido por <code>VITE_SUPABASE_URL</code> na Vercel</div>
  </div>

  <div class="credential-field">
    <div class="field-label">Publishable key</div>
    <input type="text" class="input" id="cfg-supabase-key" readonly disabled>
    <div class="field-hint">Definido por <code>VITE_SUPABASE_ANON_KEY</code> na Vercel · esta chave pode ser pública quando as RLS policies estão configuradas</div>
  </div>
</div>
```

Idem para a seção Google Cloud OAuth.

Uma função sobrevive: `testarConexoes()` (index.html:6250-6270 mais ou menos). Ela roda um `supabase.from('projetos').select('id').limit(1)` e um check no `window.google?.accounts`. Fica.

### Ajuste no boot

`carregarConfiguracaoUI()` é chamada no `window.load` (index.html:9027 e adjacências). Se ela desaparecer, o boot quebra. Vou substituir por uma versão nova, curta, que **só preenche os inputs disabled com os valores atuais** para exibição:

```javascript
function carregarConfiguracaoUI() {
  const cfg = getConfig();
  const url = document.getElementById('cfg-supabase-url');
  const key = document.getElementById('cfg-supabase-key');
  const gid = document.getElementById('cfg-google-client-id');
  // Mascarar as chaves — mostrar só prefixo e últimos 4 chars.
  const mascara = s => s ? s.slice(0, 12) + '…' + s.slice(-4) : '(não definido)';
  if (url) url.value = cfg.supabaseUrl || '(não definido)';
  if (key) key.value = cfg.supabaseKey ? mascara(cfg.supabaseKey) : '(não definido)';
  if (gid) gid.value = cfg.googleClientId ? mascara(cfg.googleClientId) : '(não definido)';
}
```

**Motivo da máscara:** mesmo sendo publishable, evita a chave aparecer inteira em screenshot casual.

### Como validar (10 min)

1. `npm run dev` local. Como `.env` local não existe, `window.ENV_*` é `undefined`. Como os defaults foram removidos, `getConfig()` retorna vazio. **Espera-se:** o app carrega, mostra "(não definido)" nos campos, e o boot do Supabase falha silenciosamente (já tem `if (!cfg.supabaseUrl || !cfg.supabaseKey) return;`). Nenhuma tela crashar.

2. Criar `.env.local` com as três vars, reiniciar `npm run dev`. Testar tudo:
   - Painel carrega com projetos ✓
   - Detalhe de projeto abre ✓
   - Google Agenda conecta ✓
   - Novo projeto cria ✓

3. Só depois de tudo verde, push do commit. A Vercel builda com as env vars que estão lá desde o Commit 1 e o app em produção continua funcionando.

---

## Commit 3 — Documentar as env vars no README e criar `.env.example`

Higiene. Não quebra nada e torna o setup replicável.

### `.env.example` (novo arquivo na raiz)

```env
# Copie este arquivo para .env.local e preencha com valores reais.
# O .env.local está no .gitignore e nunca sobe para o git.

# Supabase (Settings > API Keys > Publishable and secret API keys)
VITE_SUPABASE_URL=https://xxxxxxxxxxxx.supabase.co
VITE_SUPABASE_ANON_KEY=sb_publishable_xxxxxxxxxxxxxxxxxxxxxxxxxx

# Google Cloud OAuth (Credentials > OAuth 2.0 Client IDs > Web application)
VITE_GOOGLE_CLIENT_ID=xxxxxxxxxxxxxx.apps.googleusercontent.com
```

### `.gitignore`

Confirmar que `.env` e `.env.local` estão lá (já estão, verifiquei no relatório).

### README.md (adicionar seção "Como rodar localmente")

Bloco novo ou substituir se já houver:

```markdown
## Rodar localmente

1. `npm install`
2. Copiar `.env.example` para `.env.local` e preencher com as credenciais
   reais (peça ao gestor).
3. `npm run dev` — abre em http://localhost:5173

Em produção (Vercel), as mesmas variáveis são configuradas em
Project Settings → Environment Variables.
```

---

## Sequência exata dos commits

1. **[você]** Cadastrar as 3 env vars na Vercel + redeploy. Validar no console em produção.
2. **[eu]** Commit `refactor: credenciais vem de env vars; remove defaults hardcoded` — mudanças descritas no Commit 2. Você faz push. Vercel builda. Você valida com o smoke test do fim desta seção.
3. **[eu]** Commit `docs: .env.example e instrucoes de setup local`. Vercel builda (a mudança não afeta build). Fim da fase.

## Smoke test do fim da Fase 1

Depois do push do Commit 2:

- [ ] Produção carrega sem erro no console
- [ ] Painel mostra os 5 projetos existentes
- [ ] Abrir um projeto lista as etapas dele
- [ ] Google Agenda mostra "Conectado — renovação automática ativa"
- [ ] Aba Configuração mostra os três campos preenchidos, todos disabled, com máscara
- [ ] Aviso amarelo do "Wagner" desapareceu, substituído pela caixa neutra
- [ ] Não há mais nenhuma ocorrência de "Wagner" no bundle. `curl https://alpha-sistema-six.vercel.app/ | grep -i wagner` deve retornar vazio
- [ ] Não há mais `sb_publishable_` literal no HTML servido. `curl https://alpha-sistema-six.vercel.app/ | grep -o 'sb_publishable_[a-zA-Z0-9_-]*'` retorna vazio
- [ ] Meu Dia continua funcionando
- [ ] Financeiro continua funcionando
- [ ] Novo projeto cria projeto e persiste

Se **qualquer** desses falhar, revert do commit + investigação antes de seguir para Fase 2.

## Estado depois da Fase 1

- Bundle da Vercel não contém mais URL ou chave do Supabase
- Aba Configuração vira dashboard read-only de status de credenciais
- Referência ao "Wagner" desaparece
- Comportamento visível ao gestor: **idêntico ao de antes**. Nenhum novo botão, nenhuma nova tela, nenhum novo passo de login.
- Zero mudança no banco de dados. Zero mudança nas RLS policies. Zero Auth ativado.

## Perguntas para você responder antes de eu executar

1. **Nome da env var do Google:** manter `VITE_GOOGLE_CLIENT_ID` (o que o código já usa) ou renomear para `VITE_GOOGLE_OAUTH_CLIENT_ID` (o que você pediu no prompt)?
2. **Override via localStorage:** manter como plano B para debug local, ou eliminar por completo?
3. **Funções mortas** (`salvarConfiguracao`, `limparConfiguracao`): deletar do arquivo, ou deixar comentadas por segurança?
4. **README:** já existe? Vou criar do zero ou você tem um base para eu mesclar?

Responde 1, 2, 3, 4 e me diz "avança" que eu escrevo o código.
