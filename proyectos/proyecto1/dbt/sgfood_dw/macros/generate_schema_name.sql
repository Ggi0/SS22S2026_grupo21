{#- ============================================================================
  generate_schema_name — usa el schema indicado en dbt_project.yml TAL CUAL.
  Por defecto dbt los concatena (staging_staging); aquí queremos nombres
  limpios: raw / staging / intermediate / marts.
============================================================================= -#}
{% macro generate_schema_name(custom_schema_name, node) -%}
    {%- if custom_schema_name is none -%}
        {{ target.schema }}
    {%- else -%}
        {{ custom_schema_name | trim }}
    {%- endif -%}
{%- endmacro %}
