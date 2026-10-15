-- int_devoluciones_validadas
-- Grano: 1 fila por devolución. Cruza con lo vendido (venta + producto) para detectar
--   * existe_venta_producto = false -> la devolución no corresponde a ninguna línea vendida
--   * excede_vendido        = true  -> se devuelve más de lo que se vendió
-- También trae sucursal/cliente de la venta y el precio neto unitario para valorizar.
with vendido as (
    select id_venta, id_producto,
           sum(cantidad) as cantidad_vendida,
           sum(subtotal) as monto_vendido
    from {{ ref('int_ventas_detalle_enriquecido') }}
    group by 1, 2
)
select
    dv.id_devolucion,
    dv.fecha,
    dv.id_venta,
    dv.id_producto,
    dv.cantidad,
    dv.motivo,
    dv.dq_cantidad_no_positiva,
    dv._loaded_at,
    vt.id_sucursal,
    vt.id_cliente,
    coalesce(vd.cantidad_vendida, 0)                          as cantidad_vendida,
    (vd.id_venta is not null)                                 as existe_venta_producto,
    coalesce(dv.cantidad > coalesce(vd.cantidad_vendida, 0), false) as excede_vendido,
    case when vd.cantidad_vendida > 0
         then round(vd.monto_vendido / vd.cantidad_vendida, 4) end  as precio_neto_unitario
from {{ ref('stg_csv__devoluciones') }} dv
left join vendido vd on vd.id_venta = dv.id_venta and vd.id_producto = dv.id_producto
left join {{ ref('stg_oltp__venta') }} vt on vt.id_venta = dv.id_venta
