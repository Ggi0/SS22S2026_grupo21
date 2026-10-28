
# Dashboards — Proyecto NYC Taxi 2022

## 1. Conexión de BigQuery con Looker Studio

Dashboard:

https://datastudio.google.com/reporting/1221f7b0-defd-4309-ab2e-fbeef7b0ef53


La visualización de los resultados del proyecto se realiza mediante Looker Studio, conectado a las tablas del conjunto de datos `nyc_taxi_2022` almacenado en Google BigQuery. Para optimizar la consulta de información, se crearon tablas agregadas que contienen los indicadores necesarios para construir los gráficos, las tablas y las tarjetas de métricas de los dashboards.

La conexión utiliza como fuente de datos las tablas generadas mediante el script `04_tablas_dashboard.sql` y las tablas de evaluación y predicciones producidas por los scripts de Machine Learning.

 1) ingresar a Data Studio y crear nuevo informe.
* https://datastudio.google.com/u/0/navigation/reporting

![alt text](<../Images/dashboad/Captura de Pantalla 2026-10-27 a la(s) 10.02.27.png>)


 2) Conectarse a datos y seleccionar Big Query


![alt text](<../Images/dashboad/Captura de Pantalla 2026-10-27 a la(s) 10.04.36.png>)

 3) Seleccionar el proyecto que realizarmos en BigQuery

![alt text](<../Images/dashboad/Captura de Pantalla 2026-10-27 a la(s) 10.08.30.png>)

 4) Seleccionar las tablas qeu vamos a utilizar

![alt text](<../Images/dashboad/Captura de Pantalla 2026-10-27 a la(s) 10.10.11.png>) 
![alt text](<../Images/dashboad/Captura de Pantalla 2026-10-27 a la(s) 10.21.49.png>)

Objetivos de la conexión:

- Centralizar los resultados del análisis exploratorio y la evaluación de los modelos.
- Facilitar la consulta de indicadores sin ejecutar nuevamente las consultas completas sobre los datos originales.
- Permitir la actualización de los gráficos cuando se regeneran las tablas en BigQuery.
- Presentar los resultados mediante indicadores, gráficos comparativos y series temporales.

### 1.1. Tablas utilizadas como fuentes de datos

| Tabla de BigQuery       | Propósito                                                                                               |
| ----------------------- | ------------------------------------------------------------------------------------------------------- |
| `dash_viajes_mes`       | Resumen mensual de viajes, tarifas, distancias, duración e ingresos.                                    |
| `dash_heatmap_hora_dia` | Distribución de los viajes según el día de la semana y la hora.                                         |
| `dash_top_zonas`        | Principales zonas de recogida, volumen de viajes, tarifa promedio y proporción de propinas con tarjeta. |
| `dash_top_rutas`        | Rutas más frecuentes, tarifas promedio y distancias promedio.                                           |
| `dash_propina_hora`     | Indicadores de propinas registradas en pagos con tarjeta por hora.                                      |
| `dash_metodo_pago`      | Cantidad de viajes y monto promedio según el método de pago.                                            |
| `dash_roc_curve`        | Puntos de las curvas ROC de los modelos de clasificación.                                               |
| `dash_rolling_fare`     | Seguimiento diario de las tarifas reales y predichas.                                                   |
| `dash_rolling_tip`      | Comparación diaria de la tasa real y predicha de propinas altas.                                        |

Las tablas `dash_roc_curve`, `dash_rolling_fare` y `dash_rolling_tip` se generan a partir de los resultados de evaluación y predicción de los modelos. Además, las consultas de predicciones manuales permiten comprobar el funcionamiento de los modelos con ejemplos de viajes nuevos.

Para configurar cada fuente en Looker Studio, se selecciona BigQuery como conector, se identifica el proyecto y el conjunto de datos correspondiente y se elige la tabla que alimentará cada visualización. Los campos numéricos se configuran según su función: métricas, dimensiones, valores de series o ejes de los gráficos.


