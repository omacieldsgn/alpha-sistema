# Alpha Móveis — Design Tokens & Regras (v1)

> Documento de orientação para produção. Usado primeiro para orientar a construção da proposta comercial da Alpha. Contém apenas o que está confirmado nos arquivos-fonte; pendências marcadas como `[FALTA]` ou `[DECIDIR]`.

---

## 1. Cor

Paleta extraída do catálogo de MDF da Alpha. Percentual = proporção sugerida de uso.

| Token | Nome | Hex | Papel | Uso |
|---|---|---|---|---|
| `grafite` | Grafite Alpha | `#211D19` | Base escura | 30% |
| `branco` | Branco Texturizado | `#F7F4EE` | Base clara | 30% |
| `taupe` | Taupe Lobo | `#6D6250` | **Cor da marca** | 20% |
| `tauari` | Tauari | `#A9825A` | Acento quente | 10% |
| `areia` | Areia Guararapes | `#D9CDBA` | Neutro suave | 8% |
| `floresta` | Floresta | `#2F332B` | Profundidade | 2% |
| `azul-astral` | Azul Astral | `#33506B` | Apoio interno de documentos — **nunca cor de marca** | — |

- Taupe Lobo `#6D6250` extraído direto do vetor original = cor da marca confirmada.
- Wordmark atual usa cinza `#383838`; proposta migra para Grafite `#211D19`. `[DECIDIR com cliente]`
- Rosa: fora da paleta.
- `paper` recomendado para fundos de documento: `#F5F1EA`.

## 2. Contraste (WCAG, calculado)

Regra: corpo ≥ 4,5:1 · título grande ≥ 3:1.

| Texto / Fundo | Ratio | Uso |
|---|---|---|
| Grafite / Branco | 15,3 | corpo ✓ |
| Areia / Grafite | 10,7 | corpo ✓ |
| Branco / Floresta | 11,7 | corpo ✓ |
| Branco / Taupe | 5,5 | corpo ✓ |
| Grafite / Tauari | 4,8 | corpo ✓ |
| Tauari / Branco | 3,2 | **só título grande** |
| Branco / Tauari | 3,5 | **evitar** |
| Taupe / Grafite | 2,8 | **evitar** |

**Regra dura:** texto sobre Tauari e Areia sempre em Grafite, nunca em branco. Taupe nunca como texto sobre Grafite.

## 3. Tipografia

| Papel | Fonte | Peso |
|---|---|---|
| Display / títulos | Fraunces (serif) | 340–360 |
| Corpo / dados | Archivo (sans) | 400–500 |
| Nome da marca (texto) | Archivo | 600 |
| Legenda / rótulo | Archivo caixa alta, tracking `.14em` | 400 |

- Comprimento de linha: 65–75 caracteres.
- Fonte real da marca é **Glancyr** (Regular + ExtraLight), identificada no PDF original. `[FALTA arquivo de fonte]` — Fraunces/Archivo são o par de sistema até a Glancyr ser disponibilizada e licenciada para digital.

## 4. Símbolo — construção

- Caminho único monolinear fechado; o losango central é a autointerseção do traço, não um elemento desenhado.
- Grade de construção: **30° / 60°** a partir da vertical.
- Proporção do símbolo: ≈ 1,04 : 1 (L : A).

| Métrica | Oficial atual | Revisado (proposta) |
|---|---|---|
| Cor | `#6D6250` Taupe | `#9E7A46` Corten |
| Altura da perna | 91,1% | 99,4% |
| Losango central | 29,3% | 34,0% |
| Arquivo | `SIMBOLO.svg` | `novo.svg` |

`[DECIDIR]` qual geometria é a canônica antes de aplicar em escala.

## 5. Elemento de assinatura

Zigue-zague angular derivado dos mesmos 30°/60°. Usar como divisor, textura de rodapé ou marca d'água discreta. Nunca sobre texto.

## 6. Versões do logotipo

| Versão | Arquivo | Status |
|---|---|---|
| Horizontal | `ALPHA_HORIZONTAL.svg` / `Ativo_3.svg` | ⚠ contém typo |
| Símbolo isolado | `SIMBOLO.svg` | ok |
| Negativa | derivada (símbolo em branco) | ok |
| Empilhada (principal) | — | `[FALTA vetor isolado]` |

## 7. Pendências que bloqueiam produção

1. **Typo no lockup horizontal:** "MÓVEIS PLENAJADOS" → corrigir para "PLANEJADOS" no arquivo-fonte antes de exportar qualquer peça. **Bloqueia produção.**
2. Wordmark expandido em contornos; sem fonte editável. Manter como asset fechado.
3. Área de proteção e tamanho mínimo do símbolo não especificados. Partida sugerida: margem = altura do losango; mínimo 24 px (favicon 32 px). `[CONFIRMAR]`
4. Unificar geometria oficial vs. revisada do símbolo.

## 8. Regras rápidas (do / don't)

**Fazer:** corpo em Grafite sobre claro / Areia sobre escuro · Taupe como cor institucional dominante · Tauari só em acento · manter área de proteção · Azul Astral só interno.

**Não fazer:** texto branco sobre Tauari/Areia · Taupe como texto sobre Grafite · Rosa em marca · exportar horizontal antes de corrigir typo · distorcer/rotacionar/recolorir o símbolo fora da paleta.
