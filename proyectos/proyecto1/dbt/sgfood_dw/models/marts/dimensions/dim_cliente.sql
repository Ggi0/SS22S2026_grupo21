-- dim_cliente: 1 fila por cliente. Clientes con id NULO/VACÍO no se pueden identificar:
-- se excluyen (quedan contados en audit_calidad_datos). cliente_key -1 = NO DEFINIDO.
select
    id_cliente as cliente_key, id_cliente, nit, nombre as nombre_cliente,
    tipo_cliente, municipio, departamento, fecha_alta
from {{ ref('stg_oltp__cliente') }}
where id_cliente is not null
union all
select -1::bigint, -1::bigint, 'NO DEFINIDO', 'NO DEFINIDO', 'NO DEFINIDO',
       'NO DEFINIDO', 'NO DEFINIDO', null::date