- Creacion de las tablas:
![alt text](<../Images/dashboad/Captura de Pantalla 2026-10-27 a la(s) 00.29.46.png>)

- tablas en el Datasets / nyc_taxi_2022:
![alt text](<../Images/dashboad/Captura de Pantalla 2026-10-27 a la(s) 00.33.27.png>)

## 2. Dashboard 1: Análisis Exploratorio de Viajes NYC Taxi 2022

### 2.1. Objetivo

Este dashboard presenta una visión general del comportamiento de los viajes en taxi de Nueva York durante 2022. Su propósito es facilitar el análisis del volumen de viajes, los métodos de pago, las tarifas, las distancias, la duración, las zonas de mayor demanda y el comportamiento de las propinas.

El tablero combina indicadores generales con gráficos que permiten comparar categorías, identificar patrones temporales y observar diferencias entre zonas de recogida.

### 2.2. Indicadores generales

En la parte central del dashboard se muestran cuatro indicadores principales:

| Indicador            | Descripción                                                        |
| -------------------- | ------------------------------------------------------------------ |
| `viajes`             | Cantidad total de registros de viajes considerados en el análisis. |
| `ingresos_totales`   | Suma del campo `total_amount` de los viajes.                       |
| `tarifa_promedio`    | Promedio del campo `fare_amount`.                                  |
| `distancia_promedio` | Distancia promedio recorrida por los taxis.                        |

Estos indicadores permiten obtener una referencia general del tamaño del conjunto de datos, los ingresos registrados y las características económicas y operativas de los viajes.

Los valores que aparecen en las tarjetas corresponden a las agregaciones calculadas en BigQuery y mostradas por Looker Studio.

![alt text](<../Images/dashboad/Captura de Pantalla 2026-10-27 a la(s) 16.57.53.png>)

### 2.3. Distribución de métodos de pago

Esta visualización compara los métodos de pago registrados en los viajes.

Fuente: `dash_metodo_pago`.

Los campos utilizados son:

- `metodo`: categoría del método de pago.
- `viajes`: cantidad de viajes asociados a cada categoría.
- `total_promedio`: monto promedio total de los viajes de cada categoría.

El gráfico permite comparar la frecuencia de los métodos de pago y observar diferencias en el monto promedio asociado a cada uno. Las categorías consideradas en la consulta son tarjeta, efectivo, sin cargo y disputa.

La consulta agrupa los registros por método de pago y calcula tanto la cantidad de viajes como el promedio de `total_amount`.

![alt text](<../Images/dashboad/Captura de Pantalla 2026-10-27 a la(s) 16.58.50.png>)

### 2.4. Tendencia de demanda por mes

Este gráfico muestra la evolución mensual de las principales características de los viajes.

Fuente: `dash_viajes_mes`.

Los indicadores utilizados son:

- `mes`: mes de recogida.
- `viajes`: cantidad de registros de viajes.
- `tarifa_promedio`: tarifa promedio mensual.
- `distancia_promedio`: distancia promedio mensual.
- `duracion_promedio_min`: duración promedio en minutos.
- `ingresos_totales`: suma mensual de los montos totales.

La visualización permite comparar el comportamiento de los viajes entre meses y observar variaciones en la duración y la distancia promedio. También proporciona una base para relacionar la actividad mensual con los ingresos y el número de viajes registrados.

![alt text](<../Images/dashboad/Captura de Pantalla 2026-10-27 a la(s) 16.59.22.png>)

### 2.5. Zonas de mayor demanda frente a propinas

Este gráfico compara el volumen de viajes de las principales zonas de recogida con la proporción promedio de propinas registradas en pagos con tarjeta.

Fuente: `dash_top_zonas`.

Los campos principales son:

- `zona`: nombre de la zona de recogida.
- `distrito`: distrito o borough correspondiente.
- `viajes`: cantidad de viajes que comienzan en la zona.
- `tarifa_promedio`: tarifa promedio de los viajes de la zona.
- `propina_pct_tarjeta`: promedio de `tip_pct` cuando el método de pago es tarjeta.

