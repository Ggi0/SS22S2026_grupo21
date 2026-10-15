-- stg_oltp__categoria: categorías de producto. Fuente: raw.oltp_categoria
with src as (select * from {{ source('raw', 'oltp_categoria') }})
select
    {{ safe_int('id_categoria') }}  as id_categoria,
    {{ clean_text('nombre') }}      as nombre,
    _batch_id, _loaded_at
from src
