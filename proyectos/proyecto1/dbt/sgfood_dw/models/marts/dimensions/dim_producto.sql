-- dim_producto: producto con categoría y marca DESNORMALIZADAS (estrella, no copo de nieve).
-- producto_key = id_producto; -1 = NO DEFINIDO (ej. producto del CSV que no existe en el OLTP).
select
    p.id_producto                                   as producto_key,
    p.id_producto,
    p.sku,
    p.nombre                                        as nombre_producto,
    p.id_categoria,
    coalesce(c.nombre, 'NO_INFORMADO')              as categoria,
    p.id_marca,
    coalesce(m.nombre, 'NO_INFORMADO')              as marca,
    p.unidad_medida,
    p.costo_base,
    p.precio_lista,
    p.activo,
    case when p.precio_lista > 0
         then round((p.precio_lista - p.costo_base) / p.precio_lista, 4) end as margen_lista_pct
from {{ ref('stg_oltp__producto') }} p
left join {{ ref('stg_oltp__categoria') }} c on c.id_categoria = p.id_categoria
left join {{ ref('stg_oltp__marca') }}     m on m.id_marca     = p.id_marca
where p.id_producto is not null
union all
select -1::bigint, -1::bigint, 'NO DEFINIDO', 'NO DEFINIDO', null::bigint, 'NO DEFINIDO',
       null::bigint, 'NO DEFINIDO', 'NO DEFINIDO', null::numeric, null::numeric, null::boolean, null::numeric
