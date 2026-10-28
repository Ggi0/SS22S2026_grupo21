-- =====================================================================
-- 06_modelo_regresion_lineal.sql
-- MODELO 1: REGRESIÓN LINEAL -> predecir fare_amount (costo base, USD)
-- CUMPLE:   Alcance "2 modelos", "hiperparámetros", "data leakage por
--           data_split_eval_fraction y split personalizado"
--           Rúbrica 1.4, 1.5, 1.6, 2.4
--
-- Se entrenan DOS variantes para comparar estrategia de split e hiperparámetros:
--   m1_lin_random   : split aleatorio 80/20 (DATA_SPLIT_EVAL_FRACTION=0.2),
--                     sin regularización, 20 iteraciones.
--                     -> RIESGO: mezcla meses; la evaluación "ve" el mismo
--                        periodo que el entrenamiento.
--   m1_lin_temporal : split PERSONALIZADO (CUSTOM) con is_eval: entrena
--                     ene-sep y evalúa oct. L2_REG=0.1, 30 iteraciones.
--                     -> Respeta el orden del tiempo (sin fuga del futuro).
-- Ambos usan datos de ene-oct. Noviembre (TEST) queda fuera de los dos.
-- =====================================================================

-- ---------- Variante A: split aleatorio ----------
CREATE OR REPLACE MODEL `ID_Proyecto_GCP.nyc_taxi_2022.m1_lin_random`
OPTIONS (
  model_type = 'LINEAR_REG',
  input_label_cols = ['fare_amount'],
  data_split_method = 'RANDOM',
  data_split_eval_fraction = 0.2,
  max_iterations = 20
) AS
SELECT
  fare_amount,
  trip_distance, trip_duration_min, pickup_hour, pickup_dow, passenger_count,
  pickup_location_id, dropoff_location_id, rate_code, is_weekend, is_rush_hour
FROM `ID_Proyecto_GCP.nyc_taxi_2022.ml_features`
WHERE split_set IN ('TRAIN', 'EVAL');

-- ---------- Variante B: split personalizado temporal + regularización ----------
CREATE OR REPLACE MODEL `ID_Proyecto_GCP.nyc_taxi_2022.m1_lin_temporal`
OPTIONS (
  model_type = 'LINEAR_REG',
  input_label_cols = ['fare_amount'],
  data_split_method = 'CUSTOM',
  data_split_col = 'is_eval',
  l2_reg = 0.1,
  max_iterations = 30
) AS
SELECT
  fare_amount,
  trip_distance, trip_duration_min, pickup_hour, pickup_dow, passenger_count,
  pickup_location_id, dropoff_location_id, rate_code, is_weekend, is_rush_hour,
  is_eval
FROM `ID_Proyecto_GCP.nyc_taxi_2022.ml_features`
WHERE split_set IN ('TRAIN', 'EVAL');

-- ---------- Evaluación interna (sobre el eval de cada modelo) ----------
-- RMSE = raíz del error cuadrático medio (USD). Menor = mejor.
SELECT 'm1_lin_random' AS modelo, SQRT(mean_squared_error) AS rmse, mean_absolute_error AS mae, r2_score
FROM ML.EVALUATE(MODEL `ID_Proyecto_GCP.nyc_taxi_2022.m1_lin_random`)
UNION ALL
SELECT 'm1_lin_temporal', SQRT(mean_squared_error), mean_absolute_error, r2_score
FROM ML.EVALUATE(MODEL `ID_Proyecto_GCP.nyc_taxi_2022.m1_lin_temporal`);

-- ---------- Iteraciones / convergencia ----------
SELECT iteration, loss, eval_loss, learning_rate, duration_ms
FROM ML.TRAINING_INFO(MODEL `ID_Proyecto_GCP.nyc_taxi_2022.m1_lin_temporal`)
ORDER BY iteration;

-- ---------- Peso de cada variable (interpretación) ----------
SELECT processed_input, weight, category_weights
FROM ML.WEIGHTS(MODEL `ID_Proyecto_GCP.nyc_taxi_2022.m1_lin_temporal`)
WHERE category_weights IS NULL OR ARRAY_LENGTH(category_weights) = 0
ORDER BY ABS(weight) DESC;
