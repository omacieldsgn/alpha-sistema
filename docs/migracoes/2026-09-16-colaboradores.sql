-- Aplicada em produção em 16/09/2026 (Supabase zfoatchkgfkilfymtyli).
-- Aditiva: nenhuma tabela ou coluna existente foi alterada.
create table if not exists public.colaboradores (
  id uuid primary key default gen_random_uuid(),
  nome text not null,
  telefone text,
  funcao text,
  ativo boolean not null default true,
  token text not null unique,
  legacy_id text unique,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
alter table public.colaboradores enable row level security;
create policy "Permitir leitura publica" on public.colaboradores for select using (true);
create policy "Permitir insercao publica" on public.colaboradores for insert with check (true);
create policy "Permitir alteracao publica" on public.colaboradores for update using (true);
create policy "Permitir exclusao publica" on public.colaboradores for delete using (true);

alter table public.production_tasks
  add column if not exists assigned_to uuid references public.colaboradores(id) on delete set null;
create index if not exists production_tasks_assigned_to_idx on public.production_tasks (assigned_to);

-- Para desfazer:
-- alter table public.production_tasks drop column assigned_to;
-- drop table public.colaboradores;