La consulta relaciona los viajes con la tabla geográfica `taxi_zone_geom` mediante el identificador de la zona de recogida. Después, agrupa los registros por zona y distrito, ordena las zonas por cantidad de viajes y conserva las primeras 30.

El gráfico permite identificar zonas con mayor actividad y contrastar su volumen de viajes con el comportamiento de las propinas registradas mediante tarjeta.

Consideración: la proporción de propinas se calcula únicamente con registros de pago con tarjeta. Por tanto, no representa necesariamente las propinas de todos los viajes, ya que las propinas en efectivo no quedan registradas de la misma manera en los datos.

![alt text](<../Images/dashboad/Captura de Pantalla 2026-10-27 a la(s) 16.59.53.png>)

### 2.6. Intensidad de viajes según hora y día

Esta visualización está destinada a analizar la distribución de la demanda según la hora y el día de la semana.

Fuente: `dash_heatmap_hora_dia`.

Los campos utilizados son:

- `dia_num`: número del día de la semana.
- `dia`: abreviatura del día.
- `hora`: hora de recogida.
- `viajes`: cantidad de viajes registrados.
- `tarifa_promedio`: tarifa promedio de los viajes correspondientes a cada combinación.

La consulta agrupa los registros por día y hora. El resultado permite estudiar cómo cambia la actividad a lo largo de la semana y durante las diferentes horas del día.

Esta información puede utilizarse para identificar periodos con mayor concentración de viajes y explorar si existen diferencias en las tarifas promedio según el momento en que se realiza el servicio.

![alt text](<../Images/dashboad/Captura de Pantalla 2026-10-27 a la(s) 17.00.18.png>)

### 2.7. Comportamiento de los pagos con tarjeta a lo largo del día

La tabla situada en la parte inferior presenta el comportamiento de los viajes pagados con tarjeta, agrupados por hora.

Fuente: `dash_propina_hora`.

Los campos principales son:

- `hora`: hora de recogida.
- `viajes_tarjeta`: cantidad de viajes pagados con tarjeta.
- `propina_pct_promedio`: porcentaje promedio de propina.
- `proporcion_propina_alta`: proporción de viajes cuya propina alcanza o supera el 20 % de la tarifa.

La consulta filtra los registros con `payment_type = '1'` y `fare_amount > 0`. Posteriormente, agrupa los viajes por hora y calcula las métricas relacionadas con las propinas.

Esta visualización permite comparar la actividad de los pagos con tarjeta durante el día y estudiar la frecuencia con que se registran propinas altas.

![alt text](<../Images/dashboad/Captura de Pantalla 2026-10-27 a la(s) 17.00.57.png>)

### 2.8. Interpretación general del dashboard exploratorio

El primer dashboard funciona como una herramienta de análisis descriptivo. Sus visualizaciones permiten examinar conjuntamente el volumen de viajes, la distribución de los pagos, las características de los recorridos y las diferencias entre zonas y periodos.

Los resultados sirven como contexto para comprender el comportamiento de los datos antes de interpretar las predicciones de Machine Learning. Sin embargo, las relaciones observadas en los gráficos son descriptivas y no demuestran por sí mismas una relación causal entre las variables.

![alt text](<../Images/dashboad/Captura de Pantalla 2026-10-27 a la(s) 17.01.30.png>)

## 3. Dashboard 2: Evaluación de Modelos de Machine Learning

### 3.1. Objetivo

El segundo dashboard presenta los resultados de evaluación de los modelos de regresión y clasificación, junto con el seguimiento temporal de sus predicciones.

Su finalidad es comparar el rendimiento de los modelos, visualizar las diferencias entre las estrategias de entrenamiento y comprobar cómo se comportan las predicciones frente a los valores reales durante noviembre de 2022.

