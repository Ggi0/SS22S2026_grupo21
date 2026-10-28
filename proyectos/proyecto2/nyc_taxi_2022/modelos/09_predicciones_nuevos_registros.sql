-- =====================================================================
-- 09_predicciones_nuevos_registros.sql
-- OBJETIVO: Ejecutar predicciones sobre registros NUEVOS (noviembre =
--           TEST, que ningún modelo vio) y sobre viajes escritos a mano;
--           generar las tablas del "Rolling Forecast" para el dashboard.
-- CUMPLE:   Alcance "Ejecutar predicciones sobre nuevos registros" y
--           "Representar resultados de los modelos en el dashboard"
--           Rúbrica 2.2
-- =====================================================================

-- ---------- 1. Predicción de tarifa sobre noviembre (2 modelos) ----------
CREATE OR REPLACE TABLE `ID_Proyecto_GCP.nyc_taxi_2022.pred_fare_test` AS
SELECT 'm1_lin_random' AS modelo, pickup_datetime, pickup_date,
       fare_amount AS fare_real, predicted_fare_amount AS fare_predicho,
       predicted_fare_amount - fare_amount AS error
FROM ML.PREDICT(MODEL `ID_Proyecto_GCP.nyc_taxi_2022.m1_lin_random`,
  (SELECT * FROM `ID_Proyecto_GCP.nyc_taxi_2022.ml_features` WHERE split_set = 'TEST'))
UNION ALL
SELECT 'm1_lin_temporal', pickup_datetime, pickup_date,
       fare_amount, predicted_fare_amount, predicted_fare_amount - fare_amount
FROM ML.PREDICT(MODEL `ID_Proyecto_GCP.nyc_taxi_2022.m1_lin_temporal`,
  (SELECT * FROM `ID_Proyecto_GCP.nyc_taxi_2022.ml_features` WHERE split_set = 'TEST'));

-- ---------- 2. Predicción de propina alta sobre noviembre (2 modelos) ----------
CREATE OR REPLACE TABLE `ID_Proyecto_GCP.nyc_taxi_2022.pred_tip_test` AS
SELECT 'm2_log_random' AS modelo, pickup_datetime, pickup_date,
       tip_alta AS tip_real, predicted_tip_alta AS tip_predicho,
       (SELECT p.prob FROM UNNEST(predicted_tip_alta_probs) p WHERE p.label = 1) AS prob_propina_alta
FROM ML.PREDICT(MODEL `ID_Proyecto_GCP.nyc_taxi_2022.m2_log_random`,
  (SELECT * FROM `ID_Proyecto_GCP.nyc_taxi_2022.ml_features`
   WHERE split_set = 'TEST' AND payment_type = '1' AND tip_alta IS NOT NULL))
UNION ALL
SELECT 'm2_log_temporal', pickup_datetime, pickup_date,
       tip_alta, predicted_tip_alta,
       (SELECT p.prob FROM UNNEST(predicted_tip_alta_probs) p WHERE p.label = 1)
FROM ML.PREDICT(MODEL `ID_Proyecto_GCP.nyc_taxi_2022.m2_log_temporal`,
  (SELECT * FROM `ID_Proyecto_GCP.nyc_taxi_2022.ml_features`
   WHERE split_set = 'TEST' AND payment_type = '1' AND tip_alta IS NOT NULL));

-- ---------- 3. ROLLING FORECAST diario (real vs predicho, día a día de noviembre) ----------
CREATE OR REPLACE TABLE `ID_Proyecto_GCP.nyc_taxi_2022.dash_rolling_fare` AS
SELECT modelo, pickup_date AS fecha,
       COUNT(*) AS viajes,
       ROUND(AVG(fare_real), 2)     AS fare_real_prom,
       ROUND(AVG(fare_predicho), 2) AS fare_predicho_prom,
       ROUND(SQRT(AVG(POW(error, 2))), 2) AS rmse_dia
FROM `ID_Proyecto_GCP.nyc_taxi_2022.pred_fare_test`
GROUP BY modelo, fecha ORDER BY fecha, modelo;

CREATE OR REPLACE TABLE `ID_Proyecto_GCP.nyc_taxi_2022.dash_rolling_tip` AS
SELECT modelo, pickup_date AS fecha,
       COUNT(*) AS viajes,
       ROUND(AVG(tip_real), 3)         AS tasa_real_propina_alta,
       ROUND(AVG(tip_predicho), 3)     AS tasa_predicha_propina_alta,
       ROUND(AVG(prob_propina_alta), 3) AS prob_promedio
FROM `ID_Proyecto_GCP.nyc_taxi_2022.pred_tip_test`
GROUP BY modelo, fecha ORDER BY fecha, modelo;

-- ---------- 4. Predicciones sobre viajes NUEVOS escritos a mano ----------
-- Los tipos deben coincidir con el entrenamiento (STRING para hora/día/zonas/rate_code).
-- Viernes (dow='6') 6 pm hora pico; JFK (132) -> Midtown; etc.
SELECT * FROM ML.PREDICT(MODEL `ID_Proyecto_GCP.nyc_taxi_2022.m1_lin_temporal`, (
  SELECT 5.2 AS trip_distance, 22.0 AS trip_duration_min, '18' AS pickup_hour, '6' AS pickup_dow,
         1 AS passenger_count, '237' AS pickup_location_id, '161' AS dropoff_location_id,
         '1.0' AS rate_code, 0 AS is_weekend, 1 AS is_rush_hour
  UNION ALL
  SELECT 17.5, 45.0, '14', '1', 2, '132', '230', '2.0', 1, 0
  UNION ALL
  SELECT 1.1, 8.0, '9', '3', 1, '236', '237', '1.0', 0, 1
));

SELECT
  predicted_tip_alta,
  (SELECT p.prob FROM UNNEST(predicted_tip_alta_probs) p WHERE p.label = 1) AS prob_propina_alta,
  fare_amount, trip_distance
FROM ML.PREDICT(MODEL `ID_Proyecto_GCP.nyc_taxi_2022.m2_log_temporal`, (
  SELECT 22.0 AS fare_amount, 4.0 AS fare_per_mile, 5.5 AS trip_distance, 24.0 AS trip_duration_min,
         '19' AS pickup_hour, '6' AS pickup_dow, 1 AS passenger_count,
         '237' AS pickup_location_id, '161' AS dropoff_location_id, '1.0' AS rate_code,
         0 AS is_weekend, 1 AS is_rush_hour
  UNION ALL
  SELECT 70.0, 4.1, 17.0, 50.0, '15', '1', 2, '132', '230', '2.0', 1, 0
));
