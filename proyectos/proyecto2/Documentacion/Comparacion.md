
# comparaciones:

## Tabla de Consultas y Tablas

| Consulta | Tabla                     |
|----------|---------------------------|
| Q1_A     | Pública original          |
| Q1_B     | Limpia sin optimizar      |
| Q1_C     | Particionada + Clustering |
| Q2_A     | Pública original          |
| Q2_B     | Limpia sin optimizar      |
| Q2_C     | Particionada + Clustering |
| Q3_A     | Pública original          |
| Q3_B     | Limpia sin optimizar      |
| Q3_C     | Particionada + Clustering |


##  una zona, un mes - Filtro por fecha (partición) + filtro por zona (cluster)

### Pública original
```sql
-- BENCH Q1_A
SELECT COUNT(*) AS viajes, ROUND(AVG(fare_amount), 2) AS tarifa_prom, ROUND(AVG(tip_amount), 2) AS propina_prom
FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022`
WHERE DATE(pickup_datetime) BETWEEN '2022-06-01' AND '2022-06-30'
  AND pickup_location_id = '132';
```

![alt text](<../Images/comparacion/Captura de Pantalla 2026-10-26 a la(s) 23.48.39.png>)

#### bytes procesados, bytes facturados, tiempo de slot
![alt text](<../Images/comparacion/Captura de Pantalla 2026-10-26 a la(s) 23.52.35.png>)

| Métrica                | Valor     |
|------------------------|-----------|
| Bytes procesados       | 1.51 GB   |
| Bytes facturados       | 1.51 GB   |
| Milisegundos de ranura | 6076      |


### Limpia sin optimizar
```sql
-- BENCH Q1_B
SELECT COUNT(*) AS viajes, ROUND(AVG(fare_amount), 2) AS tarifa_prom, ROUND(AVG(tip_amount), 2) AS propina_prom
FROM `project-d8c3b660-d94c-44a1-b5b.nyc_taxi_2022.taxi_clean_sin_opt`
WHERE DATE(pickup_datetime) BETWEEN '2022-06-01' AND '2022-06-30'
  AND pickup_location_id = '132';
```
![alt text](<../Images/comparacion/Captura de Pantalla 2026-10-26 a la(s) 23.55.23.png>)

#### bytes procesados, bytes facturados, tiempo de slot
![text](<../Images/comparacion/Captura de Pantalla 2026-10-26 a la(s) 23.55.59.png>)

| Métrica                | Valor     |
|------------------------|-----------|
| Bytes procesados       | 920.45 MB |
| Bytes facturados       | 921 MB    |
| Milisegundos de ranura | 10137     |


### Particionada + Clustering
```sql
-- BENCH Q1_C
SELECT COUNT(*) AS viajes, ROUND(AVG(fare_amount), 2) AS tarifa_prom, ROUND(AVG(tip_amount), 2) AS propina_prom
FROM `project-d8c3b660-d94c-44a1-b5b.nyc_taxi_2022.taxi_clean_part`
WHERE DATE(pickup_datetime) BETWEEN '2022-06-01' AND '2022-06-30'
  AND pickup_location_id = '132';
```

![alt text](<../Images/comparacion/Captura de Pantalla 2026-10-26 a la(s) 23.59.09.png>)

#### bytes procesados, bytes facturados, tiempo de slot
![alt text](<../Images/comparacion/Captura de Pantalla 2026-10-26 a la(s) 23.59.59.png>)

| Métrica                | Valor     |
|------------------------|-----------|
| Bytes procesados       | 75.22 MB  |
| Bytes facturados       | 76 MB     |
| Milisegundos de ranura | 368       |














##  una semana, ruta específica - Filtro por rango corto de fechas + ruta (pickup y dropoff = ambos cluster)

### Pública original
```sql
-- BENCH Q2_A
SELECT EXTRACT(HOUR FROM pickup_datetime) AS hora, COUNT(*) AS viajes, ROUND(AVG(total_amount), 2) AS total_prom
FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022`
WHERE DATE(pickup_datetime) BETWEEN '2022-03-07' AND '2022-03-13'
  AND pickup_location_id = '237' AND dropoff_location_id = '236'
GROUP BY hora ORDER BY hora;
```
![alt text](<../Images/comparacion/Captura de Pantalla 2026-10-27 a la(s) 00.03.27.png>)

#### bytes procesados, bytes facturados, tiempo de slot

| Métrica                | Valor     |
|------------------------|-----------|
| Bytes procesados       | 1.13 GB   |
| Bytes facturados       | 1.14 GB   |
| Milisegundos de ranura | 11940     |