Se incluyen dos tareas principales:

1. Regresión: estimación del importe de la tarifa del viaje.
2. Clasificación: predicción de si un viaje tendrá una propina alta, definida mediante la variable `tip_alta`.

### 3.2. Comparación del volumen de datos procesados por estrategia

Esta visualización compara el volumen de datos asociado con las distintas estrategias de procesamiento.

El gráfico presenta las categorías:

- Limpia sin optimizar.
- Pública (original).
- Partición + cluster.

Los indicadores representados son `mb_procesados` y `mb_facturados`, que permiten comparar el volumen procesado y el volumen facturado por cada estrategia, según los datos disponibles para la visualización.

La comparación permite observar el efecto de las estrategias de preparación y organización de los datos sobre el procesamiento de las consultas.

La interpretación debe centrarse en los valores mostrados en el gráfico: la cantidad de datos procesados y facturados por estrategia. Estos valores no representan directamente el tiempo de entrenamiento ni la precisión de los modelos.

![alt text](<../Images/dashboad/Captura de Pantalla 2026-10-27 a la(s) 17.02.26.png>)

### 3.3. Comparación de modelos de regresión

Esta visualización compara los resultados de los modelos que estiman la tarifa de los viajes.

Los modelos incluidos son:

- `baseline_promedio`: referencia que utiliza el promedio de la tarifa de entrenamiento.
- `m1_lin_random`: modelo de regresión lineal con partición aleatoria.
- `m1_lin_temporal`: modelo de regresión lineal con partición temporal.

Las métricas representadas son:

| Métrica    | Interpretación                                                                                                                             |
| ---------- | ------------------------------------------------------------------------------------------------------------------------------------------ |
| `mae`      | Error absoluto medio. Indica cuánto se desvían, en promedio, las predicciones de las tarifas reales, en las unidades de la tarifa.         |
| `rmse`     | Raíz del error cuadrático medio. Penaliza con mayor intensidad los errores grandes.                                                        |
| `r2_score` | Coeficiente de determinación, que mide la capacidad del modelo para explicar la variabilidad de la variable objetivo cuando está definido. |

El objetivo es comparar la precisión de las predicciones y determinar qué estrategia ofrece resultados más adecuados.

De acuerdo con los resultados de evaluación proporcionados, el modelo `m1_lin_temporal` obtuvo un RMSE de aproximadamente 2.76 y un MAE de aproximadamente 0.98 en el conjunto de prueba. Por su parte, `baseline_promedio` obtuvo un RMSE aproximado de 13.07 y un MAE de 8.37.

![alt text](<../Images/dashboad/Captura de Pantalla 2026-10-27 a la(s) 17.03.13.png>)

Estos valores muestran que el modelo temporal redujo considerablemente el error respecto a la referencia basada en el promedio. El modelo `m1_lin_random` presenta un RMSE reportado de aproximadamente 52.70, junto con un MAE de 1.17 y un \\(R^2\\) de aproximadamente -15.29. La diferencia marcada entre su RMSE y MAE indica que conviene investigar la presencia de errores de predicción especialmente grandes.

Nota de interpretación: el MAE, el RMSE y el \\(R^2\\) tienen escalas y significados distintos. No deben interpretarse como si fueran una misma medida de precisión.

### 3.4. Curva ROC de los modelos de clasificación

La visualización de la curva ROC permite evaluar la capacidad de los modelos para distinguir entre viajes con propina alta y viajes sin propina alta.

Fuente: `dash_roc_curve`.

Esta tabla se genera mediante `ML.ROC_CURVE` para los modelos `m2_log_temporal` y `m2_log_random`, utilizando registros del conjunto `TEST` que cumplen las condiciones de pago con tarjeta y disponibilidad de la etiqueta `tip_alta`.

Los campos principales son:

- `modelo`: modelo evaluado.
- `threshold`: umbral utilizado para convertir las probabilidades en clasificaciones.
- `recall`: proporción de positivos reales identificados correctamente.
- `false_positive_rate`: proporción de negativos reales clasificados incorrectamente como positivos.

