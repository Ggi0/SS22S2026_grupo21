{{ config(severity='warn') }}
-- ADVERTENCIA: devoluciones mayores a lo vendido, o sin venta/producto que las respalde.
select devolucion_key, cantidad, cantidad_vendida
from {{ ref('fact_devoluciones') }}
where excede_vendido or not existe_venta_producto
