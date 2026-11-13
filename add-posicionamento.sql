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

grant select, insert, update, delete on posicionamento to anon, authenticated;
grant usage, select on sequence posicionamento_id_seq to anon, authenticated;

alter table posicionamento enable row level security;
drop policy if exists p_anon_all on posicionamento;
create policy p_anon_all on posicionamento for all to anon, authenticated using (true) with check (true);

delete from posicionamento where data = '2026-11-11'::date and lancador = 'Semente';

insert into posicionamento (data, placa, grupo, produto, empresa, origem, destino, localizacao, situacao, motorista, obs, ordem, lancador) values
  ('2026-11-11'::date, 'FRI-0D72', 'RODOTREM',    'SEMENTES',            'FOCO AGRONEGOCIOS', 'GURUPI-TO',          'PEIXE-TO/FIGUEIROPOLIS-TO/MONTE SANTO DO TO-TO', 'SUCUPIRA-TO',             'EM DESCARREGAMENTO',                                              'JOÃO PEDRO',   null,                                                                                                 0,  'Semente'),
  ('2026-11-11'::date, 'PRJ-3G87', 'RODOTREM',    'SOJA EM GRÃOS',       'RODOFROTA TRANSP',  'VICENTINOPOLIS-GO',  'UBERABA-MG',                                      'UBERABA-MG',              'AGUARDANDO DESCARREGAMENTO',                                      'MOACIR',       null,                                                                                                 1,  'Semente'),
  ('2026-11-11'::date, 'RBV-4F96', 'RODOTREM',    'SOJA EM GRÃOS',       'RODOFROTA TRANSP',  'VICENTINOPOLIS-GO',  'UBERABA-MG',                                      'VICENTINOPOLIS-GO',       'AGUARDANDO CARREGAMENTO',                                         'JOÃO BATISTA', 'AINDA ESTA SENTINDO O CAMINHAO COM POUCA PRESSAO, AGUARDAREMOS PARA AVALIAR AO SEGUIR VIAGEM.',       2,  'Semente'),
  ('2026-11-11'::date, 'SDD-5J27', 'RODOTREM',    'SEMENTES',            'FOCO AGRONEGOCIOS', 'GURUPI-TO',          'FAZ STA ANGELINA',                                'GURUPI-TO',               'REVISAO - VERIFICANDO SISTEMA DE FREIOS DA CARRETA',              'LEANDRO',      null,                                                                                                 3,  'Semente'),
  ('2026-11-11'::date, 'SDD-5J67', 'RODOTREM',    null,                  null,                'DOM AQUINO-MT',      'BOM JESUS DO ARAGUAIA-MT',                        'BOM JESUS DO ARAGUAIA-MT','AGUARDANDO CARREGAMENTO',                                         'CLEITON',      null,                                                                                                 4,  'Semente'),
  ('2026-11-11'::date, 'SDD-6B47', 'RODOTREM',    'SEMENTES',            'FOCO AGRONEGOCIOS', 'GURUPI-TO',          'FAZ STA ANGELINA',                                'GURUPI-TO',               'AGUARDANDO CARREGAMENTO',                                         'NELIO',        null,                                                                                                 5,  'Semente'),
  ('2026-11-11'::date, 'PRR-5H27', '4 EIXO',      'CHAPA DE GESSO',      'CRP TRANSPORTES',   'APARECIDA DE GYN-GO','PRIMAVERA DO LESTE-MT',                           'PRIMAVERA DO LESTE-MT',   'EM DESCARREGAMENTO',                                              'ILSON',        null,                                                                                                 6,  'Semente'),
  ('2026-11-11'::date, 'PRU-6G14', '4 EIXO',      'MILHO A GRANEL',      'G10 TRANSPORTES',   'DOM AQUINO-MT',      'BOM JESUS DO ARAGUAIA-MT',                        'BOM JESUS DO ARAGUAIA-MT','AGUARDANDO CARREGAMENTO',                                         'PAULO',        null,                                                                                                 7,  'Semente'),
  ('2026-11-11'::date, 'SDD-5J07', 'RODOCAÇAMBA', 'CALCARIO DOLOMITICO', 'PIANETTO TRANSP',   'VILA PROPICIO-GO',   'ITUMBIARA-GO',                                    'GOIANIA-GO',              'EM VIAGEM PARA DESCARREGAMENTO',                                  'SAMUEL',       null,                                                                                                 8,  'Semente'),
  ('2026-11-11'::date, 'SDD-6A77', 'RODOCAÇAMBA', 'CALCARIO DOLOMITICO', 'PIANETTO TRANSP',   'VILA PROPICIO-GO',   'ITUMBIARA-GO',                                    'ITUMBIARA-GO',            'EM DESCARREGAMENTO',                                              'ADENILSON',    null,                                                                                                 9,  'Semente'),
  ('2026-11-11'::date, 'MWL-8F67', 'RODOCAÇAMBA', null,                  null,                null,                 null,                                              'BRASILIA-DF',             'AGUARDANDO LIBERAÇAO DA DOCUMENTAÇÃO PARA CARREGAMENTO EM FORMOSA-GO','ADAILTON',  'FINALIZOU CALCARIO',                                                                                 10, 'Semente'),
  ('2026-11-11'::date, 'RCN-7I11', 'FAZENDAS',    null,                  null,                null,                 null,                                              'PADRE BERNARDO-GO',       'SERVIÇOS - FAZENDA',                                              'EDMAR',        null,                                                                                                 11, 'Semente'),
  ('2026-11-11'::date, 'NKT-0H38', 'FAZENDAS',    null,                  null,                null,                 null,                                              'BREJINHO-TO',             'SERVIÇOS - FAZENDA',                                              'ACLEUTO',      null,                                                                                                 12, 'Semente'),
  ('2026-11-11'::date, 'RBP-1G55', 'RODOTREM',    null,                  null,                null,                 null,                                              null,                      null,                                                              null,           null,                                                                                                 13, 'Semente');

select 'linhas 11/11' as info, count(*)::text as valor from posicionamento where data = '2026-11-11'::date
union all
select 'policies', count(*)::text from pg_policies where tablename = 'posicionamento';
