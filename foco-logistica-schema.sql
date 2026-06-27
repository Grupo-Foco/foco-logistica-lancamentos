-- ============================================================
--  FOCO LOGÍSTICA — Schema do banco (Supabase / PostgreSQL)
--  Rode este script no SQL Editor do projeto Supabase.
--  Convenções seguem o padrão do sistema da Agropecuária.
-- ============================================================

-- ----------------------------------------------------------------
-- 1) USUÁRIOS E ACESSOS
--    (na agro ficam em localStorage; aqui vão para o banco para
--     funcionarem em vários dispositivos/locais)
-- ----------------------------------------------------------------
create table if not exists usuarios (
  id          bigserial primary key,
  login       text unique not null,
  nome        text not null,
  senha       text not null,                       -- ver nota de segurança no fim
  role        text not null default 'funcionario', -- 'gestor' | 'funcionario'
  ativo       boolean not null default true,
  perms       jsonb not null default '{}'::jsonb,   -- {endividamento:true, exportar:true, ...}
  created_at  timestamptz not null default now()
);

-- ----------------------------------------------------------------
-- 2) CADASTROS DE APOIO
-- ----------------------------------------------------------------
create table if not exists caminhoes (
  id              bigserial primary key,
  placa           text unique not null,
  modelo          text,
  motorista_padrao text,
  ativo           boolean not null default true,
  created_at      timestamptz not null default now()
);

create table if not exists motoristas (
  id          bigserial primary key,
  nome        text not null,
  telefone    text,
  chave_pix   text,
  login       text,                 -- vínculo opcional com usuarios.login
  ativo       boolean not null default true,
  created_at  timestamptz not null default now()
);

create table if not exists clientes (
  id          bigserial primary key,
  nome        text not null,
  cnpj        text,
  ativo       boolean not null default true,
  created_at  timestamptz not null default now()
);

create table if not exists fornecedores (
  id          bigserial primary key,
  nome        text not null,
  cnpj        text,
  created_at  timestamptz not null default now()
);

-- ----------------------------------------------------------------
-- 3) FRETES  (origem da RECEITA)
-- ----------------------------------------------------------------
create table if not exists fretes (
  id                bigserial primary key,
  codigo            text,                         -- ex: FRETE-0001
  cliente           text,
  cliente_id        bigint references clientes(id),
  origem            text,
  destino           text,
  placa             text,                         -- caminhão do frete
  motorista         text,
  produto           text,                         -- carga transportada (opcional)
  valor_total       numeric(14,2) not null default 0,
  data_carregamento date,
  data_descarregamento date,
  status            text not null default 'EM_ANDAMENTO', -- EM_ANDAMENTO | CONCLUIDO | CANCELADO
  observacao        text,
  lancador          text,
  created_at        timestamptz not null default now()
);

-- ----------------------------------------------------------------
-- 4) RECEITAS = PARCELAS DO FRETE
--    Normalmente 2 por frete: ANTECIPACAO (carregamento) e SALDO
--    (descarregamento). Valor é manual (sem % fixo). Permite +parcelas.
-- ----------------------------------------------------------------
create table if not exists receita_parcelas (
  id                bigserial primary key,
  frete_id          bigint not null references fretes(id) on delete cascade,
  tipo              text not null,                 -- ANTECIPACAO | SALDO | PARCELA
  valor             numeric(14,2) not null default 0,
  previsao          date,                          -- data prevista de recebimento
  status            text not null default 'PREVISTA', -- PREVISTA | RECEBIDA
  data_recebimento  date,
  conta             text,                          -- conta onde caiu
  comprovante       text,                          -- caminho do anexo (Storage)
  observacao        text,
  created_at        timestamptz not null default now()
);

-- ----------------------------------------------------------------
-- 5) DESPESAS  (lançamentos) — inclui reembolsos
--    Ligadas ao CAMINHÃO e, opcionalmente, ao FRETE -> margem.
-- ----------------------------------------------------------------
create table if not exists despesas (
  id              bigserial primary key,
  tipo_despesa    text,                            -- COMBUSTIVEL | PEDAGIO | MANUTENCAO | REEMBOLSO | ...
  placa           text,                            -- caminhão
  motorista       text,
  frete_id        bigint references fretes(id),    -- opcional: amarra a despesa ao frete
  fornecedor      text,
  cnpj            text,
  documento       text,                            -- nº NF/recibo
  valor           numeric(14,2) not null default 0,
  data_doc        date,
  vencimento      date,
  pagamento       date,
  status          text not null default 'A_PAGAR', -- A_PAGAR | PAGO
  conta           text,
  forma_pagamento text default 'PIX',
  chave_pix       text,                            -- p/ reembolso
  cg              text,                            -- agrupador de parcelas (se parcelado)
  nf              text,                            -- anexo NF (Storage)
  boleto          text,                            -- anexo comprovante/boleto (Storage)
  historico       text,
  lancador        text,
  created_at      timestamptz not null default now()
);

