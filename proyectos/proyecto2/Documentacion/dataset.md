

# Tablas

consulta:
```sql

SELECT table_name
FROM `bigquery-public-data.new_york_taxi_trips.INFORMATION_SCHEMA.TABLES`;


```

resultado:

```json
[{
  "table_name": "tlc_yellow_trips_2023"
}, {
  "table_name": "tlc_yellow_trips_2016"
}, {
  "table_name": "tlc_green_trips_2018"
}, {
  "table_name": "tlc_green_trips_2019"
}, {
  "table_name": "tlc_fhv_trips_2016"
}, {
  "table_name": "tlc_yellow_trips_2014"
}, {
  "table_name": "tlc_green_trips_2022"
}, {
  "table_name": "tlc_yellow_trips_2019"
}, {
  "table_name": "taxi_zone_geom"
}, {
  "table_name": "tlc_yellow_trips_2017"
}, {
  "table_name": "tlc_yellow_trips_2012"
}, {
  "table_name": "tlc_yellow_trips_2015"
}, {
  "table_name": "tlc_yellow_trips_2018"
}, {
  "table_name": "tlc_yellow_trips_2020"
}, {
  "table_name": "tlc_fhv_trips_2015"
}, {
  "table_name": "tlc_green_trips_2014"
}, {
  "table_name": "tlc_yellow_trips_2022"
}, {
  "table_name": "tlc_green_trips_2023"
}, {
  "table_name": "tlc_fhv_trips_2017"
}, {
  "table_name": "tlc_green_trips_2017"
}, {
  "table_name": "tlc_yellow_trips_2011"
}, {
  "table_name": "tlc_green_trips_2021"
}, {
  "table_name": "tlc_green_trips_2020"
}, {
  "table_name": "tlc_green_trips_2016"
}, {
  "table_name": "tlc_yellow_trips_2021"
}, {
  "table_name": "tlc_green_trips_2015"
}, {
  "table_name": "tlc_yellow_trips_2013"
}]

```



# fase exploratoria (EDA)

para descubrir qué datos tiene la tabla antes de pensar en particiones, clustering y BigQuery ML

## 1. Descubrir las columnas
```sql
SELECT
    column_name,
    data_type
FROM `bigquery-public-data.new_york_taxi_trips.INFORMATION_SCHEMA.COLUMNS`
WHERE table_name = 'tlc_yellow_trips_2022'
ORDER BY ordinal_position;
```



```json
[{
  "column_name": "vendor_id",
  "data_type": "STRING"
}, {
  "column_name": "pickup_datetime",
  "data_type": "TIMESTAMP"
}, {
  "column_name": "dropoff_datetime",
  "data_type": "TIMESTAMP"
}, {
  "column_name": "passenger_count",
  "data_type": "INT64"
}, {
  "column_name": "trip_distance",
  "data_type": "NUMERIC"
}, {
  "column_name": "rate_code",
  "data_type": "STRING"
}, {
  "column_name": "store_and_fwd_flag",
  "data_type": "STRING"
}, {
  "column_name": "payment_type",
  "data_type": "STRING"
}, {
  "column_name": "fare_amount",
  "data_type": "NUMERIC"
}, {
  "column_name": "extra",
  "data_type": "NUMERIC"
}, {
  "column_name": "mta_tax",
  "data_type": "NUMERIC"
}, {
  "column_name": "tip_amount",
  "data_type": "NUMERIC"
}, {
  "column_name": "tolls_amount",
  "data_type": "NUMERIC"
}, {
  "column_name": "imp_surcharge",
  "data_type": "NUMERIC"
}, {
  "column_name": "airport_fee",
  "data_type": "NUMERIC"
}, {
  "column_name": "total_amount",
  "data_type": "NUMERIC"
}, {
  "column_name": "pickup_location_id",
  "data_type": "STRING"
}, {
  "column_name": "dropoff_location_id",
  "data_type": "STRING"
}, {
  "column_name": "data_file_year",
  "data_type": "INT64"
}, {
  "column_name": "data_file_month",
  "data_type": "INT64"
}]

```


## 2. Ver registros

```sql
SELECT *
FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022`
LIMIT 6;
```


```json
[{
  "vendor_id": "2",
  "pickup_datetime": "2022-03-21 11:22:21.000000 UTC",
  "dropoff_datetime": "2022-03-21 11:22:33.000000 UTC",
  "passenger_count": "1",
  "trip_distance": "0",
  "rate_code": "1.0",
  "store_and_fwd_flag": "N",
  "payment_type": "1",
  "fare_amount": "0",
  "extra": "0",
  "mta_tax": "0",
  "tip_amount": "0",
  "tolls_amount": "0",
  "imp_surcharge": "0",
  "airport_fee": "0",
  "total_amount": "0",
  "pickup_location_id": "193",
  "dropoff_location_id": "193",
  "data_file_year": "2022",
  "data_file_month": "3"
}, {
  "vendor_id": "2",
  "pickup_datetime": "2022-03-07 19:23:42.000000 UTC",
  "dropoff_datetime": "2022-03-07 19:23:59.000000 UTC",
  "passenger_count": "1",
  "trip_distance": "0",
  "rate_code": "1.0",
  "store_and_fwd_flag": "N",
  "payment_type": "1",
  "fare_amount": "0",
  "extra": "0",
  "mta_tax": "0",
  "tip_amount": "0",
  "tolls_amount": "0",
  "imp_surcharge": "0",
  "airport_fee": "0",
  "total_amount": "0",
  "pickup_location_id": "193",
  "dropoff_location_id": "193",
  "data_file_year": "2022",
  "data_file_month": "3"
}, {
  "vendor_id": "2",
  "pickup_datetime": "2022-03-09 09:07:59.000000 UTC",
  "dropoff_datetime": "2022-03-09 09:08:20.000000 UTC",
  "passenger_count": "1",
  "trip_distance": "0",
  "rate_code": "1.0",
  "store_and_fwd_flag": "N",
  "payment_type": "1",
  "fare_amount": "0",
  "extra": "0",
  "mta_tax": "0",
  "tip_amount": "0",
  "tolls_amount": "0",
  "imp_surcharge": "0",
  "airport_fee": "0",
  "total_amount": "0",
  "pickup_location_id": "193",
  "dropoff_location_id": "193",
  "data_file_year": "2022",
  "data_file_month": "3"
}, {
  "vendor_id": "2",
  "pickup_datetime": "2022-03-11 13:48:15.000000 UTC",
  "dropoff_datetime": "2022-03-11 13:48:50.000000 UTC",
  "passenger_count": "1",
  "trip_distance": "0",
  "rate_code": "1.0",
  "store_and_fwd_flag": "N",
  "payment_type": "1",
  "fare_amount": "0",
  "extra": "0",
  "mta_tax": "0",
  "tip_amount": "0",
  "tolls_amount": "0",
  "imp_surcharge": "0",
  "airport_fee": "0",
  "total_amount": "0",
  "pickup_location_id": "264",
  "dropoff_location_id": "264",
  "data_file_year": "2022",
  "data_file_month": "3"
}, {
  "vendor_id": "2",
  "pickup_datetime": "2022-03-28 09:13:24.000000 UTC",
  "dropoff_datetime": "2022-03-28 09:13:30.000000 UTC",
  "passenger_count": "1",
  "trip_distance": "0",
  "rate_code": "1.0",
  "store_and_fwd_flag": "N",
  "payment_type": "1",
  "fare_amount": "0",
  "extra": "0",
  "mta_tax": "0",
  "tip_amount": "0",
  "tolls_amount": "0",
  "imp_surcharge": "0",
  "airport_fee": "0",
  "total_amount": "0",
  "pickup_location_id": "193",
  "dropoff_location_id": "193",
  "data_file_year": "2022",
  "data_file_month": "3"
}, {
  "vendor_id": "2",
  "pickup_datetime": "2022-03-30 18:38:18.000000 UTC",
  "dropoff_datetime": "2022-03-30 18:39:04.000000 UTC",
  "passenger_count": "1",
  "trip_distance": "0",
  "rate_code": "1.0",
  "store_and_fwd_flag": "N",
  "payment_type": "1",
  "fare_amount": "0",
  "extra": "0",
  "mta_tax": "0",
  "tip_amount": "0",
  "tolls_amount": "0",
  "imp_surcharge": "0",
  "airport_fee": "0",
  "total_amount": "0",
  "pickup_location_id": "193",
  "dropoff_location_id": "193",
  "data_file_year": "2022",
  "data_file_month": "3"
}]
```

## 3. Ver cuántos viajes hay
```sql
SELECT
    COUNT(*) AS total_viajes
FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022`;
```

```json
[{
  "total_viajes": "36256539"
}]
```


# 4. Viajes por mes

```sql
SELECT
    EXTRACT(MONTH FROM pickup_datetime) AS mes,
    COUNT(*) AS viajes
FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022`
GROUP BY mes
ORDER BY mes;
```

resultado:
```json
[{
  "mes": "1",
  "viajes": "2463954"
}, {
  "mes": "2",
  "viajes": "2979419"
}, {
  "mes": "3",
  "viajes": "3627887"
}, {
  "mes": "4",
  "viajes": "3599902"
}, {
  "mes": "5",
  "viajes": "3588291"
}, {
  "mes": "6",
  "viajes": "3557691"
}, {
  "mes": "7",
  "viajes": "3174362"
}, {
  "mes": "8",
  "viajes": "3152694"
}, {
  "mes": "9",
  "viajes": "3183783"
}, {
  "mes": "10",
  "viajes": "3675811"
}, {
  "mes": "11",
  "viajes": "3252628"
}, {
  "mes": "12",
  "viajes": "117"
}]

```

## 5. Viajes por día de la semana

```sql
SELECT
    FORMAT_DATE('%A', DATE(pickup_datetime)) AS dia,
    COUNT(*) AS viajes
FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022`
GROUP BY dia
ORDER BY viajes DESC;
```

resultado
```json
[{
  "dia": "Thursday",
  "viajes": "5541019"
}, {
  "dia": "Wednesday",
  "viajes": "5499048"
}, {
  "dia": "Friday",
  "viajes": "5486263"
}, {
  "dia": "Tuesday",
  "viajes": "5335167"
}, {
  "dia": "Saturday",
  "viajes": "5281407"
}, {
  "dia": "Monday",
  "viajes": "4701114"
}, {
  "dia": "Sunday",
  "viajes": "4412521"
}]
```


## 6. Horas más concurridas

```sql
SELECT
    EXTRACT(HOUR FROM pickup_datetime) AS hora,
    COUNT(*) AS viajes
FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022`
GROUP BY hora
ORDER BY hora;
```


```json
[{
  "hora": "0",
  "viajes": "1001786"
}, {
  "hora": "1",
  "viajes": "661286"
}, {
  "hora": "2",
  "viajes": "440841"
}, {
  "hora": "3",
  "viajes": "291413"
}, {
  "hora": "4",
  "viajes": "200553"
}, {
  "hora": "5",
  "viajes": "231502"
}, {
  "hora": "6",
  "viajes": "567755"
}, {
  "hora": "7",
  "viajes": "1051949"
}, {
  "hora": "8",
  "viajes": "1396320"
}, {
  "hora": "9",
  "viajes": "1561361"
}, {
  "hora": "10",
  "viajes": "1719231"
}, {
  "hora": "11",
  "viajes": "1867672"
}, {
  "hora": "12",
  "viajes": "2017343"
}, {
  "hora": "13",
  "viajes": "2058545"
}, {
  "hora": "14",
  "viajes": "2205956"
}, {
  "hora": "15",
  "viajes": "2263896"
}, {
  "hora": "16",
  "viajes": "2250795"
}, {
  "hora": "17",
  "viajes": "2450718"
}, {
  "hora": "18",
  "viajes": "2575374"
}, {
  "hora": "19",
  "viajes": "2325281"
}, {
  "hora": "20",
  "viajes": "2000668"
}, {
  "hora": "21",
  "viajes": "1918459"
}, {
  "hora": "22",
  "viajes": "1768688"
}, {
  "hora": "23",
  "viajes": "1429147"
}]
```



## 7. Distancia promedio
```sql
SELECT
    AVG(trip_distance) AS distancia_promedio,
    MIN(trip_distance) AS distancia_minima,
    MAX(trip_distance) AS distancia_maxima
FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022`;
```

```json
[{
  "distancia_promedio": "6.077670271",
  "distancia_minima": "0",
  "distancia_maxima": "389678.46"
}]
```

## 8. Monto promedio pagado
```sql
SELECT
    AVG(total_amount) AS promedio,
    MIN(total_amount) AS minimo,
    MAX(total_amount) AS maximo
FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022`;

