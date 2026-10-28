-- =====================================================================
-- 03_comparacion_optimizacion.sql
-- OBJETIVO: Comparar costo/rendimiento de las MISMAS consultas sobre:
--     A) tabla pública original
--     B) taxi_clean_sin_opt  (limpia, sin partición/cluster)
--     C) taxi_clean_part     (limpia, partición por fecha + cluster)
-- CUMPLE:   Alcance "Comparar el rendimiento antes y después"
--           Rúbrica 1.3 y 2.5
--
-- ANTES DE EJECUTAR (MUY IMPORTANTE):
--   1. En el editor: Más (⋮) > Configuración de consulta >
--      DESACTIVAR "Usar resultados almacenados en caché".
--      (Con caché activa verás 0 bytes y la comparación no sirve.)
--   2. Reemplazar TU_PROYECTO por tu Project ID.
--   3. Antes de ejecutar cada consulta, toma captura del validador
--      ("Esta consulta procesará X MB") -> evidencia de bytes.
--   4. Ejecuta CADA consulta por separado. El comentario "-- BENCH ..."
--      es la etiqueta que usa la consulta de resumen del final.
--   NOTA: A trabaja con datos sin limpiar, por eso sus resultados pueden
--         diferir ligeramente de B y C. B y C son idénticas en contenido.
-- =====================================================================

-- ======================= Q1: una zona, un mes ========================
-- Filtro por fecha (partición) + filtro por zona (cluster)

-- BENCH Q1_A
SELECT COUNT(*) AS viajes, ROUND(AVG(fare_amount), 2) AS tarifa_prom, ROUND(AVG(tip_amount), 2) AS propina_prom
FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022`
WHERE DATE(pickup_datetime) BETWEEN '2022-06-01' AND '2022-06-30'
  AND pickup_location_id = '132';

-- BENCH Q1_B
SELECT COUNT(*) AS viajes, ROUND(AVG(fare_amount), 2) AS tarifa_prom, ROUND(AVG(tip_amount), 2) AS propina_prom
FROM `ID_Proyecto_GCP.nyc_taxi_2022.taxi_clean_sin_opt`
WHERE DATE(pickup_datetime) BETWEEN '2022-06-01' AND '2022-06-30'
  AND pickup_location_id = '132';

-- BENCH Q1_C
SELECT COUNT(*) AS viajes, ROUND(AVG(fare_amount), 2) AS tarifa_prom, ROUND(AVG(tip_amount), 2) AS propina_prom
FROM `ID_Proyecto_GCP.nyc_taxi_2022.taxi_clean_part`
WHERE DATE(pickup_datetime) BETWEEN '2022-06-01' AND '2022-06-30'
  AND pickup_location_id = '132';

-- ================= Q2: una semana, ruta específica ===================
-- Filtro por rango corto de fechas + ruta (pickup y dropoff = ambos cluster)

-- BENCH Q2_A
SELECT EXTRACT(HOUR FROM pickup_datetime) AS hora, COUNT(*) AS viajes, ROUND(AVG(total_amount), 2) AS total_prom
FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022`
WHERE DATE(pickup_datetime) BETWEEN '2022-03-07' AND '2022-03-13'
  AND pickup_location_id = '237' AND dropoff_location_id = '236'
GROUP BY hora ORDER BY hora;

-- BENCH Q2_B
SELECT EXTRACT(HOUR FROM pickup_datetime) AS hora, COUNT(*) AS viajes, ROUND(AVG(total_amount), 2) AS total_prom
FROM `ID_Proyecto_GCP.nyc_taxi_2022.taxi_clean_sin_opt`
WHERE DATE(pickup_datetime) BETWEEN '2022-03-07' AND '2022-03-13'
  AND pickup_location_id = '237' AND dropoff_location_id = '236'
GROUP BY hora ORDER BY hora;

-- BENCH Q2_C
SELECT EXTRACT(HOUR FROM pickup_datetime) AS hora, COUNT(*) AS viajes, ROUND(AVG(total_amount), 2) AS total_prom
FROM `ID_Proyecto_GCP.nyc_taxi_2022.taxi_clean_part`
WHERE DATE(pickup_datetime) BETWEEN '2022-03-07' AND '2022-03-13'
  AND pickup_location_id = '237' AND dropoff_location_id = '236'
