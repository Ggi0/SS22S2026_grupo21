-- =====================================================================
-- 08_comparacion_modelos.sql
-- OBJETIVO: Comparar los 4 modelos de forma JUSTA sobre el mismo conjunto
--           TEST (noviembre), que ninguno vio en entrenamiento ni en
--           evaluación interna. Justifica la selección final.
-- CUMPLE:   Rúbrica 1.5 (métricas + hiperparámetros + justificación) y 1.6
-- =====================================================================

-- ---------- REGRESIÓN: RMSE / MAE / R2 sobre TEST ----------
CREATE OR REPLACE TABLE `ID_Proyecto_GCP.nyc_taxi_2022.comparacion_regresion` AS
SELECT 'm1_lin_random' AS modelo, 'RANDOM 80/20, sin L2, 20 iter' AS configuracion,
       SQRT(mean_squared_error) AS rmse, mean_absolute_error AS mae, r2_score
FROM ML.EVALUATE(MODEL `ID_Proyecto_GCP.nyc_taxi_2022.m1_lin_random`,
  (SELECT * FROM `ID_Proyecto_GCP.nyc_taxi_2022.ml_features` WHERE split_set = 'TEST'))
UNION ALL
SELECT 'm1_lin_temporal', 'CUSTOM temporal, L2=0.1, 30 iter',
       SQRT(mean_squared_error), mean_absolute_error, r2_score
FROM ML.EVALUATE(MODEL `ID_Proyecto_GCP.nyc_taxi_2022.m1_lin_temporal`,
  (SELECT * FROM `ID_Proyecto_GCP.nyc_taxi_2022.ml_features` WHERE split_set = 'TEST'))
UNION ALL
-- Línea base ingenua: predecir siempre el promedio del entrenamiento
SELECT 'baseline_promedio', 'predice el fare promedio de TRAIN',
       SQRT(AVG(POW(t.fare_amount - b.prom, 2))), AVG(ABS(t.fare_amount - b.prom)), CAST(NULL AS FLOAT64)
FROM `ID_Proyecto_GCP.nyc_taxi_2022.ml_features` t
CROSS JOIN (SELECT AVG(fare_amount) AS prom
            FROM `ID_Proyecto_GCP.nyc_taxi_2022.ml_features` WHERE split_set = 'TRAIN') b
WHERE t.split_set = 'TEST';

SELECT * FROM `ID_Proyecto_GCP.nyc_taxi_2022.comparacion_regresion` ORDER BY rmse;

-- ---------- CLASIFICACIÓN: precisión, recall, F1, ROC-AUC sobre TEST ----------
CREATE OR REPLACE TABLE `ID_Proyecto_GCP.nyc_taxi_2022.comparacion_clasificacion` AS
SELECT 'm2_log_random' AS modelo, 'RANDOM 80/20, sin pesos, 20 iter' AS configuracion,
       precision, recall, accuracy, f1_score, log_loss, roc_auc
FROM ML.EVALUATE(MODEL `ID_Proyecto_GCP.nyc_taxi_2022.m2_log_random`,
  (SELECT * FROM `ID_Proyecto_GCP.nyc_taxi_2022.ml_features`
   WHERE split_set = 'TEST' AND payment_type = '1' AND tip_alta IS NOT NULL),
  STRUCT(0.5 AS threshold))
UNION ALL
SELECT 'm2_log_temporal', 'CUSTOM temporal, pesos auto, L2=0.1, 30 iter',
       precision, recall, accuracy, f1_score, log_loss, roc_auc
FROM ML.EVALUATE(MODEL `ID_Proyecto_GCP.nyc_taxi_2022.m2_log_temporal`,
  (SELECT * FROM `ID_Proyecto_GCP.nyc_taxi_2022.ml_features`
   WHERE split_set = 'TEST' AND payment_type = '1' AND tip_alta IS NOT NULL),
  STRUCT(0.5 AS threshold));

SELECT * FROM `ID_Proyecto_GCP.nyc_taxi_2022.comparacion_clasificacion` ORDER BY roc_auc DESC;

-- ---------- Matrices de confusión sobre TEST ----------
SELECT 'm2_log_random' AS modelo, * FROM ML.CONFUSION_MATRIX(
  MODEL `ID_Proyecto_GCP.nyc_taxi_2022.m2_log_random`,
  (SELECT * FROM `ID_Proyecto_GCP.nyc_taxi_2022.ml_features`
   WHERE split_set = 'TEST' AND payment_type = '1' AND tip_alta IS NOT NULL),
  STRUCT(0.5 AS threshold));

SELECT 'm2_log_temporal' AS modelo, * FROM ML.CONFUSION_MATRIX(
  MODEL `ID_Proyecto_GCP.nyc_taxi_2022.m2_log_temporal`,
  (SELECT * FROM `ID_Proyecto_GCP.nyc_taxi_2022.ml_features`
   WHERE split_set = 'TEST' AND payment_type = '1' AND tip_alta IS NOT NULL),
  STRUCT(0.5 AS threshold));

-- ---------- Curva ROC (para graficar en Looker Studio) ----------
CREATE OR REPLACE TABLE `ID_Proyecto_GCP.nyc_taxi_2022.dash_roc_curve` AS
SELECT 'm2_log_temporal' AS modelo, threshold, recall, false_positive_rate
FROM ML.ROC_CURVE(
  MODEL `ID_Proyecto_GCP.nyc_taxi_2022.m2_log_temporal`,
  (SELECT * FROM `ID_Proyecto_GCP.nyc_taxi_2022.ml_features`
   WHERE split_set = 'TEST' AND payment_type = '1' AND tip_alta IS NOT NULL))
UNION ALL
SELECT 'm2_log_random', threshold, recall, false_positive_rate
FROM ML.ROC_CURVE(
  MODEL `ID_Proyecto_GCP.nyc_taxi_2022.m2_log_random`,
  (SELECT * FROM `ID_Proyecto_GCP.nyc_taxi_2022.ml_features`
   WHERE split_set = 'TEST' AND payment_type = '1' AND tip_alta IS NOT NULL));
