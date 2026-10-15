{#- ============================================================================
  data_quality.sql — macros de limpieza usadas por TODA la capa staging.
  Principio: raw trae todo como TEXT; aquí se tipa sin que una fila "sucia"
  haga fallar la corrida (un valor inválido se vuelve NULL y queda marcado).

  NULL vs VACÍO (requisito del proyecto):
    NULL  = dato ausente        VACÍO = campo presente con ""
  Se distinguen con estado_dato() y, en columnas de texto, con etiquetas
  distintas en clean_text().
============================================================================= -#}

{# 'NULO' | 'VACIO' | 'OK'  -> conserva la diferencia entre NULL y "" #}
{% macro estado_dato(col) -%}
case when {{ col }} is null then 'NULO'
     when btrim({{ col }}) = '' then 'VACIO'
     else 'OK' end
{%- endmacro %}

{# Texto limpio. NULL y VACÍO reciben etiquetas DISTINTAS (configurables). #}
{% macro clean_text(col, null_label='NO_INFORMADO', empty_label='SIN_VALOR') -%}
case when {{ col }} is null then '{{ null_label }}'
     when btrim({{ col }}) = '' then '{{ empty_label }}'
     else btrim({{ col }}) end
{%- endmacro %}

{# Casts seguros: si el texto no tiene el formato esperado devuelve NULL. #}
{% macro safe_int(col) -%}
case when btrim({{ col }}) ~ '^-?[0-9]+$' then btrim({{ col }})::bigint end
{%- endmacro %}

{% macro safe_numeric(col) -%}
case when btrim({{ col }}) ~ '^-?[0-9]+(\.[0-9]+)?$' then btrim({{ col }})::numeric end
{%- endmacro %}

{% macro safe_date(col) -%}
case when btrim({{ col }}) ~ '^[0-9]{4}-[0-9]{2}-[0-9]{2}$' then btrim({{ col }})::date end
{%- endmacro %}

{% macro safe_bool(col) -%}
case when lower(btrim({{ col }})) in ('true','t','1','si','sí','yes') then true
     when lower(btrim({{ col }})) in ('false','f','0','no') then false end
{%- endmacro %}
