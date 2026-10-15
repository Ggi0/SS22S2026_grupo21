-- fact_precios_proveedor
-- GRANO: 1 fila por proveedor x producto x fecha de vigencia.  PK: precio_key (sustituta).
-- Compara el costo del proveedor contra el costo_base del producto.
-- costo_proveedor puede ser NULL (faltante); costo_proveedor_estado dice si fue NULO o VACIO.
with base as (
    select distinct on (id_proveedor, id_producto, fecha_vigencia) *
    from {{ ref('stg_csv__proveedores_precios') }}
    where id_proveedor is not null and id_producto is not null and fecha_vigencia is not null
    order by id_proveedor, id_producto, fecha_vigencia, _loaded_at desc
)
select
    (row_number() over (order by b.id_proveedor, b.id_producto, b.fecha_vigencia))::bigint as precio_key,
    coalesce(dpv.proveedor_key, -1)  as proveedor_key,
    coalesce(dp.producto_key, -1)    as producto_key,
    coalesce(df.fecha_key, -1)       as fecha_vigencia_key,
    b.costo_proveedor,
    b.costo_proveedor_estado,
    b.plazo_dias,
    dp.costo_base                    as costo_base_producto,
    round((b.costo_proveedor - dp.costo_base) / nullif(dp.costo_base, 0), 4) as variacion_vs_costo_base_pct
from base b
left join {{ ref('dim_proveedor') }} dpv on dpv.proveedor_key = b.id_proveedor
left join {{ ref('dim_producto') }}  dp  on dp.producto_key = b.id_producto
left join {{ ref('dim_fecha') }}     df  on df.fecha = b.fecha_vigencia