```

```json
[{
  "promedio": "21.401159324",
  "minimo": "-2567.8",
  "maximo": "401095.62"
}]
```

## 9. Cantidad de pasajeros
```sql

SELECT
    passenger_count,
    COUNT(*) AS viajes
FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022`
GROUP BY passenger_count
ORDER BY viajes DESC;
```


```json
[{
  "passenger_count": "1",
  "viajes": "25889529"
}, {
  "passenger_count": "2",
  "viajes": "5334240"
}, {
  "passenger_count": "3",
  "viajes": "1399213"
}, {
  "passenger_count": null,
  "viajes": "1241840"
}, {
  "passenger_count": "0",
  "viajes": "703119"
}, {
  "passenger_count": "5",
  "viajes": "635766"
}, {
  "passenger_count": "4",
  "viajes": "625785"
}, {
  "passenger_count": "6",
  "viajes": "426667"
}, {
  "passenger_count": "7",
  "viajes": "208"
}, {
  "passenger_count": "8",
  "viajes": "133"
}, {
  "passenger_count": "9",
  "viajes": "39"
}]
```



## 10 calidad de datos:
```sql
SELECT
    COUNT(*) AS total,
    COUNTIF(trip_distance = 0) AS distancia_cero,
    COUNTIF(total_amount = 0) AS pago_cero,
    COUNTIF(passenger_count = 0) AS pasajeros_cero
FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022`;
```

```json
[{
  "total": "36256539",
  "distancia_cero": "511442",
  "pago_cero": "5746",
  "pasajeros_cero": "703119"
}]
```

## 11 Duración de los viajes
```sql
SELECT
    MIN(TIMESTAMP_DIFF(dropoff_datetime, pickup_datetime, MINUTE)) AS min_duracion,
    AVG(TIMESTAMP_DIFF(dropoff_datetime, pickup_datetime, MINUTE)) AS promedio,
    MAX(TIMESTAMP_DIFF(dropoff_datetime, pickup_datetime, MINUTE)) AS max_duracion
FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022`
WHERE dropoff_datetime > pickup_datetime;
```

```json
[{
  "min_duracion": "0",
  "promedio": "56.362017641887235",
  "max_duracion": "10322055"
}]
```

## 12 Distribución mensual
```sql
SELECT
    data_file_month,
    COUNT(*) AS viajes
FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022`
GROUP BY data_file_month
ORDER BY data_file_month;
```

```json
[{
  "data_file_month": "1",
  "viajes": "2463931"
}, {
  "data_file_month": "2",
  "viajes": "2979430"
}, {
  "data_file_month": "3",
  "viajes": "3627881"
}, {
  "data_file_month": "4",
  "viajes": "3599919"
}, {
  "data_file_month": "5",
  "viajes": "3588294"
}, {
  "data_file_month": "6",
  "viajes": "3558123"
}, {
  "data_file_month": "7",
  "viajes": "3174393"
}, {
  "data_file_month": "8",
  "viajes": "3152676"
}, {
  "data_file_month": "9",
  "viajes": "3183766"
}, {
  "data_file_month": "10",
  "viajes": "3675410"
}, {
  "data_file_month": "11",
  "viajes": "3252716"
}]
```


## 13. Horas pico

```sql
SELECT
    EXTRACT(HOUR FROM pickup_datetime) AS hora,
    COUNT(*) AS viajes
FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022`
GROUP BY hora
ORDER BY hora;
```

```json
[{
  "hora": "0",
  "viajes": "1001786"
}, {
  "hora": "1",
  "viajes": "661286"
}, {
  "hora": "2",
  "viajes": "440841"
}, {
  "hora": "3",
  "viajes": "291413"
}, {
  "hora": "4",
  "viajes": "200553"
}, {
  "hora": "5",
  "viajes": "231502"
}, {
  "hora": "6",
  "viajes": "567755"
}, {
  "hora": "7",
  "viajes": "1051949"
}, {
  "hora": "8",
  "viajes": "1396320"
}, {
  "hora": "9",
  "viajes": "1561361"
}, {
  "hora": "10",
  "viajes": "1719231"
}, {
  "hora": "11",
  "viajes": "1867672"
}, {
  "hora": "12",
  "viajes": "2017343"
}, {
  "hora": "13",
  "viajes": "2058545"
}, {
  "hora": "14",
  "viajes": "2205956"
}, {
  "hora": "15",
  "viajes": "2263896"
}, {
  "hora": "16",
  "viajes": "2250795"
}, {
  "hora": "17",
  "viajes": "2450718"
}, {
  "hora": "18",
  "viajes": "2575374"
}, {
  "hora": "19",
  "viajes": "2325281"
}, {
  "hora": "20",
  "viajes": "2000668"
}, {
  "hora": "21",
  "viajes": "1918459"
}, {
  "hora": "22",
  "viajes": "1768688"
}, {
  "hora": "23",
  "viajes": "1429147"
}]
```


## 14. Métodos de pago
```sql
SELECT
    payment_type,
    COUNT(*) AS cantidad
FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022`
GROUP BY payment_type
ORDER BY cantidad DESC;
```


```json

[{
  "payment_type": "1",
  "cantidad": "27531946"
}, {
  "payment_type": "2",
  "cantidad": "7102477"
}, {
  "payment_type": "0",
  "cantidad": "1241840"
}, {
  "payment_type": "4",
  "cantidad": "207844"
}, {
  "payment_type": "3",
  "cantidad": "172427"
}, {
  "payment_type": "5",
  "cantidad": "5"
}]
```


## 15. Top rutas
```sql
SELECT
    pickup_location_id,
    dropoff_location_id,
    COUNT(*) AS viajes
FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022`
GROUP BY
    pickup_location_id,
    dropoff_location_id
ORDER BY viajes DESC
LIMIT 20;

```

