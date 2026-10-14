-- fact_devoluciones
-- GRANO: 1 fila por devolución.  PK: devolucion_key (= id_devolucion).
-- Dimensiones: fecha, producto, sucursal y cliente (estos dos heredados de la venta original).
-- Banderas: existe_venta_producto / excede_vendido (calidad, ver audit_calidad_datos).
with base as (
    select distinct on (id_devolucion) *
    from {{ ref('int_devoluciones_validadas') }}
    where id_devolucion is not null
    order by id_devolucion, _loaded_at desc
)
select
    b.id_devolucion                                as devolucion_key,
    b.id_venta,                                                          -- dimensión degenerada
    coalesce(df.fecha_key, -1)                     as fecha_key,
    coalesce(dp.producto_key, -1)                  as producto_key,
    coalesce(ds.sucursal_key, -1)                  as sucursal_key,
    coalesce(dc.cliente_key, -1)                   as cliente_key,
    b.motivo,
    b.cantidad,
    b.cantidad_vendida,
    b.existe_venta_producto,
    b.excede_vendido,
    round(b.cantidad * b.precio_neto_unitario, 2)  as monto_devuelto_estimado
from base b
left join {{ ref('dim_fecha') }}    df on df.fecha = b.fecha
left join {{ ref('dim_producto') }} dp on dp.producto_key = b.id_producto
left join {{ ref('dim_sucursal') }} ds on ds.sucursal_key = b.id_sucursal
left join {{ ref('dim_cliente') }}  dc on dc.cliente_key = b.id_cliente
