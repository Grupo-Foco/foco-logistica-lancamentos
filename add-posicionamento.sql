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
