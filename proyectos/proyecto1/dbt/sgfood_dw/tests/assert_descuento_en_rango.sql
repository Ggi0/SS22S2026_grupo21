-- Falla si hay descuentos fuera de [0,1] en las líneas de venta.
select detalle_key, descuento_pct from {{ ref('fact_ventas') }}
where descuento_pct < 0 or descuento_pct > 1
