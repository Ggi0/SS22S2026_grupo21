{#- Prueba genérica: la combinación de columnas es única (grano de una tabla de
    hechos o de una dimensión con llave compuesta). Devuelve las filas repetidas. -#}
{% test unique_combination_of_columns(model, combination_of_columns) %}
select {{ combination_of_columns | join(', ') }}, count(*) as n_filas
from {{ model }}
group by {{ combination_of_columns | join(', ') }}
having count(*) > 1
{% endtest %}
