-- Fluxo operacional padrão da Alfa Móveis Planejados.
-- Migration aditiva: preserva projetos e tarefas existentes.

CREATE TABLE IF NOT EXISTS public.production_templates (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    stage_key TEXT NOT NULL,
    name TEXT NOT NULL,
    category TEXT NOT NULL,
    description TEXT,
    "order" INTEGER NOT NULL,
    depends_on_order INTEGER,
    is_required BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE UNIQUE INDEX IF NOT EXISTS production_templates_stage_key_idx
    ON public.production_templates (stage_key);

INSERT INTO public.production_templates (stage_key, name, category, "order", depends_on_order, is_required)
VALUES
 ('conferencia_inicial', 'Conferência inicial do projeto', 'PRE-PRODUÇÃO', 1, NULL, true),
 ('medicao_tecnica', 'Medição técnica', 'PRE-PRODUÇÃO', 2, 1, true),
 ('engenharia_detalhamento', 'Engenharia / detalhamento técnico', 'PRE-PRODUÇÃO', 3, 2, true),
 ('revisao_interna', 'Revisão interna', 'PRE-PRODUÇÃO', 4, 3, true),
 ('aprovacao_cliente', 'Aprovação final do cliente', 'PRE-PRODUÇÃO', 5, 4, true),
 ('levantamento_materiais', 'Levantamento de materiais', 'PLANEJAMENTO / SUPRIMENTOS', 6, 5, false),
 ('compra_separacao', 'Compra / separação de materiais', 'PLANEJAMENTO / SUPRIMENTOS', 7, 6, false),
 ('preparacao_producao', 'Preparação para produção', 'PLANEJAMENTO / SUPRIMENTOS', 8, 7, true),
 ('corte_seccionamento', 'Corte / Seccionamento', 'PRODUÇÃO', 9, 8, false),
 ('corte_cnc', 'Corte CNC', 'PRODUÇÃO', 10, 9, false),
 ('furacao_usinagem', 'Furação / Usinagem', 'PRODUÇÃO', 11, 10, false),
 ('laminacao_revestimento', 'Laminação / Revestimento', 'PRODUÇÃO', 12, 11, false),
 ('fita_borda', 'Fita de borda', 'PRODUÇÃO', 13, 12, false),
 ('preparacao_pecas', 'Preparação das peças', 'PRODUÇÃO', 14, 13, true),
 ('pre_montagem', 'Pré-montagem', 'PRODUÇÃO', 15, 14, false),
 ('montagem_final', 'Montagem final', 'PRODUÇÃO', 16, 15, true),
 ('acabamento_finalizacao', 'Acabamento / Finalização', 'PRODUÇÃO', 17, 16, false),
 ('conferencia_qualidade', 'Conferência de qualidade', 'QUALIDADE', 18, 17, true),
 ('embalagem_expedicao', 'Embalagem / Expedição', 'LOGÍSTICA', 19, 18, true),
 ('instalacao', 'Instalação', 'CAMPO', 20, 19, true),
 ('conferencia_pos_instalacao', 'Conferência pós-instalação', 'CAMPO', 21, 20, true),
 ('pendencias_ajustes', 'Pendências / Ajustes finais', 'PÓS-VENDA', 22, 21, false),
 ('projeto_concluido', 'Projeto concluído', 'ENCERRAMENTO', 23, 22, true)
ON CONFLICT (stage_key) DO UPDATE SET
    name = EXCLUDED.name,
    category = EXCLUDED.category,
    "order" = EXCLUDED."order",
    depends_on_order = EXCLUDED.depends_on_order,
    is_required = EXCLUDED.is_required,
    updated_at = now();

CREATE TABLE IF NOT EXISTS public.production_tasks (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    project_id UUID NOT NULL REFERENCES public.projetos(id) ON DELETE CASCADE,
    template_id UUID REFERENCES public.production_templates(id) ON DELETE SET NULL,
    name TEXT NOT NULL,
    stage_key TEXT,
    category TEXT,
    "order" INTEGER NOT NULL,
    status TEXT NOT NULL DEFAULT 'pending',
    is_applicable BOOLEAN NOT NULL DEFAULT true,
    depends_on_order INTEGER,
    started_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE public.production_tasks ADD COLUMN IF NOT EXISTS template_id UUID REFERENCES public.production_templates(id) ON DELETE SET NULL;
ALTER TABLE public.production_tasks ADD COLUMN IF NOT EXISTS stage_key TEXT;
ALTER TABLE public.production_tasks ADD COLUMN IF NOT EXISTS category TEXT;
ALTER TABLE public.production_tasks ADD COLUMN IF NOT EXISTS is_applicable BOOLEAN NOT NULL DEFAULT true;
ALTER TABLE public.production_tasks ADD COLUMN IF NOT EXISTS depends_on_order INTEGER;

-- Migra as tarefas legadas de 12 etapas para o template e completa as etapas ausentes.
UPDATE public.production_tasks task
SET template_id = template.id,
    name = template.name,
    stage_key = template.stage_key,
    category = template.category,
    "order" = template."order",
    depends_on_order = template.depends_on_order
FROM public.production_templates template
WHERE task.template_id IS NULL
  AND template.stage_key = CASE task.name
      WHEN 'Conferência do projeto' THEN 'conferencia_inicial'
      WHEN 'Medição' THEN 'medicao_tecnica'
      WHEN 'Projeto técnico' THEN 'engenharia_detalhamento'
      WHEN 'Aprovação' THEN 'aprovacao_cliente'
      WHEN 'Corte CNC' THEN 'corte_cnc'
      WHEN 'Corte / Seccionamento' THEN 'corte_seccionamento'
      WHEN 'Usinagem' THEN 'furacao_usinagem'
      WHEN 'Borda' THEN 'fita_borda'
      WHEN 'Montagem' THEN 'montagem_final'
      WHEN 'Acabamento / Finalização' THEN 'acabamento_finalizacao'
      WHEN 'Conferência final' THEN 'conferencia_qualidade'
      WHEN 'Instalação' THEN 'instalacao'
  END;

INSERT INTO public.production_tasks (project_id, template_id, name, stage_key, category, "order", status, is_applicable, depends_on_order)
SELECT project.id, template.id, template.name, template.stage_key, template.category, template."order",
       CASE WHEN template."order" = 1 THEN 'pending' ELSE 'blocked' END,
       true, template.depends_on_order
FROM public.projetos project
CROSS JOIN public.production_templates template
WHERE NOT EXISTS (
    SELECT 1 FROM public.production_tasks existing
    WHERE existing.project_id = project.id AND existing.template_id = template.id
);

-- Impede que a mesma etapa seja cadastrada duas vezes para um projeto.
CREATE UNIQUE INDEX IF NOT EXISTS production_tasks_project_order_idx
    ON public.production_tasks (project_id, "order");

CREATE INDEX IF NOT EXISTS production_tasks_project_status_idx
    ON public.production_tasks (project_id, status);

CREATE INDEX IF NOT EXISTS production_tasks_stage_status_idx
    ON public.production_tasks (stage_key, status, is_applicable);

-- Habilitar Row Level Security (RLS)
ALTER TABLE public.production_tasks ENABLE ROW LEVEL SECURITY;

-- Políticas de acesso público para integração com aplicativo estático (chave anon)
DO $$ BEGIN
    CREATE POLICY "Permitir leitura pública" ON public.production_tasks
        FOR SELECT USING (true);
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

ALTER TABLE public.production_templates ENABLE ROW LEVEL SECURITY;
DO $$ BEGIN
    CREATE POLICY "Permitir leitura pública dos templates" ON public.production_templates
        FOR SELECT USING (true);
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- Habilita eventos de tarefa para atualização automática do Chão de Fábrica.
DO $$ BEGIN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.production_tasks;
EXCEPTION WHEN duplicate_object THEN NULL;
          WHEN undefined_object THEN NULL;
END $$;

DO $$ BEGIN
    CREATE POLICY "Permitir inserção pública" ON public.production_tasks
        FOR INSERT WITH CHECK (true);
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
    CREATE POLICY "Permitir atualização pública" ON public.production_tasks
        FOR UPDATE USING (true);
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
    CREATE POLICY "Permitir exclusão pública" ON public.production_tasks
        FOR DELETE USING (true);
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;
