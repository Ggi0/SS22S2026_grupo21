{{ config(severity='warn') }}
-- ADVERTENCIA: inventario con stock disponible negativo.
select inventario_key, stock_disponible from {{ ref('fact_inventario') }} where dq_stock_negativo
