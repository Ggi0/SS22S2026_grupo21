-- =====================================================================
-- 05_features_ml.sql
-- OBJETIVO: Construir la tabla única de características (ml_features)
--           para ambos modelos, con las variables de entrada, las
--           variables objetivo y las columnas de SPLIT.
-- CUMPLE:   Alcance "BigQuery ML sobre dataset limpio" y "Manejo de
--           data leakage". Rúbrica 1.6, 2.3, 2.4
--
-- DISEÑO DEL SPLIT TEMPORAL (evita fuga de información del futuro):
--     TRAIN : ene-sep 2022   -> entrena
--     EVAL  : oct 2022       -> evaluación interna (split personalizado)
--     TEST  : nov 2022       -> NUNCA lo ve ningún modelo; se usa para
--                               comparar modelos y para "nuevos registros"
--
-- MUESTREO: 5% determinístico por trip_key (~1.5 M filas) para entrenar
--           rápido y barato. Sube el 5 a 10 o 20 si quieres más datos.
--
-- ============== VARIABLES (justificación para el README) ==============
-- MODELO 1 (regresión lineal) -> OBJETIVO: fare_amount
--   Entradas: trip_distance, trip_duration_min, pickup_hour, pickup_dow,
--             passenger_count, pickup_location_id, dropoff_location_id,
--             rate_code, is_weekend, is_rush_hour
--   EXCLUIDAS por leakage: total_amount, tip_amount, tolls_amount, extra,
--             mta_tax, imp_surcharge, airport_fee (componentes del total
--             o posteriores al cobro) y fare_per_mile (se calcula con el
--             label).
-- MODELO 2 (regresión logística) -> OBJETIVO: tip_alta (propina >= 20 % fare)
--   Entradas: fare_amount, fare_per_mile + las del modelo 1.
--   EXCLUIDAS: tip_amount y tip_pct (definen el label), total_amount
--             (incluye la propina), payment_type (se filtra a tarjeta,
--             porque en efectivo la propina no se registra).
-- pickup_hour y pickup_dow se convierten a STRING para que BigQuery ML
-- los trate como categóricas (one-hot) y no como números ordinales.
-- =====================================================================

CREATE OR REPLACE TABLE `ID_Proyecto_GCP.nyc_taxi_2022.ml_features` AS
SELECT
  trip_key,
  pickup_datetime,
  pickup_date,
  payment_type,

  -- ===== Variables objetivo =====
  fare_amount,                                                  -- Modelo 1 (numérica)
  CASE WHEN payment_type = '1' AND fare_amount > 0
       THEN IF(tip_amount >= 0.2 * fare_amount, 1, 0) END AS tip_alta,  -- Modelo 2 (0/1); NULL si no es tarjeta

  -- ===== Variables de entrada =====
  trip_distance,
  trip_duration_min,
  CAST(pickup_hour AS STRING) AS pickup_hour,
  CAST(pickup_dow  AS STRING) AS pickup_dow,
  passenger_count,
  pickup_location_id,
  dropoff_location_id,
  rate_code,
  is_weekend,
  is_rush_hour,
  fare_per_mile,                                                -- SOLO para el modelo 2

  -- ===== Columnas de split =====
  CASE WHEN pickup_datetime <  TIMESTAMP('2022-10-01') THEN 'TRAIN'
       WHEN pickup_datetime <  TIMESTAMP('2022-11-01') THEN 'EVAL'
       ELSE 'TEST' END AS split_set,
  (pickup_datetime >= TIMESTAMP('2022-10-01')
   AND pickup_datetime < TIMESTAMP('2022-11-01')) AS is_eval   -- BOOL para DATA_SPLIT_COL (TRUE = evaluación)
FROM `ID_Proyecto_GCP.nyc_taxi_2022.taxi_clean_part`
WHERE DATE(pickup_datetime) BETWEEN '2022-01-01' AND '2022-11-30'
  AND MOD(ABS(trip_key), 100) < 5;

-- Revisión 1: tamaño de cada conjunto y balance de clases del Modelo 2
SELECT
  split_set,
  COUNT(*) AS filas,
  ROUND(AVG(fare_amount), 2) AS fare_promedio,
  COUNTIF(payment_type = '1' AND tip_alta IS NOT NULL) AS filas_tarjeta,
  ROUND(AVG(tip_alta), 3) AS proporcion_propina_alta
FROM `ID_Proyecto_GCP.nyc_taxi_2022.ml_features`
GROUP BY split_set ORDER BY split_set;

-- Revisión 2: no debe haber nulos en variables de entrada
SELECT
  COUNTIF(trip_distance IS NULL OR trip_duration_min IS NULL OR pickup_hour IS NULL
          OR pickup_location_id IS NULL OR dropoff_location_id IS NULL OR rate_code IS NULL) AS filas_con_nulos
FROM `ID_Proyecto_GCP.nyc_taxi_2022.ml_features`;
