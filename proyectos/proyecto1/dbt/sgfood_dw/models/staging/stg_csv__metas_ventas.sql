-- stg_csv__metas_ventas: metas mensuales por sucursal. periodo 'YYYY-MM' -> periodo_fecha (día 1).
-- Fuente: raw.csv_metas_ventas
with src as (select * from {{ source('raw', 'csv_metas_ventas') }}),
typed as (
    select
        btrim(periodo)                                       as periodo,
        {{ safe_date("btrim(periodo) || '-01'") }}           as periodo_fecha,
        {{ safe_int('id_sucursal') }}                        as id_sucursal,
        {{ safe_numeric('meta_ventas') }}                    as meta_ventas,
        {{ safe_int('meta_unidades') }}                      as meta_unidades,
        _batch_id, _loaded_at
    from src
)
select typed.*,
       coalesce(meta_ventas = 0, false) as dq_meta_cero
from typed
