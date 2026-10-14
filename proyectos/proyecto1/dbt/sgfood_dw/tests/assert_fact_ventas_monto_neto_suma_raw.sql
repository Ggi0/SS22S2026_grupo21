-- Falla si la suma de monto_neto en el hecho difiere de la suma de subtotal en raw (tolerancia 0.01).
select r.s_raw, f.s_fact
from (select sum(btrim(subtotal)::numeric) as s_raw from {{ source('raw', 'oltp_venta_detalle') }}) r
cross join (select sum(monto_neto) as s_fact from {{ ref('fact_ventas') }}) f
where abs(r.s_raw - f.s_fact) > 0.01
