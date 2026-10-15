-- dim_proveedor: 1 fila por proveedor (si el nombre cambia, queda el más reciente por vigencia).
-- proveedor_key = id_proveedor; -1 = NO DEFINIDO.
with ranked as (
    select distinct on (id_proveedor)
        id_proveedor as proveedor_key, id_proveedor, proveedor as nombre_proveedor
    from {{ ref('stg_csv__proveedores_precios') }}
    where id_proveedor is not null
    order by id_proveedor, fecha_vigencia desc nulls last, _loaded_at desc
)
select * from ranked
union all
select -1::bigint, -1::bigint, 'NO DEFINIDO'
