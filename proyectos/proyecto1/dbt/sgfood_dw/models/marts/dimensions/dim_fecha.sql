-- dim_fecha: calendario (1 fila por día) en español. Rango en dbt_project.yml (vars).
-- Clave: fecha_key = YYYYMMDD (entero). fecha_key = -1 -> fecha desconocida.
with dias as (
    select d::date as fecha
    from generate_series('{{ var("fecha_inicio") }}'::date, '{{ var("fecha_fin") }}'::date, interval '1 day') d
)
select
    to_char(fecha, 'YYYYMMDD')::integer                                   as fecha_key,
    fecha,
    extract(year from fecha)::integer                                     as anio,
    extract(quarter from fecha)::integer                                  as trimestre,
    extract(month from fecha)::integer                                    as mes,
    (array['Enero','Febrero','Marzo','Abril','Mayo','Junio','Julio','Agosto',
           'Septiembre','Octubre','Noviembre','Diciembre'])[extract(month from fecha)::integer] as nombre_mes,
    to_char(fecha, 'YYYY-MM')                                             as periodo,
    extract(isodow from fecha)::integer                                   as dia_semana,
    (array['Lunes','Martes','Miércoles','Jueves','Viernes','Sábado','Domingo'])[extract(isodow from fecha)::integer] as nombre_dia,
    extract(isodow from fecha)::integer >= 6                              as es_fin_de_semana,
    extract(week from fecha)::integer                                     as semana_iso
from dias
union all
select -1, date '1900-01-01', 0, 0, 0, 'NO DEFINIDO', '0000-00', 0, 'NO DEFINIDO', false, 0
