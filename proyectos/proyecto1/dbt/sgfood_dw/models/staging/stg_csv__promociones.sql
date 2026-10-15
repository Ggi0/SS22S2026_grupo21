-- stg_csv__promociones: campañas por categoría y rango de fechas. Fuente: raw.csv_promociones
with src as (select * from {{ source('raw', 'csv_promociones') }}),
typed as (
    select
        {{ safe_int('id_promocion') }}            as id_promocion,
        {{ clean_text('nombre') }}                as nombre,
        {{ safe_date('fecha_inicio') }}           as fecha_inicio,
        {{ safe_date('fecha_fin') }}              as fecha_fin,
        {{ safe_int('id_categoria') }}            as id_categoria,
        {{ safe_numeric('porcentaje_descuento') }} as porcentaje_descuento,
        _batch_id, _loaded_at
    from src
)
select typed.*,
       coalesce(fecha_fin < fecha_inicio, false)                     as dq_rango_fechas_invalido,
       coalesce(porcentaje_descuento < 0 or porcentaje_descuento > 1, false) as dq_descuento_fuera_rango
from typed
