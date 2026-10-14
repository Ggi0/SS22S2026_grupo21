-- stg_csv__inventario_bodega: snapshot de inventario + banderas de stock/vencimiento.
-- Fuente: raw.csv_inventario_bodega
with src as (select * from {{ source('raw', 'csv_inventario_bodega') }}),
typed as (
    select
        {{ safe_date('fecha_corte') }}        as fecha_corte,
        {{ safe_int('id_sucursal') }}         as id_sucursal,
        {{ safe_int('id_producto') }}         as id_producto,
        {{ safe_int('stock_disponible') }}    as stock_disponible,
        {{ safe_int('stock_minimo') }}        as stock_minimo,
        {{ safe_int('stock_maximo') }}        as stock_maximo,
        {{ clean_text('lote') }}              as lote,
        {{ safe_date('fecha_vencimiento') }}  as fecha_vencimiento,
        {{ estado_dato('fecha_vencimiento') }} as fecha_vencimiento_estado,
        _batch_id, _loaded_at
    from src
)
select typed.*,
       coalesce(stock_disponible < 0, false)                  as dq_stock_negativo,
       coalesce(fecha_vencimiento < fecha_corte, false)       as dq_vencido_al_corte,
       coalesce(stock_disponible < stock_minimo, false)       as bajo_minimo,
       coalesce(stock_disponible > stock_maximo, false)       as sobre_maximo
from typed
