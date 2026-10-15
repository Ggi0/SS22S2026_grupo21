{{ config(severity='warn') }}
-- ADVERTENCIA: líneas de venta cuyo cliente no existe (cayeron en cliente_key = -1).
select detalle_key, id_venta from {{ ref('fact_ventas') }} where cliente_key = -1
