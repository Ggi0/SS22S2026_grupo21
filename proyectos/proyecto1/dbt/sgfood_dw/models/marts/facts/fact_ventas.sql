-- fact_ventas
-- GRANO: 1 fila por línea de venta (venta_detalle).  PK: detalle_key (= id_detalle).
-- Dimensiones: fecha, cliente, sucursal, producto, canal_pago, promocion.
-- Llaves no resueltas (ej. cliente huérfano) apuntan al miembro -1 "NO DEFINIDO":
-- así NUNCA se pierde una venta ni se rompe la FK.
-- Medidas aditivas: cantidad, monto_bruto, monto_descuento, monto_neto, costo_estimado, margen_estimado.
-- Para ingresos use siempre es_venta_efectiva = true (excluye ANULADA/PENDIENTE).
select
    e.id_detalle                                  as detalle_key,
    e.id_venta,                                                          -- dimensión degenerada
    coalesce(df.fecha_key, -1)                    as fecha_key,
    coalesce(dc.cliente_key, -1)                  as cliente_key,
    coalesce(ds.sucursal_key, -1)                 as sucursal_key,
    coalesce(dp.producto_key, -1)                 as producto_key,
    coalesce(dcp.canal_pago_key, -1)              as canal_pago_key,
    coalesce(dpr.promocion_key, -1)               as promocion_key,
    e.estado_venta,
    e.es_venta_efectiva,
    e.cantidad,
    e.precio_unitario,
    e.descuento                                   as descuento_pct,
    e.monto_bruto,
    e.monto_descuento,
    e.subtotal                                    as monto_neto,
    e.costo_estimado,
    e.margen_estimado,
    e.dq_subtotal_inconsistente
from {{ ref('int_ventas_detalle_enriquecido') }} e
left join {{ ref('int_ventas_promocion') }} ip  on ip.id_detalle = e.id_detalle
left join {{ ref('dim_fecha') }}      df  on df.fecha = e.fecha
left join {{ ref('dim_cliente') }}    dc  on dc.cliente_key = e.id_cliente
left join {{ ref('dim_sucursal') }}   ds  on ds.sucursal_key = e.id_sucursal
left join {{ ref('dim_producto') }}   dp  on dp.producto_key = e.id_producto
left join {{ ref('dim_canal_pago') }} dcp on dcp.canal = e.canal and dcp.metodo_pago = e.metodo_pago
left join {{ ref('dim_promocion') }}  dpr on dpr.promocion_key = ip.id_promocion
where e.id_detalle is not null
