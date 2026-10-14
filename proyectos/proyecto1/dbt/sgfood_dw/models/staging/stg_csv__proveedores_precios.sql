-- stg_csv__proveedores_precios: lista de costos por proveedor.
-- costo_proveedor_estado distingue NULO ("NULL" en el CSV) de VACIO (""). Fuente: raw.csv_proveedores_precios
with src as (select * from {{ source('raw', 'csv_proveedores_precios') }})
select
    {{ safe_int('id_proveedor') }}          as id_proveedor,
    {{ clean_text('proveedor') }}           as proveedor,
    {{ safe_int('id_producto') }}           as id_producto,
    {{ safe_numeric('costo_proveedor') }}   as costo_proveedor,
    {{ estado_dato('costo_proveedor') }}    as costo_proveedor_estado,   -- NULO / VACIO / OK
    {{ safe_int('plazo_dias') }}            as plazo_dias,
    {{ safe_date('fecha_vigencia') }}       as fecha_vigencia,
    _batch_id, _loaded_at
from src
