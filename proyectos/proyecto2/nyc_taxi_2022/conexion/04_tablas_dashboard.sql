-- =====================================================================
-- 04_tablas_dashboard.sql
-- OBJETIVO: Crear tablas agregadas y pequeñas para conectar a Looker
--           Studio (consultas rápidas y baratas al refrescar el tablero).
--           Se calculan sobre taxi_clean_part (optimizada).
-- CUMPLE:   Alcance "Exportar o enlazar resultados ... 3 visualizaciones"
--           Rúbrica 2.1 y 2.2
-- Reemplazar TU_PROYECTO antes de ejecutar.
-- Verifica los nombres de columnas de taxi_zone_geom (zone_id, zone_name,
-- borough) con INFORMATION_SCHEMA.COLUMNS si el JOIN falla.
-- =====================================================================

-- V1. Serie mensual (gráfico de líneas/barras)
CREATE OR REPLACE TABLE `project-d8c3b660-d94c-44a1-b5b.nyc_taxi_2022.dash_viajes_mes` AS
SELECT
  pickup_month AS mes,
  COUNT(*) AS viajes,
  ROUND(AVG(fare_amount), 2)        AS tarifa_promedio,
  ROUND(AVG(trip_distance), 2)      AS distancia_promedio,
  ROUND(AVG(trip_duration_min), 1)  AS duracion_promedio_min,
  ROUND(SUM(total_amount), 0)       AS ingresos_totales
FROM `project-d8c3b660-d94c-44a1-b5b.nyc_taxi_2022.taxi_clean_part`
GROUP BY mes ORDER BY mes;

-- V2. Mapa de calor día de la semana x hora
CREATE OR REPLACE TABLE `project-d8c3b660-d94c-44a1-b5b.nyc_taxi_2022.dash_heatmap_hora_dia` AS
SELECT
  pickup_dow AS dia_num,
  CASE pickup_dow WHEN 1 THEN 'Dom' WHEN 2 THEN 'Lun' WHEN 3 THEN 'Mar' WHEN 4 THEN 'Mie'
                  WHEN 5 THEN 'Jue' WHEN 6 THEN 'Vie' WHEN 7 THEN 'Sab' END AS dia,
  pickup_hour AS hora,
  COUNT(*) AS viajes,
  ROUND(AVG(fare_amount), 2) AS tarifa_promedio
FROM `project-d8c3b660-d94c-44a1-b5b.nyc_taxi_2022.taxi_clean_part`
GROUP BY dia_num, dia, hora;

-- V3. Top zonas de recogida con nombre (gráfico de barras)
CREATE OR REPLACE TABLE `project-d8c3b660-d94c-44a1-b5b.nyc_taxi_2022.dash_top_zonas` AS
SELECT
  z.zone_name AS zona, z.borough AS distrito,
  COUNT(*) AS viajes,
  ROUND(AVG(t.fare_amount), 2) AS tarifa_promedio,
  ROUND(AVG(IF(t.payment_type = '1', t.tip_pct, NULL)), 3) AS propina_pct_tarjeta
FROM `project-d8c3b660-d94c-44a1-b5b.nyc_taxi_2022.taxi_clean_part` t
JOIN `bigquery-public-data.new_york_taxi_trips.taxi_zone_geom` z
  ON t.pickup_location_id = z.zone_id
GROUP BY zona, distrito
ORDER BY viajes DESC LIMIT 30;

-- V4. Top rutas con nombres
CREATE OR REPLACE TABLE `project-d8c3b660-d94c-44a1-b5b.nyc_taxi_2022.dash_top_rutas` AS
SELECT
  zp.zone_name AS origen, zd.zone_name AS destino,
  COUNT(*) AS viajes,
  ROUND(AVG(t.fare_amount), 2) AS tarifa_promedio,
  ROUND(AVG(t.trip_distance), 2) AS distancia_promedio
FROM `project-d8c3b660-d94c-44a1-b5b.nyc_taxi_2022.taxi_clean_part` t
JOIN `bigquery-public-data.new_york_taxi_trips.taxi_zone_geom` zp ON t.pickup_location_id  = zp.zone_id
JOIN `bigquery-public-data.new_york_taxi_trips.taxi_zone_geom` zd ON t.dropoff_location_id = zd.zone_id
GROUP BY origen, destino
ORDER BY viajes DESC LIMIT 30;

-- V5. Propina por hora (solo tarjeta: la propina en efectivo no se registra)
CREATE OR REPLACE TABLE `project-d8c3b660-d94c-44a1-b5b.nyc_taxi_2022.dash_propina_hora` AS
SELECT
  pickup_hour AS hora,
  COUNT(*) AS viajes_tarjeta,
  ROUND(AVG(tip_pct), 3) AS propina_pct_promedio,
  ROUND(AVG(IF(tip_pct >= 0.2, 1, 0)), 3) AS proporcion_propina_alta
FROM `project-d8c3b660-d94c-44a1-b5b.nyc_taxi_2022.taxi_clean_part`
WHERE payment_type = '1' AND fare_amount > 0
GROUP BY hora ORDER BY hora;

-- V6. Métodos de pago
CREATE OR REPLACE TABLE `project-d8c3b660-d94c-44a1-b5b.nyc_taxi_2022.dash_metodo_pago` AS
SELECT
  CASE payment_type WHEN '1' THEN 'Tarjeta' WHEN '2' THEN 'Efectivo'
                    WHEN '3' THEN 'Sin cargo' WHEN '4' THEN 'Disputa' END AS metodo,
  COUNT(*) AS viajes,
  ROUND(AVG(total_amount), 2) AS total_promedio
FROM `project-d8c3b660-d94c-44a1-b5b.nyc_taxi_2022.taxi_clean_part`
GROUP BY metodo;
