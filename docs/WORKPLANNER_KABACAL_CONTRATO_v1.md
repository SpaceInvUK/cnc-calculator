# WorkPlanner ⇄ Kabacal — Contrato de Integração v1

**Para quem:** Rodrigo / Codex, que está construindo a API do WorkPlanner.
**O que é:** a especificação mínima do lado WorkPlanner para que o Kabacal (o app de CNC da FAST CNC) consiga (a) abrir um job já preenchido e (b) devolver quantidades, materiais, área, valor e arquivos de produção — automaticamente.
**Escrito em:** 2026-07-21, a partir do levantamento dos campos reais da UI do WorkPlanner (`data-field` do DOM) e do que o Kabacal já produz hoje.

---

## 0. Contexto em 10 linhas

- O **Kabacal** é o app de orçamento/nesting/CAM da FAST CNC. Já roda **headless** (sem navegador) e já gera, sozinho, a partir de um pedido: `.fastcnc` (o job reabrível), **DXF por espessura**, **NC por chapa**, PDF de orçamento e cut list.
- Isso **já está em produção** para os pedidos do site: o WooCommerce chama uma Edge Function no Supabase do Kabacal, que roda o motor e devolve os arquivos + e-mail. Ou seja: o padrão "recebe pedido → gera arquivos" já existe e funciona.
- O que falta é o **outro canal de entrada**: os jobs que nascem de e-mail/WhatsApp e vivem no WorkPlanner.
- Hoje o projeto Supabase do WorkPlanner (`dtxomecpeykpeghhfkxn`) está **vazio**: nenhuma tabela, nenhum bucket, nenhuma função, zero requisições. Este documento é o que precisa existir lá.
- Os arquivos dos clientes ficam no **Google Drive da conta info@**, uma pasta por Reference (ex.: `LEE290626`). Isso **não muda** — o Drive continua sendo a entrada humana.

---

## 1. Regras invioláveis

1. **A `reference` é a chave canônica.** Formato atual: `CLIENTE+DDMMYY`, ex. `PARTRIDGE170426`, `CVH140426-2`. Nada de inventar um segundo ID. O Kabacal passa a usar essa string como número de ordem dele.
2. **Um campo, um dono.** Nenhum campo pode ser escrito pelos dois lados. A tabela de propriedade está na §4. O Kabacal escreve numa tabela própria (`job_analysis`), nunca por cima do que um humano digitou.
3. **Dinheiro: rascunho ≠ aprovado.** O Kabacal calcula `quote_draft`. Quem grava `quote_value` (o valor que vale) é sempre uma pessoa no WorkPlanner.
4. **O que o Kabacal não reconhecer, ele deixa em branco** e escreve um aviso no diálogo do job. Nunca chuta.
5. **Nenhuma chave secreta no frontend.** A publishable pode; a `service_role` nunca. A ponte usa credencial própria (§5).
6. **Nada é marcado como "cortado/concluído" automaticamente.** O Kabacal pode marcar "arquivos prontos"; concluir é ação humana.

---

## 2. Esquema SQL (o que criar)

Schema sugerido: `ops`. (Se preferir `public`, tudo bem — só manter consistente.)

