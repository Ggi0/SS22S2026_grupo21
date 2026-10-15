-- dim_canal_pago: dimensión "basura" (junk) que agrupa 2 atributos de baja cardinalidad
-- de la venta: canal y método de pago. 1 fila por combinación; -1 = NO DEFINIDO.
with combos as (
    select distinct canal, metodo_pago from {{ ref('stg_oltp__venta') }}
)
select (row_number() over (order by canal, metodo_pago))::bigint as canal_pago_key,
       canal, metodo_pago
from combos
union all
select -1::bigint, 'NO DEFINIDO', 'NO DEFINIDO'
