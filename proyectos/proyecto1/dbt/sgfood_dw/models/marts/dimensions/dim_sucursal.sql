-- dim_sucursal: 1 fila por sucursal. sucursal_key = id_sucursal; -1 = NO DEFINIDO.
select id_sucursal as sucursal_key, id_sucursal, nombre as nombre_sucursal, ciudad, departamento
from {{ ref('stg_oltp__sucursal') }}
where id_sucursal is not null
union all
select -1::bigint, -1::bigint, 'NO DEFINIDO', 'NO DEFINIDO', 'NO DEFINIDO'
