{{ config(severity='warn') }}
-- ADVERTENCIA: metas de ventas en cero.
select meta_key, periodo from {{ ref('fact_metas_ventas') }} where dq_meta_cero
