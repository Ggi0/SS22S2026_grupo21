-- stg_oltp__sucursal: sucursales tipadas y limpias (1 fila por sucursal). Fuente: raw.oltp_sucursal
with src as (select * from {{ source('raw', 'oltp_sucursal') }})
select
    {{ safe_int('id_sucursal') }}        as id_sucursal,
    {{ clean_text('nombre') }}           as nombre,
    {{ clean_text('ciudad') }}           as ciudad,
    {{ clean_text('departamento') }}     as departamento,
    _batch_id, _loaded_at
from src