resultado:
```json
[{
  "pickup_location_id": "237",
  "dropoff_location_id": "236",
  "viajes": "235454"
}, {
  "pickup_location_id": "236",
  "dropoff_location_id": "237",
  "viajes": "199312"
}, {
  "pickup_location_id": "264",
  "dropoff_location_id": "264",
  "viajes": "184323"
}, {
  "pickup_location_id": "237",
  "dropoff_location_id": "237",
  "viajes": "158271"
}, {
  "pickup_location_id": "236",
  "dropoff_location_id": "236",
  "viajes": "150618"
}, {
  "pickup_location_id": "237",
  "dropoff_location_id": "161",
  "viajes": "103779"
}, {
  "pickup_location_id": "161",
  "dropoff_location_id": "237",
  "viajes": "95351"
}, {
  "pickup_location_id": "132",
  "dropoff_location_id": "132",
  "viajes": "91391"
}, {
  "pickup_location_id": "142",
  "dropoff_location_id": "239",
  "viajes": "88595"
}, {
  "pickup_location_id": "239",
  "dropoff_location_id": "142",
  "viajes": "88067"
}, {
  "pickup_location_id": "161",
  "dropoff_location_id": "236",
  "viajes": "85253"
}, {
  "pickup_location_id": "239",
  "dropoff_location_id": "238",
  "viajes": "85038"
}, {
  "pickup_location_id": "141",
  "dropoff_location_id": "236",
  "viajes": "82833"
}, {
  "pickup_location_id": "236",
  "dropoff_location_id": "161",
  "viajes": "80856"
}, {
  "pickup_location_id": "237",
  "dropoff_location_id": "162",
  "viajes": "80437"
}, {
  "pickup_location_id": "48",
  "dropoff_location_id": "68",
  "viajes": "73936"
}, {
  "pickup_location_id": "263",
  "dropoff_location_id": "141",
  "viajes": "73710"
}, {
  "pickup_location_id": "132",
  "dropoff_location_id": "230",
  "viajes": "73558"
}, {
  "pickup_location_id": "238",
  "dropoff_location_id": "239",
  "viajes": "73318"
}, {
  "pickup_location_id": "142",
  "dropoff_location_id": "238",
  "viajes": "73252"
}]
```


