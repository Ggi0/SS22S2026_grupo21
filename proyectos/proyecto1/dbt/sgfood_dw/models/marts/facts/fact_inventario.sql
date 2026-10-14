-- fact_inventario  (snapshot periódico)
-- GRANO: 1 fila por fecha_corte x sucursal x producto.  PK: inventario_key (sustituta).
-- Medidas semi-aditivas: stock_* se suman entre sucursales/productos, NO entre fechas.
with base as (
    select distinct on (fecha_corte, id_sucursal, id_producto) *
    from {{ ref('stg_csv__inventario_bodega') }}
    where fecha_corte is not null and id_sucursal is not null and id_producto is not null
    order by fecha_corte, id_sucursal, id_producto, _loaded_at desc
)
select
    (row_number() over (order by b.fecha_corte, b.id_sucursal, b.id_producto))::bigint as inventario_key,
    coalesce(df.fecha_key, -1)       as fecha_key,
    coalesce(ds.sucursal_key, -1)    as sucursal_key,
    coalesce(dp.producto_key, -1)    as producto_key,
    b.lote,
    b.fecha_vencimiento,
    (b.fecha_vencimiento - b.fecha_corte) as dias_para_vencer,
    b.fecha_vencimiento_estado,                 -- NULO / VACIO / OK
    b.stock_disponible,
    b.stock_minimo,
    b.stock_maximo,
    b.bajo_minimo,
    b.sobre_maximo,
    b.dq_stock_negativo,
    b.dq_vencido_al_corte
from base b
left join {{ ref('dim_fecha') }}    df on df.fecha = b.fecha_corte
left join {{ ref('dim_sucursal') }} ds on ds.sucursal_key = b.id_sucursal
left join {{ ref('dim_producto') }} dp on dp.producto_key = b.id_producto
