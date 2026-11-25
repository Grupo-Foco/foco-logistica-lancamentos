create table if not exists motoristas (
  id bigserial primary key,
  nome text not null unique,
  taxa_comissao numeric not null default 10.5,
  vale numeric not null default 400,
  ativo boolean default true,
  created_at timestamptz default now()
);

create table if not exists comissao_fechamento (
  id bigserial primary key,
  motorista text not null,
  competencia text not null,
  diarias numeric default 0,
  gratificacao numeric default 0,
  obs text,
  created_at timestamptz default now(),
  unique (motorista, competencia)
);

grant select, insert, update, delete on motoristas to anon, authenticated;
grant select, insert, update, delete on comissao_fechamento to anon, authenticated;
grant usage, select on sequence motoristas_id_seq to anon, authenticated;
grant usage, select on sequence comissao_fechamento_id_seq to anon, authenticated;

alter table motoristas enable row level security;
drop policy if exists p_anon_all_mot on motoristas;
create policy p_anon_all_mot on motoristas for all to anon, authenticated using (true) with check (true);

alter table comissao_fechamento enable row level security;
drop policy if exists p_anon_all_fec on comissao_fechamento;
create policy p_anon_all_fec on comissao_fechamento for all to anon, authenticated using (true) with check (true);

update fretes set motorista = upper(btrim(motorista))
  where motorista is not null and motorista <> upper(btrim(motorista));

update fretes set motorista = 'SAMUEL' where btrim(upper(motorista)) = 'SA';

insert into motoristas (nome, taxa_comissao, vale) values
  ('JOÃO PEDRO', 10.5, 400),
  ('LEANDRO', 10.5, 400),
  ('NELIO', 10.5, 400),
  ('SAMUEL', 10.5, 400),
  ('MOACIR', 10.5, 400),
  ('ILSON', 12, 400),
  ('CLEITON', 10.5, 400),
  ('ADAILTON', 10.5, 400),
  ('ADENILSON', 10.5, 400),
  ('JOÃO BATISTA', 10.5, 400),
  ('PAULO JUNIO', 12, 400),
  ('EDMAR', 10.5, 400),
  ('LUCAS', 10.5, 400),
  ('FLÁVIO', 10.5, 400),
  ('DIONE', 10.5, 400),
  ('MARCOS', 10.5, 400)
on conflict (nome) do nothing;

select nome, taxa_comissao, vale from motoristas order by nome;
