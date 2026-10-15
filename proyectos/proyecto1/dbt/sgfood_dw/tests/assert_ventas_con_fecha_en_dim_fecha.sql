-- Falla si una venta quedó con fecha desconocida: dim_fecha no cubre el rango (ver vars en dbt_project.yml).
select detalle_key, id_venta from {{ ref('fact_ventas') }} where fecha_key = -1
