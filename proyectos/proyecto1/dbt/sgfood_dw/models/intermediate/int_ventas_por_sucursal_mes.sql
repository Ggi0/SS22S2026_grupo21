-- int_ventas_por_sucursal_mes
-- Grano: sucursal x mes. Ventas REALES (solo COMPLETADAS) para compararlas con las metas.
select
    date_trunc('month', fecha)::date  as periodo_fecha,
    id_sucursal,
    sum(subtotal)                     as venta_real,
    sum(cantidad)                     as unidades_reales,
    count(distinct id_venta)          as num_ventas
from {{ ref('int_ventas_detalle_enriquecido') }}
where es_venta_efectiva and fecha is not null and id_sucursal is not null
group by 1, 2