### Limpia sin optimizar
```sql
-- BENCH Q2_B
SELECT EXTRACT(HOUR FROM pickup_datetime) AS hora, COUNT(*) AS viajes, ROUND(AVG(total_amount), 2) AS total_prom
FROM `project-d8c3b660-d94c-44a1-b5b.nyc_taxi_2022.taxi_clean_sin_opt`
WHERE DATE(pickup_datetime) BETWEEN '2022-03-07' AND '2022-03-13'
  AND pickup_location_id = '237' AND dropoff_location_id = '236'
GROUP BY hora ORDER BY hora;
```

![alt text](<../Images/comparacion/Captura de Pantalla 2026-10-27 a la(s) 00.05.22.png>)

#### bytes procesados, bytes facturados, tiempo de slot

| Métrica                | Valor     |
|------------------------|-----------|
| Bytes procesados       | 817.75 MB |
| Bytes facturados       | 818 MB    |
| Milisegundos de ranura | 9862      |


### Particionada + Clustering
```sql
SELECT EXTRACT(HOUR FROM pickup_datetime) AS hora, COUNT(*) AS viajes, ROUND(AVG(total_amount), 2) AS total_prom
FROM `project-d8c3b660-d94c-44a1-b5b.nyc_taxi_2022.taxi_clean_part`
WHERE DATE(pickup_datetime) BETWEEN '2022-03-07' AND '2022-03-13'
  AND pickup_location_id = '237' AND dropoff_location_id = '236'
GROUP BY hora ORDER BY hora;
```

![alt text](<../Images/comparacion/Captura de Pantalla 2026-10-27 a la(s) 00.06.37.png>)

#### bytes procesados, bytes facturados, tiempo de slot

| Métrica                | Valor     |
|------------------------|-----------|
| Bytes procesados       | 16.56 MB  |
| Bytes facturados       | 15 MB     |
| Milisegundos de ranura | 141       |











## solo fecha (un día), sin filtro de zona - Aquí solo ayuda la PARTICIÓN; sirve para mostrar el aporte de cada técnica.

### Pública original
```sql
-- BENCH Q3_A
SELECT pickup_location_id, COUNT(*) AS viajes
FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022`
WHERE DATE(pickup_datetime) = '2022-09-15'
GROUP BY pickup_location_id ORDER BY viajes DESC LIMIT 10;
```

![alt text](<../Images/comparacion/Captura de Pantalla 2026-10-27 a la(s) 00.09.54.png>)

#### bytes procesados, bytes facturados, tiempo de slot


| Métrica                | Valor     |
|------------------------|-----------|
| Bytes procesados       | 443.61 MB   |
| Bytes facturados       | 444 MB   |
| Milisegundos de ranura | 2828      |


### Limpia sin optimizar
```sql
-- BENCH Q3_B
SELECT pickup_location_id, COUNT(*) AS viajes
FROM `project-d8c3b660-d94c-44a1-b5b.nyc_taxi_2022.taxi_clean_sin_opt`
WHERE DATE(pickup_datetime) = '2022-09-15'
GROUP BY pickup_location_id ORDER BY viajes DESC LIMIT 10;
```

![alt text](<../Images/comparacion/Captura de Pantalla 2026-10-27 a la(s) 00.11.10.png>)

#### bytes procesados, bytes facturados, tiempo de slot

| Métrica                | Valor     |
|------------------------|-----------|
| Bytes procesados       | 409.68 MB |
| Bytes facturados       | 410 MB    |
| Milisegundos de ranura | 4241     |


### Particionada + Clustering
```sql
-- BENCH Q3_C
SELECT pickup_location_id, COUNT(*) AS viajes
FROM `project-d8c3b660-d94c-44a1-b5b.nyc_taxi_2022.taxi_clean_part`
WHERE DATE(pickup_datetime) = '2022-09-15'
GROUP BY pickup_location_id ORDER BY viajes DESC LIMIT 10;
```

![alt text](<../Images/comparacion/Captura de Pantalla 2026-10-27 a la(s) 00.12.41.png>)

#### bytes procesados, bytes facturados, tiempo de slot

| Métrica                | Valor     |
|------------------------|-----------|
| Bytes procesados       | 1.44 MB  |
| Bytes facturados       | 10 MB     |
| Milisegundos de ranura | 26      |



##  bytes procesados, bytes facturados, slot-ms y tiempo.

![alt text](<../Images/comparacion/Captura de Pantalla 2026-10-27 a la(s) 00.18.15.png>)


![alt text](<../Images/comparacion/Captura de Pantalla 2026-10-27 a la(s) 00.19.47.png>)