-- stg_oltp__venta_detalle: líneas de venta + subtotal recalculado + banderas dq_*.
-- Fuente: raw.oltp_venta_detalle
with src as (select * from {{ source('raw', 'oltp_venta_detalle') }}),
typed as (
    select
        {{ safe_int('id_detalle') }}        as id_detalle,
        {{ safe_int('id_venta') }}          as id_venta,
        {{ safe_int('id_producto') }}       as id_producto,
        {{ safe_int('cantidad') }}          as cantidad,
        {{ safe_numeric('precio_unitario') }} as precio_unitario,
        {{ safe_numeric('descuento') }}     as descuento,
        {{ safe_numeric('subtotal') }}      as subtotal,
        _batch_id, _loaded_at
    from src
)
select typed.*,
       round(cantidad * precio_unitario * (1 - coalesce(descuento, 0)), 2) as subtotal_calculado,
       coalesce(cantidad <= 0, false)                                      as dq_cantidad_no_positiva,
       coalesce(descuento < 0 or descuento > 1, false)                     as dq_descuento_fuera_rango,
       coalesce(abs(subtotal - round(cantidad * precio_unitario * (1 - coalesce(descuento, 0)), 2)) > 0.05, false)
                                                                           as dq_subtotal_inconsistente
from typed
