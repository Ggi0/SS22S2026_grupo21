-- stg_oltp__producto: productos tipados + bandera de precio negativo. Fuente: raw.oltp_producto
with src as (select * from {{ source('raw', 'oltp_producto') }}),
typed as (
    select
        {{ safe_int('id_producto') }}      as id_producto,
        {{ clean_text('sku') }}            as sku,
        {{ clean_text('nombre') }}         as nombre,
        {{ safe_int('id_categoria') }}     as id_categoria,
        {{ safe_int('id_marca') }}         as id_marca,
        {{ clean_text('unidad_medida') }}  as unidad_medida,
        {{ safe_numeric('costo_base') }}   as costo_base,
        {{ safe_numeric('precio_lista') }} as precio_lista,
        {{ estado_dato('precio_lista') }}  as precio_lista_estado,   -- NULO / VACIO / OK
        {{ safe_bool('activo') }}          as activo,
        _batch_id, _loaded_at
    from src
)
select typed.*,
       coalesce(precio_lista < 0, false) as dq_precio_negativo
from typed
