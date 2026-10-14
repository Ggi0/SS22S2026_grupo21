{{ config(severity='warn') }}
-- ADVERTENCIA: subtotal distinto de cantidad*precio*(1-descuento) (tolerancia 0.05).
select detalle_key, monto_neto from {{ ref('fact_ventas') }} where dq_subtotal_inconsistente