La curva ROC representa la relación entre la tasa de verdaderos positivos y la tasa de falsos positivos para diferentes umbrales. Esto permite analizar cómo cambia el comportamiento del clasificador cuando se modifica el umbral de decisión.

Un modelo con mayor capacidad discriminativa suele presentar una curva más cercana a la esquina superior izquierda del gráfico y un área bajo la curva (ROC-AUC) más elevada.

![alt text](<../Images/dashboad/Captura de Pantalla 2026-10-27 a la(s) 17.03.39.png>)

Los resultados disponibles muestran un ROC-AUC aproximado de 0.611 para `m2_log_random` y 0.611 para `m2_log_temporal`. Estos valores sugieren una capacidad de discriminación limitada, por lo que conviene considerar también las métricas de precisión, recall y F1 al evaluar ambos modelos.

### 3.5. Comparación de modelos de clasificación

Esta tabla compara las métricas de los modelos que predicen si un viaje tendrá una propina alta.

Los modelos evaluados son:

- `m2_log_random`: modelo de clasificación entrenado con partición aleatoria.
- `m2_log_temporal`: modelo de clasificación entrenado con partición temporal.

Las métricas presentadas son:

| Métrica     | Interpretación                                                                                          |
| ----------- | ------------------------------------------------------------------------------------------------------- |
| `recall`    | Proporción de viajes con propina alta que el modelo identifica correctamente.                           |
| `f1_score`  | Media armónica entre precisión y recall.                                                                |
| `roc_auc`   | Capacidad del modelo para ordenar los casos positivos por encima de los negativos a distintos umbrales. |
| `accuracy`  | Proporción total de predicciones correctas.                                                             |
| `precision` | Proporción de predicciones positivas que realmente corresponden a viajes con propina alta.              |

Los resultados de evaluación proporcionados son los siguientes:

| Métrica   | `m2_log_random` | `m2_log_temporal` |
| --------- | --------------- | ----------------- |
| Precision | 0.797           | 0.826             |
| Recall    | 0.999           | 0.717             |
| Accuracy  | 0.797           | 0.655             |
| F1-score  | 0.886           | 0.768             |
| Log loss  | 0.497           | 0.686             |
| ROC-AUC   | 0.611           | 0.611             |

El modelo aleatorio presenta un recall muy alto, lo que significa que identifica casi todos los casos de propina alta en la evaluación reportada. Sin embargo, este comportamiento debe analizarse junto con la precisión y la matriz de confusión, debido a que un clasificador puede identificar muchos positivos a costa de generar numerosos falsos positivos.

El modelo temporal presenta mayor precisión, pero un recall inferior. Esto indica que, entre los casos que predice como positivos, una proporción mayor es correcta, aunque deja sin identificar más viajes que realmente tienen propina alta.

La comparación permite observar el compromiso entre detectar la mayor cantidad posible de casos positivos y evitar clasificaciones positivas incorrectas.

![alt text](<../Images/dashboad/Captura de Pantalla 2026-10-27 a la(s) 17.04.20.png>)

### 3.6. Seguimiento temporal de la predicción de tarifas

Esta visualización compara la tarifa real promedio y la tarifa predicha promedio por día durante el periodo de evaluación.

Fuente: `dash_rolling_fare`.

La tabla se construye a partir de los resultados almacenados en `pred_fare_test`, agrupando por modelo y fecha.

Los campos principales son:

- `modelo`: modelo que generó las predicciones.
- `fecha`: fecha del viaje.
- `viajes`: cantidad de registros considerados en el día.
- `fare_real_prom`: tarifa real promedio.
- `fare_predicho_prom`: tarifa predicha promedio.
- `rmse_dia`: RMSE calculado para los registros del día.

El gráfico permite observar si las predicciones siguen la evolución de las tarifas reales a lo largo del periodo.