```sql
create schema if not exists ops;

-- ─────────── JOBS: espelha exatamente as colunas da UI ───────────
create table ops.jobs (
  id             uuid primary key default gen_random_uuid(),
  reference      text not null unique,          -- ★ PARTRIDGE170426 — chave canônica
  name           text not null,                 -- "CVH Alex Carter Slim shaker doors and panels"
  customer_name  text,
  customer_email text,
  customer_phone text,
  created_by     text,                          -- coluna "Created by"
  people         text[] default '{}',           -- coluna "People"
  status         text,                          -- vocabulário fixo, §6
  quote_status   text,                          -- coluna "Quote / Invoice"
  quote_value    numeric(10,2),                 -- valor APROVADO (humano)
  sched_start    date,                          -- coluna "Sched start"
  completion     date,                          -- coluna "Completion"
  delivery_note  text,                          -- coluna "Delivery" (texto livre hoje)
  drive_folder   text,                          -- ID/URL da pasta no Drive (= reference)
  archived       boolean not null default false,
  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now()
);

-- ─────────── SUBITENS: as 5 etapas fixas de produção ───────────
create table ops.job_subitems (
  id         uuid primary key default gen_random_uuid(),
  job_id     uuid not null references ops.jobs(id) on delete cascade,
  stage      text not null,        -- QUOTE | DESIGN | PROGRAMMING | CNC CUTTING | MATERIALS ORDER
  status     text,                 -- mesmo vocabulário da §6
  text       text,
  date       date,
  position   int not null default 0,
  updated_at timestamptz not null default now(),
  unique (job_id, stage)
);

-- ─────────── DIÁLOGO: o briefing do cliente (coluna ◌N) ───────────
create table ops.job_updates (
  id         uuid primary key default gen_random_uuid(),
  job_id     uuid not null references ops.jobs(id) on delete cascade,
  author     text not null,        -- 'Josiane' | 'kabacal' | 'whatsapp' | 'email'
  source     text,                 -- whatsapp | email | manual | kabacal
  body       text not null,
  created_at timestamptz not null default now()
);

-- ─────────── ARQUIVOS: entrada (Drive) e saída (gerados) ───────────
create table ops.job_files (
  id          uuid primary key default gen_random_uuid(),
  job_id      uuid not null references ops.jobs(id) on delete cascade,
  kind        text not null,       -- input | dxf | nc | fastcnc | quote_pdf | cutlist_pdf | labels | zip
  filename    text not null,
  storage     text not null,       -- 'drive' | 'supabase'
  location    text not null,       -- fileId do Drive OU caminho no bucket
  bytes       bigint,
  revision    int not null default 0,
  created_at  timestamptz not null default now()
);

-- ─────────── RESULTADO DO KABACAL: só a ponte escreve ───────────
create table ops.job_analysis (
  id              uuid primary key default gen_random_uuid(),
  job_id          uuid not null references ops.jobs(id) on delete cascade,
  revision        int  not null default 0,        -- R0, R1, R2…
  status          text not null default 'queued', -- queued|running|complete|failed
  quantity_text   text,          -- "20 parts · 5 doors"
  material_text   text,          -- "MDF Hidrofugo Plus 18mm"
  machine         text,          -- "Router A" | "Parkin M2"
  finish_text     text,          -- "Spray white · 2 faces"
  area_m2         numeric(8,2),  -- ★ alimenta a coluna "Area (m²)" que hoje vive vazia
  sheets          int,
  waste_pct       numeric(5,2),
  machine_minutes int,
  quote_draft     numeric(10,2), -- RASCUNHO — nunca vira quote_value sozinho
  parts_count     int,
  warnings        jsonb default '[]'::jsonb,
  engine_version  text,
  error           text,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now(),
  unique (job_id, revision)
);

-- ─────────── FILA DE EVENTOS: quem avisa quem ───────────
create table ops.job_events (
  id          bigserial primary key,
  job_id      uuid not null references ops.jobs(id) on delete cascade,
  event       text not null,   -- job.ready_for_analysis | kabacal.analysis_complete | ...
  payload     jsonb not null default '{}'::jsonb,
  consumed_at timestamptz,
  created_at  timestamptz not null default now()
);
create index on ops.job_events (event, consumed_at) where consumed_at is null;
```

**View para a UI** (para o board ler tudo de uma vez, sem o risco de escrever no que não é dele):

```sql
create view ops.jobs_board as
select j.*,
       a.quantity_text, a.material_text, a.machine, a.finish_text,
       a.area_m2, a.sheets, a.waste_pct, a.machine_minutes,
       a.quote_draft, a.warnings, a.status as analysis_status, a.revision
from ops.jobs j
left join lateral (
  select * from ops.job_analysis x
  where x.job_id = j.id order by x.revision desc limit 1
) a on true;
```

---

## 3. Fluxo

```
WhatsApp / e-mail / telefone
        │
        ▼
WorkPlanner  →  cria ops.jobs (reference, name, cliente, material desejado…)
        │       cria os 5 ops.job_subitems
        │       registra o briefing em ops.job_updates
        │       aponta drive_folder = pasta /REFERENCE/ no Drive
        │
        ▼  insere evento
ops.job_events  { event: 'job.ready_for_analysis', job_id, revision: 0 }
        │
        ▼  (a ponte do lado Kabacal LÊ esta fila — conexão sempre de fora para dentro)
Kabacal  →  abre o job com cliente/reference/material/desenhos já preenchidos
        │   gera .fastcnc + DXF + NC + PDFs
        │
        ▼  escreve
ops.job_analysis (uma linha por revisão)  +  ops.job_files  +  ops.job_updates (avisos)
        │
        ▼  insere evento
ops.job_events  { event: 'kabacal.analysis_complete' }
        │
        ▼
WorkPlanner mostra quantity / material / machine / finish / area / quote_draft
            e move os subitens (QUOTE → Quoted, PROGRAMMING → Completed…)
```

**Assíncrono de verdade:** o WorkPlanner **nunca** fica esperando resposta. Ele insere o evento e segue. Se o computador do Kabacal estiver desligado, o job simplesmente fica `queued` até alguém ligar.

---

## 4. Quem escreve o quê

| Campo | Dono | Observação |
|---|---|---|
| `reference`, `name`, `customer_*` | **WorkPlanner** | reference é imutável depois de criada |
| `people`, `created_by` | **WorkPlanner** | |
| `status`, `quote_status`, `quote_value` | **WorkPlanner** | aprovação é sempre humana |
| `sched_start`, `completion` | **WorkPlanner** | o Kabacal só sugere via `machine_minutes` |
| `delivery_note` | **WorkPlanner** | |
| `drive_folder` | **WorkPlanner** | |
| `job_analysis.*` | **Kabacal** | a UI só lê |
| `job_files` (kind=input) | **WorkPlanner** | arquivos do cliente |
| `job_files` (demais kinds) | **Kabacal** | arquivos gerados |
| `job_updates` | **ambos** | append-only; nunca editar mensagem alheia |
| `job_subitems.status` | **ambos** | Kabacal só marca as etapas que ele executa (§7) |

