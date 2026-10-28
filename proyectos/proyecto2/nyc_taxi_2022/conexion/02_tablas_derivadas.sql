-- =====================================================================
-- 02_tablas_derivadas.sql
-- OBJETIVO: Crear en el proyecto propio las tablas derivadas limpias:
--   (1) taxi_clean_sin_opt : datos limpios SIN partición ni clustering
--   (2) taxi_clean_part    : mismos datos, PARTICIONADA por fecha y
--                            CLUSTERIZADA por ubicaciones
--   (3) calidad_resumen    : cuántos registros se descartaron y por qué
-- CUMPLE:   Alcance "Crear tablas derivadas" + "Particiones y clustering"
--           Rúbrica 1.2, 1.3, 2.3 (variables derivadas)
-- ANTES DE EJECUTAR: reemplazar TU_PROYECTO por tu Project ID (Ctrl+H).
-- =====================================================================

-- ---------- (1) TABLA LIMPIA SIN OPTIMIZAR ----------
-- Reglas de limpieza (justificadas en 01_eda, secciones B y E):
--   * Solo enero-noviembre 2022 (diciembre tiene 117 filas residuales)
--   * passenger_count 1..6 (descarta 0, NULL y valores absurdos 7-9)
--   * payment_type 1-4 (descarta 0 = desconocido, que coincide con NULLs)
--   * distancia 0.1-100 millas, tarifa 2.5-500 USD, total > 0
--   * duración 1-180 min y velocidad media <= 80 mph
CREATE OR REPLACE TABLE `ID_Proyecto_GCP.nyc_taxi_2022.taxi_clean_sin_opt` AS
WITH base AS (
  SELECT
    -- Llave determinística del viaje (sirve luego para muestreo reproducible)
    FARM_FINGERPRINT(CONCAT(
      CAST(pickup_datetime AS STRING), '|', CAST(dropoff_datetime AS STRING), '|',
      pickup_location_id, '|', dropoff_location_id, '|',
      CAST(total_amount AS STRING), '|', IFNULL(vendor_id, ''))) AS trip_key,
    pickup_datetime,
    dropoff_datetime,
    vendor_id,
    passenger_count,
    CAST(trip_distance AS FLOAT64)  AS trip_distance,
    rate_code,
    payment_type,
    CAST(fare_amount AS FLOAT64)    AS fare_amount,
    CAST(extra AS FLOAT64)          AS extra,
    CAST(mta_tax AS FLOAT64)        AS mta_tax,
    CAST(tip_amount AS FLOAT64)     AS tip_amount,
    CAST(tolls_amount AS FLOAT64)   AS tolls_amount,
    CAST(imp_surcharge AS FLOAT64)  AS imp_surcharge,
    COALESCE(CAST(airport_fee AS FLOAT64), 0) AS airport_fee,
    CAST(total_amount AS FLOAT64)   AS total_amount,
    pickup_location_id,
    dropoff_location_id,
    TIMESTAMP_DIFF(dropoff_datetime, pickup_datetime, SECOND) / 60.0 AS trip_duration_min
  FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022`
  WHERE pickup_datetime >= TIMESTAMP('2022-01-01')
    AND pickup_datetime <  TIMESTAMP('2022-12-01')
    AND passenger_count BETWEEN 1 AND 6
    AND rate_code IS NOT NULL
    AND pickup_location_id IS NOT NULL
    AND dropoff_location_id IS NOT NULL
    AND payment_type IN ('1', '2', '3', '4')
    AND trip_distance BETWEEN 0.1 AND 100
    AND fare_amount BETWEEN 2.5 AND 500
    AND total_amount > 0
)
SELECT
  *,
  -- Variables derivadas (ingeniería de características)
  DATE(pickup_datetime)                          AS pickup_date,
  EXTRACT(MONTH FROM pickup_datetime)            AS pickup_month,
  EXTRACT(DAYOFWEEK FROM pickup_datetime)        AS pickup_dow,   -- 1=Domingo ... 7=Sábado
  EXTRACT(HOUR FROM pickup_datetime)             AS pickup_hour,
  IF(EXTRACT(DAYOFWEEK FROM pickup_datetime) IN (1, 7), 1, 0) AS is_weekend,
  IF(EXTRACT(DAYOFWEEK FROM pickup_datetime) BETWEEN 2 AND 6
     AND (EXTRACT(HOUR FROM pickup_datetime) BETWEEN 7 AND 9
       OR EXTRACT(HOUR FROM pickup_datetime) BETWEEN 16 AND 19), 1, 0) AS is_rush_hour,
  SAFE_DIVIDE(trip_distance, trip_duration_min / 60.0) AS avg_speed_mph,
  SAFE_DIVIDE(fare_amount, trip_distance)              AS fare_per_mile,
  SAFE_DIVIDE(tip_amount, fare_amount)                 AS tip_pct
FROM base
WHERE trip_duration_min BETWEEN 1 AND 180
  AND SAFE_DIVIDE(trip_distance, trip_duration_min / 60.0) <= 80;

-- ---------- (2) TABLA LIMPIA OPTIMIZADA ----------
-- Partición por fecha de recogida  -> las consultas con filtro de fecha
--                                      solo leen las particiones necesarias.
-- Cluster por ubicaciones          -> filtros por zona leen menos bloques.
-- (El orden del cluster importa: primero la columna que más se filtra.)
CREATE OR REPLACE TABLE `ID_Proyecto_GCP.nyc_taxi_2022.taxi_clean_part`
PARTITION BY DATE(pickup_datetime)
CLUSTER BY pickup_location_id, dropoff_location_id
AS
SELECT * FROM `ID_Proyecto_GCP.nyc_taxi_2022.taxi_clean_sin_opt`;

-- ---------- (3) RESUMEN DE CALIDAD ----------
CREATE OR REPLACE TABLE `ID_Proyecto_GCP.nyc_taxi_2022.calidad_resumen` AS
SELECT
  (SELECT COUNT(*) FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022`) AS registros_originales,
  (SELECT COUNT(*) FROM `ID_Proyecto_GCP.nyc_taxi_2022.taxi_clean_part`)                      AS registros_limpios,
  (SELECT COUNT(*) FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022`)
    - (SELECT COUNT(*) FROM `ID_Proyecto_GCP.nyc_taxi_2022.taxi_clean_part`)                  AS registros_descartados;

SELECT *, ROUND(100 * registros_descartados / registros_originales, 2) AS pct_descartado
FROM `ID_Proyecto_GCP.nyc_taxi_2022.calidad_resumen`;

-- ---------- VERIFICACIÓN (evidencia de partición y clustering) ----------
-- Debe mostrar ~334 particiones (una por día de ene-nov).
SELECT table_name, partition_id, total_rows
FROM `ID_Proyecto_GCP.nyc_taxi_2022.INFORMATION_SCHEMA.PARTITIONS`
WHERE table_name = 'taxi_clean_part'
ORDER BY partition_id
LIMIT 10;

-- Ambas tablas deben tener el MISMO conteo.
SELECT 'sin_opt' AS tabla, COUNT(*) AS filas FROM `ID_Proyecto_GCP.nyc_taxi_2022.taxi_clean_sin_opt`
UNION ALL
SELECT 'part',             COUNT(*)          FROM `ID_Proyecto_GCP.nyc_taxi_2022.taxi_clean_part`;