## 16. Ver registros extremos
```sql

SELECT
    *
FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022`
ORDER BY total_amount DESC
LIMIT 20;
```

```json
[{
  "vendor_id": "1",
  "pickup_datetime": "2022-01-07 11:36:43.000000 UTC",
  "dropoff_datetime": "2022-01-07 11:47:12.000000 UTC",
  "passenger_count": "1",
  "trip_distance": "3.3",
  "rate_code": "1.0",
  "store_and_fwd_flag": "N",
  "payment_type": "4",
  "fare_amount": "401092.32",
  "extra": "2.5",
  "mta_tax": "0.5",
  "tip_amount": "0",
  "tolls_amount": "0",
  "imp_surcharge": "0.3",
  "airport_fee": "0",
  "total_amount": "401095.62",
  "pickup_location_id": "107",
  "dropoff_location_id": "140",
  "data_file_year": "2022",
  "data_file_month": "1"
}, {
  "vendor_id": "1",
  "pickup_datetime": "2022-06-11 09:47:33.000000 UTC",
  "dropoff_datetime": "2022-06-11 09:55:39.000000 UTC",
  "passenger_count": "3",
  "trip_distance": "1.2",
  "rate_code": "1.0",
  "store_and_fwd_flag": "N",
  "payment_type": "3",
  "fare_amount": "395844.94",
  "extra": "2.5",
  "mta_tax": "0.5",
  "tip_amount": "0",
  "tolls_amount": "0",
  "imp_surcharge": "0.3",
  "airport_fee": "0",
  "total_amount": "395848.24",
  "pickup_location_id": "163",
  "dropoff_location_id": "140",
  "data_file_year": "2022",
  "data_file_month": "6"
}, {
  "vendor_id": "1",
  "pickup_datetime": "2022-09-24 17:49:31.000000 UTC",
  "dropoff_datetime": "2022-09-24 17:59:06.000000 UTC",
  "passenger_count": "0",
  "trip_distance": "3.5",
  "rate_code": "1.0",
  "store_and_fwd_flag": "N",
  "payment_type": "4",
  "fare_amount": "187444.96",
  "extra": "2.5",
  "mta_tax": "0.5",
  "tip_amount": "0",
  "tolls_amount": "0",
  "imp_surcharge": "0.3",
  "airport_fee": "0",
  "total_amount": "187448.26",
  "pickup_location_id": "233",
  "dropoff_location_id": "232",
  "data_file_year": "2022",
  "data_file_month": "9"
}, {
  "vendor_id": "2",
  "pickup_datetime": "2022-09-27 08:50:11.000000 UTC",
  "dropoff_datetime": "2022-09-27 09:36:36.000000 UTC",
  "passenger_count": "1",
  "trip_distance": "34.42",
  "rate_code": "1.0",
  "store_and_fwd_flag": "N",
  "payment_type": "2",
  "fare_amount": "9999.99",
  "extra": "2.5",
  "mta_tax": "0.5",
  "tip_amount": "0",
  "tolls_amount": "0",
  "imp_surcharge": "0.3",
  "airport_fee": "0",
  "total_amount": "10003.29",
  "pickup_location_id": "138",
  "dropoff_location_id": "138",
  "data_file_year": "2022",
  "data_file_month": "9"
}, {
  "vendor_id": "2",
  "pickup_datetime": "2022-06-25 05:44:48.000000 UTC",
  "dropoff_datetime": "2022-06-25 07:06:53.000000 UTC",
  "passenger_count": "1",
  "trip_distance": "31.83",
  "rate_code": "1.0",
  "store_and_fwd_flag": "N",
  "payment_type": "2",
  "fare_amount": "7037.5",
  "extra": "0.5",
  "mta_tax": "0.5",
  "tip_amount": "0",
  "tolls_amount": "18.3",
  "imp_surcharge": "0.3",
  "airport_fee": "1.25",
  "total_amount": "7060.85",
  "pickup_location_id": "132",
  "dropoff_location_id": "265",
  "data_file_year": "2022",
  "data_file_month": "6"
}, {
  "vendor_id": "2",
  "pickup_datetime": "2022-06-22 10:24:03.000000 UTC",
  "dropoff_datetime": "2022-06-22 11:18:10.000000 UTC",
  "passenger_count": "1",
  "trip_distance": "50.23",
  "rate_code": "1.0",
  "store_and_fwd_flag": "N",
  "payment_type": "2",
  "fare_amount": "7025",
  "extra": "0",
  "mta_tax": "0.5",
  "tip_amount": "0",
  "tolls_amount": "0",
  "imp_surcharge": "0.3",
  "airport_fee": "1.25",
  "total_amount": "7027.05",
  "pickup_location_id": "132",
  "dropoff_location_id": "181",
  "data_file_year": "2022",
  "data_file_month": "6"
}, {
  "vendor_id": "2",
  "pickup_datetime": "2022-06-06 17:45:28.000000 UTC",
  "dropoff_datetime": "2022-06-06 18:37:25.000000 UTC",
  "passenger_count": "1",
  "trip_distance": "26.07",
  "rate_code": "1.0",
  "store_and_fwd_flag": "N",
  "payment_type": "2",
  "fare_amount": "7021",
  "extra": "1",
  "mta_tax": "0.5",
  "tip_amount": "0",
  "tolls_amount": "0",
  "imp_surcharge": "0.3",
  "airport_fee": "1.25",
  "total_amount": "7024.05",
  "pickup_location_id": "132",
  "dropoff_location_id": "181",
  "data_file_year": "2022",
  "data_file_month": "6"
}, {
  "vendor_id": "2",
  "pickup_datetime": "2022-06-10 15:02:21.000000 UTC",
  "dropoff_datetime": "2022-06-10 16:30:42.000000 UTC",
  "passenger_count": "1",
  "trip_distance": "33.07",
  "rate_code": "1.0",
  "store_and_fwd_flag": "N",
  "payment_type": "2",
  "fare_amount": "7006",
  "extra": "0",
  "mta_tax": "0.5",
  "tip_amount": "0",
  "tolls_amount": "6.55",
  "imp_surcharge": "0.3",
  "airport_fee": "1.25",
  "total_amount": "7017.1",
  "pickup_location_id": "138",
  "dropoff_location_id": "231",
  "data_file_year": "2022",
  "data_file_month": "6"
}, {
  "vendor_id": "2",
  "pickup_datetime": "2022-06-09 22:55:44.000000 UTC",
  "dropoff_datetime": "2022-06-10 00:30:48.000000 UTC",
  "passenger_count": "1",
  "trip_distance": "20.63",
  "rate_code": "1.0",
  "store_and_fwd_flag": "N",
  "payment_type": "2",
  "fare_amount": "7000.5",
  "extra": "0.5",
  "mta_tax": "0.5",
  "tip_amount": "0",
  "tolls_amount": "6.55",
  "imp_surcharge": "0.3",
  "airport_fee": "0",
  "total_amount": "7010.85",
  "pickup_location_id": "186",
  "dropoff_location_id": "165",
  "data_file_year": "2022",
  "data_file_month": "6"
}, {
  "vendor_id": "2",
  "pickup_datetime": "2022-06-10 15:02:55.000000 UTC",
  "dropoff_datetime": "2022-06-10 16:21:00.000000 UTC",
  "passenger_count": "1",
  "trip_distance": "22.23",
  "rate_code": "1.0",
  "store_and_fwd_flag": "N",
  "payment_type": "2",
  "fare_amount": "6997",
  "extra": "0",
  "mta_tax": "0.5",
  "tip_amount": "0",
  "tolls_amount": "6.55",
  "imp_surcharge": "0.3",
  "airport_fee": "1.25",
  "total_amount": "7008.1",
  "pickup_location_id": "138",
  "dropoff_location_id": "48",
  "data_file_year": "2022",
  "data_file_month": "6"
}, {
  "vendor_id": "2",
  "pickup_datetime": "2022-06-26 00:29:08.000000 UTC",
  "dropoff_datetime": "2022-06-26 01:05:04.000000 UTC",
  "passenger_count": "4",
  "trip_distance": "12.84",
  "rate_code": "1.0",
  "store_and_fwd_flag": "N",
  "payment_type": "2",
  "fare_amount": "6990",
  "extra": "0.5",
  "mta_tax": "0.5",
  "tip_amount": "0",
  "tolls_amount": "13.1",
  "imp_surcharge": "0.3",
  "airport_fee": "0",
  "total_amount": "7006.9",
  "pickup_location_id": "88",
  "dropoff_location_id": "115",
  "data_file_year": "2022",
  "data_file_month": "6"
}, {
  "vendor_id": "2",
  "pickup_datetime": "2022-06-24 16:07:41.000000 UTC",
  "dropoff_datetime": "2022-06-24 17:18:58.000000 UTC",
  "passenger_count": "1",
  "trip_distance": "24.13",
  "rate_code": "1.0",
  "store_and_fwd_flag": "N",
  "payment_type": "2",
  "fare_amount": "6993",
  "extra": "1",
  "mta_tax": "0.5",
  "tip_amount": "0",
  "tolls_amount": "6.55",
  "imp_surcharge": "0.3",
  "airport_fee": "0",
  "total_amount": "7003.85",
  "pickup_location_id": "237",
  "dropoff_location_id": "257",
  "data_file_year": "2022",
  "data_file_month": "6"
}, {
  "vendor_id": "2",
  "pickup_datetime": "2022-06-11 16:10:38.000000 UTC",
  "dropoff_datetime": "2022-06-11 16:58:42.000000 UTC",
  "passenger_count": "1",
  "trip_distance": "15.45",
  "rate_code": "1.0",
  "store_and_fwd_flag": "N",
  "payment_type": "2",
  "fare_amount": "6999",
  "extra": "0",
  "mta_tax": "0.5",
  "tip_amount": "0",
  "tolls_amount": "0",
  "imp_surcharge": "0.3",
  "airport_fee": "0",
  "total_amount": "7002.3",
  "pickup_location_id": "236",
  "dropoff_location_id": "14",
  "data_file_year": "2022",
  "data_file_month": "6"
}, {
  "vendor_id": "2",
  "pickup_datetime": "2022-06-04 11:45:57.000000 UTC",
  "dropoff_datetime": "2022-06-04 12:50:44.000000 UTC",
  "passenger_count": "4",
  "trip_distance": "14.8",
  "rate_code": "1.0",
  "store_and_fwd_flag": "N",
  "payment_type": "2",
  "fare_amount": "6999",
  "extra": "0",
  "mta_tax": "0.5",
  "tip_amount": "0",
  "tolls_amount": "0",
  "imp_surcharge": "0.3",
  "airport_fee": "0",
  "total_amount": "7002.3",
  "pickup_location_id": "164",
  "dropoff_location_id": "55",
  "data_file_year": "2022",
  "data_file_month": "6"
}, {
  "vendor_id": "2",
  "pickup_datetime": "2022-06-03 15:27:15.000000 UTC",
  "dropoff_datetime": "2022-06-03 16:44:19.000000 UTC",
  "passenger_count": "1",
  "trip_distance": "17.6",
  "rate_code": "1.0",
  "store_and_fwd_flag": "N",
  "payment_type": "2",
  "fare_amount": "6989.5",
  "extra": "0",
  "mta_tax": "0.5",
  "tip_amount": "0",
  "tolls_amount": "6.55",
  "imp_surcharge": "0.3",
  "airport_fee": "1.25",
  "total_amount": "7000.6",
  "pickup_location_id": "138",
  "dropoff_location_id": "239",
  "data_file_year": "2022",
  "data_file_month": "6"
}, {
  "vendor_id": "2",
  "pickup_datetime": "2022-06-24 21:37:27.000000 UTC",
  "dropoff_datetime": "2022-06-24 22:42:30.000000 UTC",
  "passenger_count": "1",
  "trip_distance": "14.82",
  "rate_code": "1.0",
  "store_and_fwd_flag": "N",
  "payment_type": "2",
  "fare_amount": "6997.5",
  "extra": "0.5",
  "mta_tax": "0.5",
  "tip_amount": "0",
  "tolls_amount": "0",
  "imp_surcharge": "0.3",
  "airport_fee": "1.25",
  "total_amount": "7000.05",
  "pickup_location_id": "132",
  "dropoff_location_id": "179",
  "data_file_year": "2022",
  "data_file_month": "6"
}, {
  "vendor_id": "2",
  "pickup_datetime": "2022-06-09 15:57:01.000000 UTC",
  "dropoff_datetime": "2022-06-09 16:58:41.000000 UTC",
  "passenger_count": "1",
  "trip_distance": "20.6",
  "rate_code": "1.0",
  "store_and_fwd_flag": "N",
  "payment_type": "2",
  "fare_amount": "6989.5",
  "extra": "0",
  "mta_tax": "0.5",
  "tip_amount": "0",
  "tolls_amount": "6.55",
  "imp_surcharge": "0.3",
  "airport_fee": "0",
  "total_amount": "6999.35",
  "pickup_location_id": "70",
  "dropoff_location_id": "107",
  "data_file_year": "2022",
  "data_file_month": "6"
}, {
  "vendor_id": "2",
  "pickup_datetime": "2022-06-27 15:26:35.000000 UTC",
  "dropoff_datetime": "2022-06-27 16:22:56.000000 UTC",
  "passenger_count": "3",
  "trip_distance": "16.61",
  "rate_code": "1.0",
  "store_and_fwd_flag": "N",
  "payment_type": "2",
  "fare_amount": "6988",
  "extra": "0",
  "mta_tax": "0.5",
  "tip_amount": "0",
  "tolls_amount": "6.55",
  "imp_surcharge": "0.3",
  "airport_fee": "0",
  "total_amount": "6997.85",
  "pickup_location_id": "142",
  "dropoff_location_id": "138",
  "data_file_year": "2022",
  "data_file_month": "6"
}, {
  "vendor_id": "2",
  "pickup_datetime": "2022-06-06 14:10:52.000000 UTC",
  "dropoff_datetime": "2022-06-06 14:55:37.000000 UTC",
  "passenger_count": "1",
  "trip_distance": "20.31",
  "rate_code": "1.0",
  "store_and_fwd_flag": "N",
  "payment_type": "2",
  "fare_amount": "6986.5",
  "extra": "0",
  "mta_tax": "0.5",
  "tip_amount": "0",
  "tolls_amount": "6.55",
  "imp_surcharge": "0.3",
  "airport_fee": "1.25",
  "total_amount": "6997.6",
  "pickup_location_id": "138",
  "dropoff_location_id": "164",
  "data_file_year": "2022",
  "data_file_month": "6"
}, {
  "vendor_id": "2",
  "pickup_datetime": "2022-06-20 17:35:14.000000 UTC",
  "dropoff_datetime": "2022-06-20 18:18:40.000000 UTC",
  "passenger_count": "1",
  "trip_distance": "17.18",
  "rate_code": "1.0",
  "store_and_fwd_flag": "N",
  "payment_type": "2",
  "fare_amount": "6984",
  "extra": "1",
  "mta_tax": "0.5",
  "tip_amount": "0",
  "tolls_amount": "6.55",
  "imp_surcharge": "0.3",
  "airport_fee": "1.25",
  "total_amount": "6996.1",
  "pickup_location_id": "138",
  "dropoff_location_id": "142",
  "data_file_year": "2022",
  "data_file_month": "6"
}]
```

```sql
SELECT
    *
