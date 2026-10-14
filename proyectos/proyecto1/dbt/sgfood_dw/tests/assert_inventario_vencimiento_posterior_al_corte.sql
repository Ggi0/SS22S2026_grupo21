{{ config(severity='warn') }}
-- ADVERTENCIA: lotes cuyo vencimiento es anterior a la fecha de corte.
select inventario_key, fecha_vencimiento from {{ ref('fact_inventario') }} where dq_vencido_al_corte
