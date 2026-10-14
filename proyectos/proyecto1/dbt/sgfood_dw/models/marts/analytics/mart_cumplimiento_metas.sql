-- mart_cumplimiento_metas  (mart analítico, listo para BI)
-- GRANO: mes x sucursal. Compara META (CSV) contra VENTA REAL (OLTP, solo COMPLETADAS).
select
    f.periodo,
    s.nombre_sucursal,
    f.meta_ventas,
    coalesce(r.venta_real, 0)                                            as venta_real,
    coalesce(r.venta_real, 0) - f.meta_ventas                            as brecha_ventas,
    round(coalesce(r.venta_real, 0) / nullif(f.meta_ventas, 0) * 100, 2) as cumplimiento_ventas_pct,
    f.meta_unidades,
    coalesce(r.unidades_reales, 0)                                       as unidades_reales,
    round(coalesce(r.unidades_reales, 0)::numeric / nullif(f.meta_unidades, 0) * 100, 2) as cumplimiento_unidades_pct
from {{ ref('fact_metas_ventas') }} f
join {{ ref('dim_fecha') }}    d on d.fecha_key = f.fecha_key
join {{ ref('dim_sucursal') }} s on s.sucursal_key = f.sucursal_key
left join {{ ref('int_ventas_por_sucursal_mes') }} r
       on r.periodo_fecha = d.fecha and r.id_sucursal = s.id_sucursal
