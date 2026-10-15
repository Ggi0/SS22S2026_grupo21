-- fact_metas_ventas
-- GRANO: 1 fila por mes x sucursal.  PK: meta_key (sustituta).
-- fecha_key apunta al día 1 del mes (periodo_fecha). Se compara contra lo real en
-- mart_cumplimiento_metas.
with base as (
    select distinct on (periodo_fecha, id_sucursal) *
    from {{ ref('stg_csv__metas_ventas') }}
    where periodo_fecha is not null and id_sucursal is not null
    order by periodo_fecha, id_sucursal, _loaded_at desc
)
select
    (row_number() over (order by b.periodo_fecha, b.id_sucursal))::bigint as meta_key,
    coalesce(df.fecha_key, -1)     as fecha_key,
    coalesce(ds.sucursal_key, -1)  as sucursal_key,
    b.periodo,
    b.meta_ventas,
    b.meta_unidades,
    b.dq_meta_cero
from base b
left join {{ ref('dim_fecha') }}    df on df.fecha = b.periodo_fecha
left join {{ ref('dim_sucursal') }} ds on ds.sucursal_key = b.id_sucursal