-- ----------------------------------------------------------------
-- 6) ENDIVIDAMENTO  (financiamentos / empréstimos)
-- ----------------------------------------------------------------
create table if not exists endividamento (
  id              bigserial primary key,
  descricao       text not null,
  credor          text,
  placa           text,                            -- se for financiamento de caminhão
  valor_total     numeric(14,2) not null default 0,
  qtd_parcelas    int default 1,
  taxa_juros      numeric(8,4),
  data_inicio     date,
  status          text not null default 'ATIVO',   -- ATIVO | QUITADO
  observacao      text,
  lancador        text,
  created_at      timestamptz not null default now()
);

create table if not exists endividamento_parcelas (
  id              bigserial primary key,
  divida_id       bigint not null references endividamento(id) on delete cascade,
  numero          int,
  valor           numeric(14,2) not null default 0,
  vencimento      date,
  pagamento       date,
  status          text not null default 'A_PAGAR', -- A_PAGAR | PAGO
  comprovante     text
);

-- ----------------------------------------------------------------
-- 7) ÍNDICES
-- ----------------------------------------------------------------
create index if not exists idx_desp_placa     on despesas(placa);
create index if not exists idx_desp_frete     on despesas(frete_id);
create index if not exists idx_desp_status    on despesas(status);
create index if not exists idx_parc_frete     on receita_parcelas(frete_id);
create index if not exists idx_parc_status    on receita_parcelas(status);
create index if not exists idx_fretes_placa   on fretes(placa);

-- ----------------------------------------------------------------
-- 8) VIEW: MARGEM POR FRETE (receita - despesas amarradas)
-- ----------------------------------------------------------------
create or replace view vw_margem_frete as
select
  f.id, f.codigo, f.cliente, f.placa, f.status,
  f.valor_total                                           as receita_total,
  coalesce((select sum(rp.valor) from receita_parcelas rp
            where rp.frete_id=f.id and rp.status='RECEBIDA'),0) as receita_recebida,
  coalesce((select sum(d.valor) from despesas d
            where d.frete_id=f.id),0)                      as despesa_total,
  f.valor_total - coalesce((select sum(d.valor) from despesas d
            where d.frete_id=f.id),0)                      as margem
from fretes f;

-- ----------------------------------------------------------------
-- 9) RLS — libera o papel anônimo (mesma lógica do sistema atual,
--    que acessa via chave anon atrás de um login próprio).
--    Veja a NOTA DE SEGURANÇA no final.
-- ----------------------------------------------------------------
do $$
declare t text;
begin
  foreach t in array array['usuarios','caminhoes','motoristas','clientes','fornecedores',
                           'fretes','receita_parcelas','despesas','endividamento','endividamento_parcelas']
  loop
    execute format('alter table %I enable row level security;', t);
    execute format('drop policy if exists anon_all on %I;', t);
    execute format('create policy anon_all on %I for all to anon using (true) with check (true);', t);
  end loop;
end $$;

-- ----------------------------------------------------------------
-- 10) USUÁRIOS INICIAIS (senha padrão 'foco2026' — troque depois)
--     Rodolfo, Henrique, Ivan = gestores (acesso total)
--     Wiliany = funcionária (acesso básico)
-- ----------------------------------------------------------------
insert into usuarios (login, nome, senha, role, perms) values
  ('rodolfo',  'Rodolfo',  'foco2026', 'gestor',      '{}'::jsonb),
  ('henrique', 'Henrique', 'foco2026', 'gestor',      '{}'::jsonb),
  ('ivan',     'Ivan',     'foco2026', 'gestor',      '{}'::jsonb),
  ('wiliany',  'Wiliany',  'foco2026', 'funcionario', '{}'::jsonb)
on conflict (login) do nothing;

-- ============================================================
--  NOTA DE SEGURANÇA
--  As políticas acima liberam leitura/escrita ao papel anônimo,
--  reproduzindo o modelo atual (login próprio + chave anon).
--  É aceitável para uma ferramenta interna, MAS as senhas ficam
--  em texto na tabela. Próximo passo recomendado: migrar o login
--  para o Supabase Auth (senha com hash) e fechar as policies por
--  usuário autenticado. Posso fazer essa evolução depois.
-- ============================================================
