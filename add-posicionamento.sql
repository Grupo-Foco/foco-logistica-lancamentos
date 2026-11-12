create table if not exists posicionamento (
  id bigserial primary key,
  data date not null,
  placa text not null,
  grupo text,
  produto text,
  empresa text,
  origem text,
  destino text,
  localizacao text,
  situacao text,
  motorista text,
  obs text,
  ordem int,
  lancador text,
  created_at timestamptz default now()
);

create index if not exists idx_posicionamento_data on posicionamento (data);

insert into posicionamento (data, placa, grupo, motorista, ordem, lancador)
select v.data, v.placa, v.grupo, v.motorista, v.ordem, v.lancador
from (values
  ('2026-11-11'::date, 'FRI-0D72', 'RODOTREM',    'João Pedro',    0, 'Semente'),
  ('2026-11-11'::date, 'PRJ-3G87', 'RODOTREM',    'Moacir',        1, 'Semente'),
  ('2026-11-11'::date, 'RBV-4F96', 'RODOTREM',    'João Batista',  2, 'Semente'),
  ('2026-11-11'::date, 'SDD-5J27', 'RODOTREM',    'Leandro',       3, 'Semente'),
  ('2026-11-11'::date, 'SDD-5J67', 'RODOTREM',    'Cleiton',       4, 'Semente'),
  ('2026-11-11'::date, 'SDD-6B47', 'RODOTREM',    'Nelio',         5, 'Semente'),
  ('2026-11-11'::date, 'PRR-5H27', '4 EIXO',      'Ilson',         6, 'Semente'),
  ('2026-11-11'::date, 'PRU-6G14', '4 EIXO',      'Paulo',         7, 'Semente'),
  ('2026-11-11'::date, 'SDD-5J07', 'RODOCAÇAMBA', 'Samuel',        8, 'Semente'),
  ('2026-11-11'::date, 'SDD-6A77', 'RODOCAÇAMBA', 'Adenilson',     9, 'Semente'),
  ('2026-11-11'::date, 'MWL-8F67', 'RODOCAÇAMBA', 'Adailton',     10, 'Semente'),
  ('2026-11-11'::date, 'RCN-7I11', 'FAZENDAS',    'Edmar',        11, 'Semente'),
  ('2026-11-11'::date, 'NKT-0H38', 'FAZENDAS',    'Acleuto',      12, 'Semente'),
  ('2026-11-11'::date, 'RBP-1G55', 'RODOTREM',    null,           13, 'Semente')
) as v(data, placa, grupo, motorista, ordem, lancador)
where not exists (
  select 1 from posicionamento p where p.data = '2026-11-11'::date
);
