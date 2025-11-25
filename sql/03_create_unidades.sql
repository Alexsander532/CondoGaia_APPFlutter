create table public.unidades (
  id uuid not null default gen_random_uuid (),
  numero character varying(10) not null,
  condominio_id uuid not null,
  bloco character varying(10) null,
  fracao_ideal numeric(10, 6) null,
  area_m2 numeric(10, 2) null,
  vencto_dia_diferente integer null,
  pagar_valor_diferente numeric(10, 2) null,
  tipo_unidade character varying(5) null default 'A'::character varying,
  isencao_nenhum boolean null default true,
  isencao_total boolean null default false,
  isencao_cota boolean null default false,
  isencao_fundo_reserva boolean null default false,
  acao_judicial boolean null default false,
  correios boolean null default false,
  nome_pagador_boleto character varying(20) null default 'proprietario'::character varying,
  observacoes text null,
  ativo boolean null default true,
  created_at timestamp with time zone null default CURRENT_TIMESTAMP,
  updated_at timestamp with time zone null default CURRENT_TIMESTAMP,
  tem_proprietario boolean null default false,
  tem_inquilino boolean null default false,
  qr_code_url text null,
  constraint unidades_pkey primary key (id),
  constraint unidades_fracao_ideal_max check (
    (
      (fracao_ideal is null)
      or (fracao_ideal <= 1.0)
    )
  ),
  constraint unidades_nome_pagador_boleto_check check (
    (
      (nome_pagador_boleto)::text = any (
        (
          array[
            'proprietario'::character varying,
            'inquilino'::character varying
          ]
        )::text[]
      )
    )
  ),
  constraint unidades_numero_not_empty check (
    (
      TRIM(
        both
        from
          numero
      ) <> ''::text
    )
  ),
  constraint unidades_valores_positivos check (
    (
      (
        (fracao_ideal is null)
        or (fracao_ideal > (0)::numeric)
      )
      and (
        (area_m2 is null)
        or (area_m2 > (0)::numeric)
      )
      and (
        (pagar_valor_diferente is null)
        or (pagar_valor_diferente >= (0)::numeric)
      )
    )
  ),
  constraint unidades_vencto_dia_valid check (
    (
      (vencto_dia_diferente is null)
      or (
        (vencto_dia_diferente >= 1)
        and (vencto_dia_diferente <= 31)
      )
    )
  )
) TABLESPACE pg_default;

create unique INDEX IF not exists idx_unidades_numero_condominio on public.unidades using btree (numero, condominio_id) TABLESPACE pg_default
where
  (ativo = true);

create index IF not exists idx_unidades_bloco on public.unidades using btree (bloco) TABLESPACE pg_default
where
  (ativo = true);

create index IF not exists idx_unidades_condominio on public.unidades using btree (condominio_id) TABLESPACE pg_default
where
  (ativo = true);

create index IF not exists idx_unidades_tipo on public.unidades using btree (tipo_unidade) TABLESPACE pg_default
where
  (ativo = true);

create index IF not exists idx_unidades_isencoes on public.unidades using btree (
  isencao_total,
  isencao_cota,
  isencao_fundo_reserva
) TABLESPACE pg_default
where
  (ativo = true);

create trigger trigger_update_unidades_updated_at BEFORE
update on unidades for EACH row
execute FUNCTION update_updated_at_column ();

create trigger trigger_validate_isencao_exclusiva BEFORE INSERT
or
update on unidades for EACH row
execute FUNCTION validate_isencao_exclusiva ();