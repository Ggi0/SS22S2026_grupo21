-- =====================================================================
-- 00_conexion_y_validacion.sql
-- OBJETIVO: Demostrar conexión al dataset público y validar volumen,
--           estructura y rango temporal de los datos.
-- CUMPLE:   Alcance "Conectarse al dataset público" | Rúbrica 1.1
-- COSTO:    Muy bajo (casi todo son metadatos o COUNT(*)).
-- EVIDENCIA: captura de cada resultado -> evidencias/01_conexion_*.png
-- =====================================================================

-- 1. Tablas disponibles en el dataset público
SELECT table_name
FROM `bigquery-public-data.new_york_taxi_trips.INFORMATION_SCHEMA.TABLES`
ORDER BY table_name;

-- 2. Estructura (columnas y tipos) de la tabla de trabajo
SELECT column_name, data_type
FROM `bigquery-public-data.new_york_taxi_trips.INFORMATION_SCHEMA.COLUMNS`
WHERE table_name = 'tlc_yellow_trips_2022'
ORDER BY ordinal_position;

-- 3. Volumen total de registros
SELECT COUNT(*) AS total_viajes
FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022`;

-- 4. Muestra de registros
SELECT *
FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022`
LIMIT 10;

-- 5. Rango temporal real y registros fuera del año 2022
SELECT
  MIN(pickup_datetime) AS primera_fecha,
  MAX(pickup_datetime) AS ultima_fecha,
  COUNTIF(pickup_datetime < TIMESTAMP('2022-01-01')
       OR pickup_datetime >= TIMESTAMP('2023-01-01')) AS fuera_de_2022,
  COUNTIF(pickup_datetime >= TIMESTAMP('2022-12-01')) AS diciembre_residual
FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022`;

-- 6. Porcentaje de nulos por columna clave
SELECT
  COUNTIF(passenger_count IS NULL)      AS nulos_passenger,
  COUNTIF(rate_code IS NULL)            AS nulos_rate_code,
  COUNTIF(store_and_fwd_flag IS NULL)   AS nulos_store_fwd,
  COUNTIF(airport_fee IS NULL)          AS nulos_airport_fee,
  COUNTIF(pickup_location_id IS NULL)   AS nulos_pickup_loc,
  COUNTIF(dropoff_location_id IS NULL)  AS nulos_dropoff_loc
FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022`;
