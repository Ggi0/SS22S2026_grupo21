{{ config(severity='warn') }}
-- ADVERTENCIA: precios de proveedor sin costo (NULL o vacío). La columna costo_proveedor_estado indica cuál.
select precio_key, costo_proveedor_estado from {{ ref('fact_precios_proveedor') }} where costo_proveedor is null
