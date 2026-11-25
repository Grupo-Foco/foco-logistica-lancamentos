alter table motoristas add column if not exists taxa_comissao numeric default 10.5;
alter table motoristas add column if not exists vale numeric default 400;

update motoristas set taxa_comissao = 10.5 where taxa_comissao is null;
update motoristas set vale = 400 where vale is null;
update motoristas set taxa_comissao = 12 where upper(btrim(nome)) in ('PAULO JUNIO', 'ILSON');

grant select, insert, update, delete on motoristas to anon, authenticated;

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

grant select, insert, update, delete on comissao_fechamento to anon, authenticated;
grant usage, select on sequence comissao_fechamento_id_seq to anon, authenticated;

alter table comissao_fechamento enable row level security;
drop policy if exists p_anon_all_fec on comissao_fechamento;
create policy p_anon_all_fec on comissao_fechamento for all to anon, authenticated using (true) with check (true);

update fretes set motorista = upper(btrim(motorista))
  where motorista is not null and motorista <> upper(btrim(motorista));

update fretes set motorista = 'SAMUEL' where btrim(upper(motorista)) = 'SA';
delete from motoristas where upper(btrim(nome)) = 'SA';

select nome, taxa_comissao, vale from motoristas order by nome;
