-- dim_promocion: campañas. promocion_key = id_promocion; -1 = SIN PROMOCION
-- (la línea de venta no cayó en ninguna campaña vigente).
with promos as (
    select distinct on (pr.id_promocion)
        pr.id_promocion as promocion_key, pr.id_promocion,
        pr.nombre as nombre_promocion, pr.fecha_inicio, pr.fecha_fin,
        (pr.fecha_fin - pr.fecha_inicio + 1) as duracion_dias,
        pr.id_categoria, coalesce(c.nombre, 'NO_INFORMADO') as categoria,
        pr.porcentaje_descuento
    from {{ ref('stg_csv__promociones') }} pr
    left join {{ ref('stg_oltp__categoria') }} c on c.id_categoria = pr.id_categoria
    where pr.id_promocion is not null
    order by pr.id_promocion, pr._loaded_at desc
)
select * from promos
union all
select -1::bigint, -1::bigint, 'SIN PROMOCION', null::date, null::date, null::integer,
       null::bigint, 'SIN PROMOCION', null::numeric
