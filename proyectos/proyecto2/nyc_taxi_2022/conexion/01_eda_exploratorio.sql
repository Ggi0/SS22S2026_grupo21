-- =====================================================================
-- 01_eda_exploratorio.sql
-- OBJETIVO: Análisis exploratorio SOBRE LA TABLA PÚBLICA (datos crudos):
--           métricas descriptivas, distribuciones categóricas, patrones
--           temporales y calidad de datos. Justifica las reglas de
--           limpieza de 02_tablas_derivadas.sql.
-- CUMPLE:   Alcance "Consultas SQL avanzadas" | Rúbrica 1.2, 2.1
-- NOTA:     Cada consulta escanea la tabla pública completa; ejecutar
--           una sola vez y guardar resultados/capturas.
-- =====================================================================

-- ---------- A. PATRONES TEMPORALES ----------

-- A1. Viajes por mes
SELECT EXTRACT(MONTH FROM pickup_datetime) AS mes, COUNT(*) AS viajes
FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022`
GROUP BY mes ORDER BY mes;

-- A2. Viajes por día de la semana (con promedio de tarifa)
SELECT
  FORMAT_DATE('%A', DATE(pickup_datetime)) AS dia,
  COUNT(*) AS viajes,
  ROUND(AVG(fare_amount), 2) AS tarifa_promedio
FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022`
GROUP BY dia ORDER BY viajes DESC;

-- A3. Horas más concurridas
SELECT EXTRACT(HOUR FROM pickup_datetime) AS hora, COUNT(*) AS viajes
FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022`
GROUP BY hora ORDER BY hora;

-- A4. Consistencia: mes por pickup_datetime vs. data_file_month
SELECT data_file_month, COUNT(*) AS viajes
FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022`
GROUP BY data_file_month ORDER BY data_file_month;

-- ---------- B. MÉTRICAS DESCRIPTIVAS ----------

-- B1. Distancia: promedio, min, max y percentiles (los extremos distorsionan el promedio)
SELECT
  AVG(trip_distance) AS promedio,
  MIN(trip_distance) AS minimo,
  MAX(trip_distance) AS maximo,
  APPROX_QUANTILES(trip_distance, 100)[OFFSET(50)] AS mediana,
  APPROX_QUANTILES(trip_distance, 100)[OFFSET(95)] AS p95,
  APPROX_QUANTILES(trip_distance, 100)[OFFSET(99)] AS p99
FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022`;

-- B2. Monto total: promedio, min, max y percentiles
SELECT
  AVG(total_amount) AS promedio,
  MIN(total_amount) AS minimo,
  MAX(total_amount) AS maximo,
  APPROX_QUANTILES(total_amount, 100)[OFFSET(50)] AS mediana,
  APPROX_QUANTILES(total_amount, 100)[OFFSET(99)] AS p99
FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022`;

-- B3. Duración de viajes en minutos (solo viajes con dropoff > pickup)
SELECT
  MIN(TIMESTAMP_DIFF(dropoff_datetime, pickup_datetime, MINUTE)) AS min_min,
  AVG(TIMESTAMP_DIFF(dropoff_datetime, pickup_datetime, MINUTE)) AS prom_min,
  APPROX_QUANTILES(TIMESTAMP_DIFF(dropoff_datetime, pickup_datetime, MINUTE), 100)[OFFSET(50)] AS mediana_min,
  MAX(TIMESTAMP_DIFF(dropoff_datetime, pickup_datetime, MINUTE)) AS max_min
FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022`
WHERE dropoff_datetime > pickup_datetime;

-- ---------- C. DISTRIBUCIONES CATEGÓRICAS ----------

-- C1. Cantidad de pasajeros
SELECT passenger_count, COUNT(*) AS viajes
FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022`
GROUP BY passenger_count ORDER BY viajes DESC;

-- C2. Métodos de pago (1=tarjeta, 2=efectivo, 3=sin cargo, 4=disputa, 0=desconocido)
SELECT payment_type, COUNT(*) AS viajes
FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022`
GROUP BY payment_type ORDER BY viajes DESC;

-- C3. Propinas por método de pago (las propinas en efectivo NO se registran)
SELECT
  payment_type,
  COUNT(*) AS viajes,
  ROUND(AVG(tip_amount), 2) AS propina_promedio,
  ROUND(AVG(SAFE_DIVIDE(tip_amount, NULLIF(fare_amount, 0))), 3) AS propina_pct_promedio
FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022`
GROUP BY payment_type ORDER BY viajes DESC;

-- C4. Tipo de tarifa (rate_code)
SELECT rate_code, COUNT(*) AS viajes, ROUND(AVG(fare_amount), 2) AS tarifa_promedio
FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022`
GROUP BY rate_code ORDER BY viajes DESC;

-- ---------- D. GEOGRAFÍA ----------

-- D1. Top 20 rutas (IDs)
SELECT pickup_location_id, dropoff_location_id, COUNT(*) AS viajes
FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022`
GROUP BY pickup_location_id, dropoff_location_id
ORDER BY viajes DESC LIMIT 20;

-- D2. Top 15 zonas de recogida con nombre (JOIN con taxi_zone_geom, sin traer la geometría)
SELECT
  z.zone_name, z.borough,
  COUNT(*) AS viajes,
  ROUND(AVG(t.fare_amount), 2) AS tarifa_promedio
FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022` t
JOIN `bigquery-public-data.new_york_taxi_trips.taxi_zone_geom` z
  ON t.pickup_location_id = z.zone_id
GROUP BY z.zone_name, z.borough
ORDER BY viajes DESC LIMIT 15;

-- ---------- E. CALIDAD DE DATOS (justifica la limpieza) ----------

-- E1. Conteo de registros problemáticos
SELECT
  COUNT(*) AS total,
  COUNTIF(trip_distance = 0)            AS distancia_cero,
  COUNTIF(trip_distance > 100)          AS distancia_mayor_100,
  COUNTIF(total_amount <= 0)            AS pago_cero_o_negativo,
  COUNTIF(fare_amount > 500)            AS tarifa_mayor_500,
  COUNTIF(passenger_count = 0)          AS pasajeros_cero,
  COUNTIF(passenger_count IS NULL)      AS pasajeros_nulos,
  COUNTIF(dropoff_datetime <= pickup_datetime) AS dropoff_antes_o_igual,
  COUNTIF(TIMESTAMP_DIFF(dropoff_datetime, pickup_datetime, MINUTE) > 180) AS duracion_mayor_3h
FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022`;

-- E2. Registros extremos por monto (ejemplos de outliers)
SELECT * FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022`
ORDER BY total_amount DESC LIMIT 20;

-- E3. Registros extremos por distancia
SELECT * FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022`
ORDER BY trip_distance DESC LIMIT 20;
