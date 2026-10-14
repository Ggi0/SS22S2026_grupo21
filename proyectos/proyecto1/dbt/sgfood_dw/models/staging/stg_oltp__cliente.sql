-- stg_oltp__cliente: clientes. Municipio/departamento pueden ser NULL o vacíos:
-- clean_text los etiqueta distinto (NO_INFORMADO vs SIN_VALOR). Fuente: raw.oltp_cliente
with src as (select * from {{ source('raw', 'oltp_cliente') }})
select
    {{ safe_int('id_cliente') }}          as id_cliente,
    {{ estado_dato('id_cliente') }}       as id_cliente_estado,    -- NULO / VACIO / OK
    {{ clean_text('nit') }}               as nit,
    {{ clean_text('nombre') }}            as nombre,
    {{ clean_text('tipo_cliente') }}      as tipo_cliente,
    {{ clean_text('municipio') }}         as municipio,
    {{ clean_text('departamento') }}      as departamento,
    {{ safe_date('fecha_alta') }}         as fecha_alta,
    _batch_id, _loaded_at
from src
