-- Aplicada em produção em 17/09/2026 (Supabase zfoatchkgfkilfymtyli).
-- Aditiva: adiciona colunas que o código de upload já esperava.
-- Sem elas, o arquivo do contrato/comprovante subia para o storage mas
-- o caminho não era gravado no banco, e às vezes o cadastro do projeto
-- inteiro era abortado.
alter table public.projetos
  add column if not exists contrato_url text,
  add column if not exists contrato_path text,
  add column if not exists contract_file_path text;

alter table public.parcelas_pagamento
  add column if not exists comprovante_url text,
  add column if not exists comprovante_path text,
  add column if not exists receipt_file_path text;

-- Para desfazer (não recomendado — o código passa a falhar silenciosamente):
-- alter table public.projetos
--   drop column contrato_url, drop column contrato_path, drop column contract_file_path;
-- alter table public.parcelas_pagamento
--   drop column comprovante_url, drop column comprovante_path, drop column receipt_file_path;
