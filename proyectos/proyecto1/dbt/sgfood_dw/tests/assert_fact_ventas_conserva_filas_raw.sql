-- Falla si fact_ventas tiene distinto # de filas que raw.oltp_venta_detalle (no se debe perder ninguna línea).
select r.n_raw, f.n_fact
from (select count(*) as n_raw from {{ source('raw', 'oltp_venta_detalle') }}) r
cross join (select count(*) as n_fact from {{ ref('fact_ventas') }}) f
where r.n_raw <> f.n_fact
