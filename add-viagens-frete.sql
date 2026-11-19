alter table fretes add column if not exists tipo text default 'SIMPLES';
alter table fretes add column if not exists viagens int default 1;

update fretes set tipo = 'SIMPLES' where tipo is null;
update fretes set viagens = 1 where viagens is null or viagens < 1;

select tipo, count(*) as fretes, sum(viagens) as viagens_total
from fretes
group by tipo
order by tipo;
