-- audit_calidad_datos
-- Una fila por regla de calidad: cuántos registros la incumplen (en TODA la data cargada).
-- Los nombres de "regla" coinciden con tipo_incidencia de casos_calidad_opcionales.csv.
-- Los registros NO se borran en staging; aquí se cuantifican y los marts los marcan/aíslan.
-- Se separa "Costo nulo" (NULL) de "Costo vacío" ("") porque se tratan distinto.
with reglas as (
    select 'NULL en identificador' as regla, 'cliente' as entidad, 'id_cliente' as campo, 'ALTA' as severidad,
           count(*) filter (where id_cliente_estado <> 'OK') as afectados, count(*) as total
    from {{ ref('stg_oltp__cliente') }}
    union all
    select 'Precio negativo', 'producto', 'precio_lista', 'ALTA',
           count(*) filter (where dq_precio_negativo), count(*) from {{ ref('stg_oltp__producto') }}
    union all
    select 'FK huérfana', 'venta', 'id_cliente', 'ALTA',
           count(*) filter (where c.id_cliente is null), count(*)
    from {{ ref('stg_oltp__venta') }} v
    left join {{ ref('stg_oltp__cliente') }} c on c.id_cliente = v.id_cliente
    union all
    select 'Cantidad cero', 'venta_detalle', 'cantidad', 'ALTA',
           count(*) filter (where dq_cantidad_no_positiva), count(*) from {{ ref('stg_oltp__venta_detalle') }}
    union all
    select 'Descuento mayor a 100%', 'venta_detalle', 'descuento', 'ALTA',
           count(*) filter (where dq_descuento_fuera_rango), count(*) from {{ ref('stg_oltp__venta_detalle') }}
    union all
    select 'Subtotal inconsistente', 'venta_detalle', 'subtotal', 'MEDIA',
           count(*) filter (where dq_subtotal_inconsistente), count(*) from {{ ref('stg_oltp__venta_detalle') }}
    union all
    select 'Stock negativo', 'inventario', 'stock_disponible', 'ALTA',
           count(*) filter (where dq_stock_negativo), count(*) from {{ ref('stg_csv__inventario_bodega') }}
    union all
    select 'Vencimiento anterior al corte', 'inventario', 'fecha_vencimiento', 'MEDIA',
           count(*) filter (where dq_vencido_al_corte), count(*) from {{ ref('stg_csv__inventario_bodega') }}
    union all
    select 'Costo nulo', 'proveedores_precios', 'costo_proveedor', 'MEDIA',
           count(*) filter (where costo_proveedor_estado = 'NULO'), count(*) from {{ ref('stg_csv__proveedores_precios') }}
    union all
    select 'Costo vacío', 'proveedores_precios', 'costo_proveedor', 'MEDIA',
           count(*) filter (where costo_proveedor_estado = 'VACIO'), count(*) from {{ ref('stg_csv__proveedores_precios') }}
    union all
    select 'Meta cero', 'metas_ventas', 'meta_ventas', 'MEDIA',
           count(*) filter (where dq_meta_cero), count(*) from {{ ref('stg_csv__metas_ventas') }}
    union all
    select 'Devolución superior a venta', 'devoluciones', 'cantidad', 'ALTA',
           count(*) filter (where existe_venta_producto and excede_vendido), count(*) from {{ ref('int_devoluciones_validadas') }}
    union all
    select 'Devolución sin venta/producto', 'devoluciones', 'id_venta', 'ALTA',
           count(*) filter (where not existe_venta_producto), count(*) from {{ ref('int_devoluciones_validadas') }}
)
select regla, entidad, campo, severidad, afectados, total,
       round(afectados::numeric / nullif(total, 0) * 100, 2) as porcentaje,
       now() as calculado_en
from reglas
