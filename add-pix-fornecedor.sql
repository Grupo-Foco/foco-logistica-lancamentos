alter table fornecedores add column if not exists chave_pix text;

grant select, insert, update on fornecedores to anon, authenticated;

update fornecedores f
set chave_pix = sub.cp
from (
  select distinct on (upper(fornecedor)) upper(fornecedor) as nome_up, chave_pix as cp
  from despesas
  where fornecedor is not null
    and chave_pix is not null
    and btrim(chave_pix) <> ''
  order by upper(fornecedor), id desc
) sub
where upper(f.nome) = sub.nome_up;

select count(*) as fornecedores_com_pix
from fornecedores
where chave_pix is not null and btrim(chave_pix) <> '';