FROM `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2022`
ORDER BY trip_distance DESC
LIMIT 20;
```



```json
[{
  "vendor_id": "2",
  "pickup_datetime": "2022-10-28 05:19:00.000000 UTC",
  "dropoff_datetime": "2022-10-28 05:32:00.000000 UTC",
  "passenger_count": null,
  "trip_distance": "389678.46",
  "rate_code": null,
  "store_and_fwd_flag": null,
  "payment_type": "0",
  "fare_amount": "12.11",
  "extra": "0",
  "mta_tax": "0.5",
  "tip_amount": "3.42",
  "tolls_amount": "0",
  "imp_surcharge": "0.3",
  "airport_fee": null,
  "total_amount": "18.83",
  "pickup_location_id": "238",
  "dropoff_location_id": "140",
  "data_file_year": "2022",
  "data_file_month": "10"
}, {
  "vendor_id": "2",
  "pickup_datetime": "2022-05-15 18:45:00.000000 UTC",
  "dropoff_datetime": "2022-05-15 18:57:00.000000 UTC",
  "passenger_count": null,
  "trip_distance": "357192.65",
  "rate_code": null,
  "store_and_fwd_flag": null,
  "payment_type": "0",
  "fare_amount": "12.46",
  "extra": "0",
  "mta_tax": "0.5",
  "tip_amount": "4.37",
  "tolls_amount": "0",
  "imp_surcharge": "0.3",
  "airport_fee": null,
  "total_amount": "20.13",
  "pickup_location_id": "249",
  "dropoff_location_id": "137",
  "data_file_year": "2022",
  "data_file_month": "5"
}, {
  "vendor_id": "2",
  "pickup_datetime": "2022-02-15 18:24:00.000000 UTC",
  "dropoff_datetime": "2022-02-15 18:37:00.000000 UTC",
  "passenger_count": null,
  "trip_distance": "348798.53",
  "rate_code": null,
  "store_and_fwd_flag": null,
  "payment_type": "0",
  "fare_amount": "20.6",
  "extra": "0",
  "mta_tax": "0.5",
  "tip_amount": "4",
  "tolls_amount": "0",
  "imp_surcharge": "0.3",
  "airport_fee": null,
  "total_amount": "27.9",
  "pickup_location_id": "13",
  "dropoff_location_id": "107",
  "data_file_year": "2022",
  "data_file_month": "2"
}, {
  "vendor_id": "2",
  "pickup_datetime": "2022-05-19 17:00:00.000000 UTC",
  "dropoff_datetime": "2022-05-19 18:20:00.000000 UTC",
  "passenger_count": null,
  "trip_distance": "344408.48",
  "rate_code": null,
  "store_and_fwd_flag": null,
  "payment_type": "0",
  "fare_amount": "63.12",
  "extra": "0",
  "mta_tax": "0.5",
  "tip_amount": "1",
  "tolls_amount": "6.55",
  "imp_surcharge": "0.3",
  "airport_fee": null,
  "total_amount": "73.97",
  "pickup_location_id": "170",
  "dropoff_location_id": "132",
  "data_file_year": "2022",
  "data_file_month": "5"
}, {
  "vendor_id": "2",
  "pickup_datetime": "2022-05-03 09:33:00.000000 UTC",
  "dropoff_datetime": "2022-05-03 09:55:00.000000 UTC",
  "passenger_count": null,
  "trip_distance": "333632.96",
  "rate_code": null,
  "store_and_fwd_flag": null,
  "payment_type": "0",
  "fare_amount": "16.51",
  "extra": "0",
  "mta_tax": "0.5",
  "tip_amount": "3.29",
  "tolls_amount": "0",
  "imp_surcharge": "0.3",
  "airport_fee": null,
  "total_amount": "23.1",
  "pickup_location_id": "24",
  "dropoff_location_id": "43",
  "data_file_year": "2022",
  "data_file_month": "5"
}, {
  "vendor_id": "2",
  "pickup_datetime": "2022-08-17 13:07:00.000000 UTC",
  "dropoff_datetime": "2022-08-17 13:29:00.000000 UTC",
  "passenger_count": null,
  "trip_distance": "330578.66",
  "rate_code": null,
  "store_and_fwd_flag": null,
  "payment_type": "0",
  "fare_amount": "26.6",
  "extra": "0",
  "mta_tax": "0.5",
  "tip_amount": "6.65",
  "tolls_amount": "0",
  "imp_surcharge": "0.3",
  "airport_fee": null,
  "total_amount": "36.55",
  "pickup_location_id": "244",
  "dropoff_location_id": "237",
  "data_file_year": "2022",
  "data_file_month": "8"
}, {
  "vendor_id": "2",
  "pickup_datetime": "2022-04-28 08:14:00.000000 UTC",
  "dropoff_datetime": "2022-04-28 08:43:00.000000 UTC",
  "passenger_count": null,
  "trip_distance": "329408.43",
  "rate_code": null,
  "store_and_fwd_flag": null,
  "payment_type": "0",
  "fare_amount": "23.67",
  "extra": "0",
  "mta_tax": "0.5",
  "tip_amount": "5.38",
  "tolls_amount": "0",
  "imp_surcharge": "0.3",
  "airport_fee": null,
  "total_amount": "32.35",
  "pickup_location_id": "238",
  "dropoff_location_id": "113",
  "data_file_year": "2022",
  "data_file_month": "4"
}, {
  "vendor_id": "2",
  "pickup_datetime": "2022-04-16 12:36:00.000000 UTC",
  "dropoff_datetime": "2022-04-16 13:22:00.000000 UTC",
  "passenger_count": null,
  "trip_distance": "327690.79",
  "rate_code": null,
  "store_and_fwd_flag": null,
  "payment_type": "0",
  "fare_amount": "40.17",
  "extra": "0",
  "mta_tax": "0",
  "tip_amount": "21.76",
  "tolls_amount": "27.5",
  "imp_surcharge": "0.3",
  "airport_fee": null,
  "total_amount": "89.73",
  "pickup_location_id": "151",
  "dropoff_location_id": "265",
  "data_file_year": "2022",
  "data_file_month": "4"
}, {
  "vendor_id": "2",
  "pickup_datetime": "2022-02-02 07:34:00.000000 UTC",
  "dropoff_datetime": "2022-02-02 07:53:00.000000 UTC",
  "passenger_count": null,
  "trip_distance": "323919.67",
  "rate_code": null,
  "store_and_fwd_flag": null,
  "payment_type": "0",
  "fare_amount": "17.72",
  "extra": "0",
  "mta_tax": "0.5",
  "tip_amount": "3.42",
  "tolls_amount": "0",
  "imp_surcharge": "0.3",
  "airport_fee": null,
  "total_amount": "24.44",
  "pickup_location_id": "75",
  "dropoff_location_id": "48",
  "data_file_year": "2022",
  "data_file_month": "2"
}, {
  "vendor_id": "2",
  "pickup_datetime": "2022-02-27 18:57:00.000000 UTC",
  "dropoff_datetime": "2022-02-27 19:08:00.000000 UTC",
  "passenger_count": null,
  "trip_distance": "314364.45",
  "rate_code": null,
  "store_and_fwd_flag": null,
  "payment_type": "0",
  "fare_amount": "9.96",
  "extra": "0",
  "mta_tax": "0.5",
  "tip_amount": "2.83",
  "tolls_amount": "0",
  "imp_surcharge": "0.3",
  "airport_fee": null,
  "total_amount": "16.09",
  "pickup_location_id": "125",
  "dropoff_location_id": "107",
  "data_file_year": "2022",
  "data_file_month": "2"
}, {
  "vendor_id": "2",
  "pickup_datetime": "2022-10-08 19:22:00.000000 UTC",
  "dropoff_datetime": "2022-10-08 19:38:00.000000 UTC",
  "passenger_count": null,
  "trip_distance": "307246.24",
  "rate_code": null,
  "store_and_fwd_flag": null,
  "payment_type": "0",
  "fare_amount": "11.37",
  "extra": "0",
  "mta_tax": "0.5",
  "tip_amount": "3.44",
  "tolls_amount": "0",
  "imp_surcharge": "0.3",
  "airport_fee": null,
  "total_amount": "18.11",
  "pickup_location_id": "234",
  "dropoff_location_id": "79",
  "data_file_year": "2022",
  "data_file_month": "10"
}, {
  "vendor_id": "2",
  "pickup_datetime": "2022-06-24 05:37:00.000000 UTC",
  "dropoff_datetime": "2022-06-24 05:55:00.000000 UTC",
  "passenger_count": null,
  "trip_distance": "307007.11",
  "rate_code": null,
  "store_and_fwd_flag": null,
  "payment_type": "0",
  "fare_amount": "50.67",
  "extra": "0",
  "mta_tax": "0",
  "tip_amount": "0",
  "tolls_amount": "11.75",
  "imp_surcharge": "0.3",
  "airport_fee": null,
  "total_amount": "62.72",
  "pickup_location_id": "125",
  "dropoff_location_id": "1",
  "data_file_year": "2022",
  "data_file_month": "6"
}, {
  "vendor_id": "2",
  "pickup_datetime": "2022-04-26 10:04:00.000000 UTC",
  "dropoff_datetime": "2022-04-26 10:38:00.000000 UTC",
  "passenger_count": null,
  "trip_distance": "306620",
  "rate_code": null,
  "store_and_fwd_flag": null,
  "payment_type": "0",
  "fare_amount": "19.97",
  "extra": "0",
  "mta_tax": "0.5",
  "tip_amount": "5.51",
  "tolls_amount": "0",
  "imp_surcharge": "0.3",
  "airport_fee": null,
  "total_amount": "28.78",
  "pickup_location_id": "142",
  "dropoff_location_id": "107",
  "data_file_year": "2022",
  "data_file_month": "4"
}, {
  "vendor_id": "2",
  "pickup_datetime": "2022-01-11 11:48:00.000000 UTC",
  "dropoff_datetime": "2022-01-11 12:00:00.000000 UTC",
  "passenger_count": null,
  "trip_distance": "306159.28",
  "rate_code": null,
  "store_and_fwd_flag": null,
  "payment_type": "0",
  "fare_amount": "14.96",
  "extra": "0",
  "mta_tax": "0.5",
  "tip_amount": "3.94",
  "tolls_amount": "0",
  "imp_surcharge": "0.3",
  "airport_fee": null,
  "total_amount": "22.2",
  "pickup_location_id": "116",
  "dropoff_location_id": "238",
  "data_file_year": "2022",
  "data_file_month": "1"
}, {
  "vendor_id": "2",
  "pickup_datetime": "2022-11-30 10:41:00.000000 UTC",
  "dropoff_datetime": "2022-11-30 11:03:00.000000 UTC",
  "passenger_count": null,
  "trip_distance": "305756.36",
  "rate_code": null,
  "store_and_fwd_flag": null,
  "payment_type": "0",
  "fare_amount": "29.5",
  "extra": "0",
  "mta_tax": "0.5",
  "tip_amount": "4.92",
  "tolls_amount": "0",
  "imp_surcharge": "0.3",
  "airport_fee": null,
  "total_amount": "37.72",
  "pickup_location_id": "263",
  "dropoff_location_id": "209",
  "data_file_year": "2022",
  "data_file_month": "11"
}, {
  "vendor_id": "2",
  "pickup_datetime": "2022-09-25 01:37:00.000000 UTC",
  "dropoff_datetime": "2022-09-25 01:51:00.000000 UTC",
  "passenger_count": null,
  "trip_distance": "303133.41",
  "rate_code": null,
  "store_and_fwd_flag": null,
  "payment_type": "0",
  "fare_amount": "17.95",
  "extra": "0",
  "mta_tax": "0.5",
  "tip_amount": "4.31",
  "tolls_amount": "0",
  "imp_surcharge": "0.3",
  "airport_fee": null,
  "total_amount": "25.56",
  "pickup_location_id": "164",
  "dropoff_location_id": "141",
  "data_file_year": "2022",
  "data_file_month": "9"
}, {
  "vendor_id": "2",
  "pickup_datetime": "2022-11-16 08:15:00.000000 UTC",
  "dropoff_datetime": "2022-11-16 08:38:00.000000 UTC",
  "passenger_count": null,
  "trip_distance": "302707.44",
  "rate_code": null,
  "store_and_fwd_flag": null,
  "payment_type": "0",
  "fare_amount": "19.42",
  "extra": "0",
  "mta_tax": "0.5",
  "tip_amount": "5.37",
  "tolls_amount": "0",
  "imp_surcharge": "0.3",
  "airport_fee": null,
  "total_amount": "28.09",
  "pickup_location_id": "238",
  "dropoff_location_id": "164",
  "data_file_year": "2022",
  "data_file_month": "11"
}, {
  "vendor_id": "2",
  "pickup_datetime": "2022-09-11 08:19:00.000000 UTC",
  "dropoff_datetime": "2022-09-11 08:33:00.000000 UTC",
  "passenger_count": null,
  "trip_distance": "300013.03",
  "rate_code": null,
  "store_and_fwd_flag": null,
  "payment_type": "0",
  "fare_amount": "20.09",
  "extra": "0",
  "mta_tax": "0.5",
  "tip_amount": "0",
  "tolls_amount": "0",
  "imp_surcharge": "0.3",
  "airport_fee": null,
  "total_amount": "23.39",
  "pickup_location_id": "152",
  "dropoff_location_id": "142",
  "data_file_year": "2022",
  "data_file_month": "9"
}, {
  "vendor_id": "2",
  "pickup_datetime": "2022-09-01 04:01:00.000000 UTC",
  "dropoff_datetime": "2022-09-01 04:28:00.000000 UTC",
  "passenger_count": null,
  "trip_distance": "297928.53",
  "rate_code": null,
  "store_and_fwd_flag": null,
  "payment_type": "0",
  "fare_amount": "59.95",
  "extra": "0",
  "mta_tax": "0.5",
  "tip_amount": "15.22",
  "tolls_amount": "6.55",
  "imp_surcharge": "0.3",
  "airport_fee": null,
  "total_amount": "85.02",
  "pickup_location_id": "90",
  "dropoff_location_id": "132",
  "data_file_year": "2022",
  "data_file_month": "9"
}, {
  "vendor_id": "2",
  "pickup_datetime": "2022-09-12 05:11:00.000000 UTC",
  "dropoff_datetime": "2022-09-12 05:19:00.000000 UTC",
  "passenger_count": null,
  "trip_distance": "296831.17",
  "rate_code": null,
  "store_and_fwd_flag": null,
  "payment_type": "0",
  "fare_amount": "12.09",
  "extra": "0",
  "mta_tax": "0.5",
  "tip_amount": "3.41",
  "tolls_amount": "0",
  "imp_surcharge": "0.3",
  "airport_fee": null,
  "total_amount": "18.8",
  "pickup_location_id": "234",
  "dropoff_location_id": "142",
  "data_file_year": "2022",
  "data_file_month": "9"
}]
```