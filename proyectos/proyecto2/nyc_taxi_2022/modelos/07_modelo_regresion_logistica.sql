-- =====================================================================
-- 07_modelo_regresion_logistica.sql
-- MODELO 2: REGRESIÓN LOGÍSTICA -> clasificar si un viaje recibe propina
--           ALTA (tip_amount >= 20 % de fare_amount). Clase 1 = propina alta.
-- CUMPLE:   Alcance "2 modelos", "ROC-AUC/matriz de confusión",
--           "data leakage". Rúbrica 1.4, 1.5, 1.6, 2.4
-- Solo viajes pagados con TARJETA (payment_type='1'): en efectivo la
-- propina no se registra y el label sería falso.
--
--   m2_log_random   : split aleatorio 80/20, sin regularización, 20 iter.
--   m2_log_temporal : split CUSTOM (train ene-sep / eval oct),
--                     AUTO_CLASS_WEIGHTS=TRUE (clases desbalanceadas),
--                     L2_REG=0.1, 30 iteraciones.
-- =====================================================================

-- ---------- Variante A: split aleatorio ----------
CREATE OR REPLACE MODEL `ID_Proyecto_GCP.nyc_taxi_2022.m2_log_random`
OPTIONS (
  model_type = 'LOGISTIC_REG',
  input_label_cols = ['tip_alta'],
  data_split_method = 'RANDOM',
  data_split_eval_fraction = 0.2,
  max_iterations = 20
) AS
SELECT
  tip_alta,
  fare_amount, fare_per_mile, trip_distance, trip_duration_min, pickup_hour, pickup_dow,
  passenger_count, pickup_location_id, dropoff_location_id, rate_code, is_weekend, is_rush_hour
FROM `ID_Proyecto_GCP.nyc_taxi_2022.ml_features`
WHERE split_set IN ('TRAIN', 'EVAL')
  AND payment_type = '1' AND tip_alta IS NOT NULL;

-- ---------- Variante B: split personalizado + pesos de clase + regularización ----------
CREATE OR REPLACE MODEL `ID_Proyecto_GCP.nyc_taxi_2022.m2_log_temporal`
OPTIONS (
  model_type = 'LOGISTIC_REG',
  input_label_cols = ['tip_alta'],
  data_split_method = 'CUSTOM',
  data_split_col = 'is_eval',
  auto_class_weights = TRUE,
  l2_reg = 0.1,
  max_iterations = 30
) AS
SELECT
  tip_alta,
  fare_amount, fare_per_mile, trip_distance, trip_duration_min, pickup_hour, pickup_dow,
  passenger_count, pickup_location_id, dropoff_location_id, rate_code, is_weekend, is_rush_hour,
  is_eval
FROM `ID_Proyecto_GCP.nyc_taxi_2022.ml_features`
WHERE split_set IN ('TRAIN', 'EVAL')
  AND payment_type = '1' AND tip_alta IS NOT NULL;

-- ---------- Evaluación interna (umbral 0.5) ----------
SELECT 'm2_log_random' AS modelo, precision, recall, accuracy, f1_score, log_loss, roc_auc
FROM ML.EVALUATE(MODEL `ID_Proyecto_GCP.nyc_taxi_2022.m2_log_random`)
UNION ALL
SELECT 'm2_log_temporal', precision, recall, accuracy, f1_score, log_loss, roc_auc
FROM ML.EVALUATE(MODEL `ID_Proyecto_GCP.nyc_taxi_2022.m2_log_temporal`);

-- ---------- Iteraciones ----------
SELECT iteration, loss, eval_loss, learning_rate, duration_ms
FROM ML.TRAINING_INFO(MODEL `ID_Proyecto_GCP.nyc_taxi_2022.m2_log_temporal`)
ORDER BY iteration;

-- ---------- Matriz de confusión interna ----------
SELECT * FROM ML.CONFUSION_MATRIX(MODEL `ID_Proyecto_GCP.nyc_taxi_2022.m2_log_temporal`);
