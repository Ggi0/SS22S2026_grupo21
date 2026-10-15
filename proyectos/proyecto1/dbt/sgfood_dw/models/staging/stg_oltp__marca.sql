-- stg_oltp__marca: marcas de producto. Fuente: raw.oltp_marca
with src as (select * from {{ source('raw', 'oltp_marca') }})
select
    {{ safe_int('id_marca') }}  as id_marca,
    {{ clean_text('nombre') }}  as nombre,
    _batch_id, _loaded_at
from src
