-- int_ventas_promocion
-- Grano: 1 fila por línea de venta que cayó dentro de una promoción
-- (misma categoría del producto y fecha entre inicio y fin).
-- Si varias promos aplican, gana la de mayor descuento (desempate: menor id).
select distinct on (e.id_detalle)
    e.id_detalle,
    pr.id_promocion
from {{ ref('int_ventas_detalle_enriquecido') }} e
join {{ ref('stg_oltp__producto') }}  p  on p.id_producto = e.id_producto
join {{ ref('stg_csv__promociones') }} pr
     on pr.id_categoria = p.id_categoria
    and e.fecha between pr.fecha_inicio and pr.fecha_fin
where pr.id_promocion is not null
order by e.id_detalle, pr.porcentaje_descuento desc, pr.id_promocion