GROUP BY hora ORDER BY hora;

-- ============= Q3: solo fecha (un día), sin filtro de zona ============
-- Aquí solo ayuda la PARTICIÓN; sirve para mostrar el aporte de cada técnica.

-- BENCH Q3_A
SELECT pickup_location_id, COUNT(*) AS viajes
FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022`
WHERE DATE(pickup_datetime) = '2022-09-15'
GROUP BY pickup_location_id ORDER BY viajes DESC LIMIT 10;

-- BENCH Q3_B
SELECT pickup_location_id, COUNT(*) AS viajes
FROM `ID_Proyecto_GCP.nyc_taxi_2022.taxi_clean_sin_opt`
WHERE DATE(pickup_datetime) = '2022-09-15'
GROUP BY pickup_location_id ORDER BY viajes DESC LIMIT 10;

-- BENCH Q3_C
SELECT pickup_location_id, COUNT(*) AS viajes
FROM `ID_Proyecto_GCP.nyc_taxi_2022.taxi_clean_part`
WHERE DATE(pickup_datetime) = '2022-09-15'
GROUP BY pickup_location_id ORDER BY viajes DESC LIMIT 10;

-- =====================================================================
-- RESUMEN AUTOMÁTICO: bytes procesados, bytes facturados, slot-ms y tiempo.
-- Ejecutar DESPUÉS de correr las 9 consultas (esta puede tener caché activa).
-- Cambia `region-us` si tu dataset está en otra ubicación.
-- Guardar el resultado en tabla para el dashboard/README:
-- =====================================================================
CREATE OR REPLACE TABLE `ID_Proyecto_GCP.nyc_taxi_2022.benchmark_optimizacion` AS
SELECT
  REGEXP_EXTRACT(query, r'BENCH (Q[0-9]_[ABC])')           AS consulta,
  CASE REGEXP_EXTRACT(query, r'BENCH Q[0-9]_([ABC])')
    WHEN 'A' THEN 'Publica (original)'
    WHEN 'B' THEN 'Limpia sin optimizar'
    WHEN 'C' THEN 'Particion + cluster' END                 AS variante,
  ROUND(total_bytes_processed / POW(1024, 2), 2)            AS mb_procesados,
  ROUND(total_bytes_billed   / POW(1024, 2), 2)             AS mb_facturados,
  total_slot_ms                                             AS slot_ms,
  TIMESTAMP_DIFF(end_time, start_time, MILLISECOND)         AS duracion_ms,
  creation_time
FROM `region-us`.INFORMATION_SCHEMA.JOBS_BY_USER
WHERE creation_time > TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 3 HOUR)
  AND job_type = 'QUERY'
  AND statement_type = 'SELECT'
  AND state = 'DONE'
  AND error_result IS NULL
  AND query LIKE '%-- BENCH Q%'
  AND query NOT LIKE '%INFORMATION_SCHEMA%'
QUALIFY ROW_NUMBER() OVER (
  PARTITION BY REGEXP_EXTRACT(query, r'BENCH (Q[0-9]_[ABC])') ORDER BY creation_time DESC) = 1;

-- Vista final: reducción % de bytes de cada variante frente a la pública y frente a B
SELECT
  SUBSTR(consulta, 1, 2) AS q,
  MAX(IF(variante = 'Publica (original)',     mb_procesados, NULL)) AS mb_publica,
  MAX(IF(variante = 'Limpia sin optimizar',   mb_procesados, NULL)) AS mb_sin_opt,
  MAX(IF(variante = 'Particion + cluster',    mb_procesados, NULL)) AS mb_optimizada,
  ROUND(100 * (1 - SAFE_DIVIDE(
    MAX(IF(variante = 'Particion + cluster', mb_procesados, NULL)),
    MAX(IF(variante = 'Limpia sin optimizar', mb_procesados, NULL)))), 1) AS pct_reduccion_vs_sin_opt,
  ROUND(100 * (1 - SAFE_DIVIDE(
    MAX(IF(variante = 'Particion + cluster', mb_procesados, NULL)),
    MAX(IF(variante = 'Publica (original)', mb_procesados, NULL)))), 1) AS pct_reduccion_vs_publica
FROM `ID_Proyecto_GCP.nyc_taxi_2022.benchmark_optimizacion`
GROUP BY q ORDER BY q;
