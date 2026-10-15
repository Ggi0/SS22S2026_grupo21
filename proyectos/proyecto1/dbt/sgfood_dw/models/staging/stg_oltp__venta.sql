-- stg_oltp__venta: encabezado de venta (estado en MAYÚSCULAS). Fuente: raw.oltp_venta
with src as (select * from {{ source('raw', 'oltp_venta') }})
select
    {{ safe_int('id_venta') }}         as id_venta,
    {{ safe_date('fecha') }}           as fecha,
    {{ safe_int('id_cliente') }}       as id_cliente,
    {{ safe_int('id_sucursal') }}      as id_sucursal,
    {{ clean_text('canal') }}          as canal,
    {{ clean_text('metodo_pago') }}    as metodo_pago,
    upper({{ clean_text('estado') }})  as estado,
    _batch_id, _loaded_at
from src