---

## 5. Credencial da ponte (importante — não envolve senha de ninguém)

A ponte do lado Kabacal precisa de acesso de máquina. **Não é preciso compartilhar login do dashboard.** Criar, no projeto do WorkPlanner:

1. Um usuário dedicado no Auth: `bridge@fastcnc.co.uk` (senha forte, gerada, entregue por canal seguro — nunca por chat).
2. Uma role/claim para ele (ex.: `app_metadata.role = 'bridge'`).
3. Políticas RLS que deem a esse usuário: **leitura** em `jobs`, `job_subitems`, `job_updates`, `job_files`, `job_events`; **escrita** em `job_analysis`, `job_files`, `job_updates`, `job_events`; **nenhuma** escrita em `jobs`.
4. RLS ligada em todas as tabelas, com política de leitura para os usuários do WorkPlanner e nada para `anon`.

Exemplo:

```sql
alter table ops.jobs enable row level security;
alter table ops.job_analysis enable row level security;
-- … idem nas demais

create policy bridge_read_jobs on ops.jobs
  for select using ((auth.jwt() -> 'app_metadata' ->> 'role') = 'bridge');

create policy bridge_write_analysis on ops.job_analysis
  for all using ((auth.jwt() -> 'app_metadata' ->> 'role') = 'bridge')
         with check ((auth.jwt() -> 'app_metadata' ->> 'role') = 'bridge');
```

**Alternativa mais simples:** uma Edge Function `bridge` no projeto do WorkPlanner protegida por um header secreto compartilhado (`X-FCNC-Secret`) — é exatamente o padrão que já está em produção do lado do Kabacal e funciona bem.

---

## 6. Vocabulários

**Status** (os 16 que já existem na UI — manter exatamente estas strings):
`Empty · On Hold · Completed · Production authorised · Quoted · Quality Check · Production · Awaiting Materials · Design · Delivery · Collection · On hold by customer · Sent to Spray · Waiting Spray Quote · Contact Client · Send to sprayer`

**Materiais** — hoje é texto livre ("18 mm MDF", "Moisture MDF", "Lightweight MDF", "Oak veneer", "Customer-supplied oak"). O ideal é virar lista fechada, casada com o catálogo do Kabacal. Enquanto não for: **o Kabacal preenche só o que reconhecer; o que não reconhecer fica em branco + aviso no diálogo**. Nada quebra.

**Máquinas:** `Router A`, `Router B` (Pegasus/Syntec) e `Parkin M2`. As duas são quase totalmente compatíveis; a única diferença conhecida hoje é a posição de parada no fim do programa na Parkin — isso é assunto do lado Kabacal (post-processador), não da integração.

---

## 7. O que o Kabacal marca nos subitens

| Etapa | Quando o Kabacal marca | Status |
|---|---|---|
| QUOTE | orçamento rascunho calculado | `Quoted` |
| DESIGN | peças válidas (sem erro de geometria) | `Completed` |
| PROGRAMMING | toolpaths aplicados sem pendência | `Completed` |
| CNC CUTTING | NC gerado e disponível | `Production` — **nunca** `Completed` |
| MATERIALS ORDER | chapas necessárias calculadas | `Awaiting Materials` + texto "3× MDF 18mm 8x4" |

---

## 8. Fase 0 — o mínimo para destravar

Se for para entregar só uma coisa primeiro, que seja isto:

1. `ops.jobs` + `ops.job_analysis` + `ops.job_events` (as três acima, sem cortes de coluna).
2. RLS ligada + a credencial da ponte da §5.
3. Um job de teste real gravado com a reference verdadeira (ex.: `LEE290626`) e `drive_folder` apontando para a pasta do Drive.
4. Signups **fechados** no Auth (hoje estão abertos).

Com isso o lado Kabacal já consegue ler o job, processar e devolver — o resto (subitens, updates, files) entra depois sem quebrar nada.

---

## 9. O que já existe do lado Kabacal (para calibrar expectativa)

- Motor headless que roda o app inteiro fora do navegador (`tools/order-engine.mjs`).
- Edge Function que recebe um pedido e devolve `.fastcnc` + DXF + NC, já em produção para o site.
- Orçamento com preço por material/serviço/spray, área em m², contagem de chapas, offcuts e estimativa de tempo de máquina — tudo o que as colunas vazias do board pedem.
- Pacote de produção (NC + etiquetas + manifesto CSV) e PDFs de orçamento e cut list.

---

## 10. Perguntas que precisam de resposta antes de codar

1. A API do WorkPlanner vai expor **escrita** para a ponte (via RLS ou Edge Function)? Sem isso a integração vira mão única.
2. Os arquivos do Drive ficam acessíveis por API (Service Account com acesso à pasta do info@) ou a ponte recebe só o link?
3. Uma pessoa vai conferir o resultado antes de o valor virar orçamento oficial? (A resposta esperada é **sim**.)