Cuando las dos líneas presentan valores cercanos, las medias predichas y reales son similares para esa fecha. Las diferencias entre ellas permiten identificar días en los que el modelo podría estar sobreestimando o subestimando la tarifa promedio.

El indicador `rmse_dia` complementa la comparación, ya que cuantifica el error de las predicciones individuales de cada día y no solamente la diferencia entre los promedios.

![alt text](<../Images/dashboad/Captura de Pantalla 2026-10-27 a la(s) 17.04.58.png>)

Esta visualización resulta útil para comprobar si el comportamiento del modelo se mantiene relativamente estable a lo largo del tiempo, en lugar de depender únicamente de una métrica global del conjunto de prueba.

### 3.7. Tasa real frente a tasa predicha de propinas altas

Esta visualización compara la proporción real de viajes con propina alta frente a la proporción estimada por el modelo de clasificación en cada día.

Fuente: `dash_rolling_tip`.

La tabla se genera a partir de `pred_tip_test` y contiene los siguientes campos:

- `modelo`: modelo de clasificación.
- `fecha`: fecha del viaje.
- `viajes`: cantidad de registros considerados.
- `tasa_real_propina_alta`: promedio de la etiqueta real `tip_real`.
- `tasa_predicha_propina_alta`: promedio de la clase predicha `tip_predicho`.
- `prob_promedio`: probabilidad promedio estimada para la clase de propina alta.

La tasa real se obtiene promediando la etiqueta binaria, mientras que la tasa predicha se obtiene promediando las clases estimadas por el modelo. Como ambas variables son binarias, sus promedios representan proporciones.

La comparación permite determinar si el modelo reproduce aproximadamente la frecuencia diaria observada de propinas altas.

Si la tasa predicha se mantiene sistemáticamente por encima de la tasa real, el modelo podría estar sobreestimando la frecuencia de esta clase. Si se encuentra por debajo, podría estar subestimándola.

![alt text](<../Images/dashboad/Captura de Pantalla 2026-10-27 a la(s) 17.06.11.png>)

La columna `prob_promedio` proporciona información adicional sobre la confianza promedio de las predicciones, aunque no equivale directamente a la proporción de clases que el modelo predice como positivas.

### 3.8. . Interpretación general del dashboard de Machine Learning

El segundo dashboard integra tres dimensiones de evaluación:

1. Eficiencia del procesamiento: comparación del volumen de datos procesados y facturados por estrategia.
2. Rendimiento predictivo: comparación de métricas de regresión y clasificación, junto con la curva ROC.
3. Comportamiento temporal: comparación diaria entre los valores reales y las predicciones de tarifas y propinas altas.

La evaluación de regresión permite identificar qué modelo estima mejor las tarifas, mientras que la evaluación de clasificación muestra las diferencias entre detectar casos positivos y evitar falsos positivos. El seguimiento temporal complementa estas métricas al mostrar cómo se comportan los resultados durante noviembre.

En conjunto, estas visualizaciones permiten analizar tanto la calidad de las predicciones como el comportamiento de los modelos durante el periodo evaluado.

![alt text](<../Images/dashboad/Captura de Pantalla 2026-10-27 a la(s) 17.09.38.png>)

## 4.  Conclusión

Los dos dashboards proporcionan una interfaz de consulta para los resultados del proyecto NYC Taxi 2022. El primero presenta el análisis exploratorio de los viajes, sus características económicas y operativas, y los patrones de demanda. El segundo muestra la evaluación de los modelos de Machine Learning, la comparación de sus métricas y el seguimiento temporal de sus predicciones.

La conexión entre BigQuery y Looker Studio permite convertir las tablas calculadas mediante SQL en visualizaciones que facilitan la interpretación de los resultados. De esta manera, el proyecto integra la preparación de datos, el análisis descriptivo, el entrenamiento de modelos, la evaluación predictiva y la presentación de resultados en una solución de análisis reproducible.
