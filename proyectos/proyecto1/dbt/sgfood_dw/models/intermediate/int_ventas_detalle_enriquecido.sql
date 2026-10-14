-- int_ventas_detalle_enriquecido
-- Grano: 1 fila por línea de venta. Une detalle + encabezado + costo del producto
-- y calcula los montos. Es la base de fact_ventas y de los KPIs de metas/promos.
-- LEFT JOIN: nunca se pierde una línea aunque su venta/producto no exista.
select
    d.id_detalle,
    d.id_venta,
    d.id_producto,
    d.cantidad,
    d.precio_unitario,
    d.descuento,
    d.subtotal,
    d.subtotal_calculado,
    v.fecha,
    v.id_cliente,
    v.id_sucursal,
    v.canal,
    v.metodo_pago,
    v.estado                                         as estado_venta,
    coalesce(v.estado = 'COMPLETADA', false)         as es_venta_efectiva,  -- ANULADA/PENDIENTE no suman ingreso
    p.costo_base,
    d.cantidad * d.precio_unitario                   as monto_bruto,
    d.cantidad * d.precio_unitario - d.subtotal      as monto_descuento,
    d.cantidad * p.costo_base                        as costo_estimado,
    d.subtotal - d.cantidad * p.costo_base           as margen_estimado,
    d.dq_cantidad_no_positiva,
    d.dq_descuento_fuera_rango,
    d.dq_subtotal_inconsistente
from {{ ref('stg_oltp__venta_detalle') }} d
left join {{ ref('stg_oltp__venta') }}    v on v.id_venta    = d.id_venta
left join {{ ref('stg_oltp__producto') }} p on p.id_producto = d.id_producto
