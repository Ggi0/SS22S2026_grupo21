-- stg_csv__devoluciones: devoluciones de producto. Fuente: raw.csv_devoluciones
with src as (select * from {{ source('raw', 'csv_devoluciones') }}),
typed as (
    select
        {{ safe_int('id_devolucion') }}  as id_devolucion,
        {{ safe_date('fecha') }}         as fecha,
        {{ safe_int('id_venta') }}       as id_venta,
        {{ safe_int('id_producto') }}    as id_producto,
        {{ safe_int('cantidad') }}       as cantidad,
        {{ clean_text('motivo') }}       as motivo,
        _batch_id, _loaded_at
    from src
)
select typed.*,
       coalesce(cantidad <= 0, false) as dq_cantidad_no_positiva
from typed
