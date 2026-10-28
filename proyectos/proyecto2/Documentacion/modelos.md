
# Construcción de Features para Machine Learning

## Objetivo

En esta etapa se construye la tabla `ml_features`, que contiene todas las variables necesarias para entrenar y evaluar los modelos de Machine Learning en BigQuery ML.

La finalidad es transformar los registros de viajes de taxi en un conjunto de datos adecuado para aprendizaje automático, evitando problemas de calidad y fuga de información (*data leakage*).

---

# ¿Qué es Machine Learning (ML)?

Machine Learning es una técnica que permite que un sistema aprenda patrones a partir de datos históricos para realizar predicciones sobre datos nuevos.

En este proyecto se utilizarán dos modelos:

## Modelo 1: Regresión Lineal

Su objetivo es predecir:

```text
fare_amount
```

Es decir:

> ¿Cuánto costará un viaje de taxi?

---

## Modelo 2: Regresión Logística

Su objetivo es predecir:

```text
tip_alta
```

Es decir:

> ¿El pasajero dejará una propina alta o no?

La variable se define como:

```sql
tip_amount >= 20% del fare_amount
```

si se cumple:

```text
1 = Propina alta
```

caso contrario:

```text
0 = Propina baja o normal
```

---

# ¿Qué son las Features?

Las *features* son las variables de entrada que utilizarán los modelos para aprender patrones.

Por ejemplo:

| Variable | Descripción |
|----------|------------|
| trip_distance | Distancia recorrida |
| trip_duration_min | Duración del viaje |
| pickup_hour | Hora de inicio |
| passenger_count | Cantidad de pasajeros |
| pickup_location_id | Zona de origen |
| dropoff_location_id | Zona de destino |
| rate_code | Tipo de tarifa |

Estas variables ayudan al modelo a encontrar relaciones entre los viajes y su costo o propina.

---

# ¿Qué variables se quieren predecir?

## Objetivo del Modelo 1

```sql
fare_amount
```

Ejemplo:

| Distancia | Duración | Pasajeros | Resultado |
|------------|----------|------------|------------|
| 5 km | 15 min | 2 | $18 |
| 10 km | 30 min | 1 | $32 |

El modelo intenta aprender esta relación.

---

## Objetivo del Modelo 2

```sql
tip_alta
```

Ejemplo:

| Propina | Resultado |
|----------|----------|
| 25% | 1 |
| 10% | 0 |

El modelo intentará identificar cuándo existe una alta probabilidad de recibir una propina considerable.

---

# ¿Qué es Data Leakage?

Data Leakage (fuga de información) ocurre cuando el modelo recibe información que en la realidad todavía no debería conocer.

Por ejemplo:

Si se quiere predecir:

```sql
fare_amount
```

sería incorrecto darle al modelo:

```sql
total_amount
```

porque:

```text
total_amount =
fare_amount +
tip_amount +
impuestos
```

El modelo estaría viendo parte de la respuesta.

Por esta razón el script excluye varias columnas que podrían provocar este problema.

---

# División de Datos (Split)

Los datos se dividen en tres grupos para evaluar correctamente los modelos.

## TRAIN

Datos utilizados para entrenar.

```text
Enero 2022 → Septiembre 2022
```

---

## EVAL

Datos utilizados para evaluación interna.

```text
Octubre 2022
```

---

## TEST

Datos completamente nuevos.

```text
Noviembre 2022
```

---

Visualmente:

```text
TRAIN ---> Aprende
EVAL ----> Ajuste y validación
TEST ----> Examen final
```

---

# ¿Por qué el split es temporal?

En problemas reales no se debe entrenar utilizando información futura.

Incorrecto:

```text
Entrenar con noviembre
Predecir marzo
```

Correcto:

```text
Entrenar con enero-septiembre
Validar con octubre
Probar con noviembre
```

Este enfoque evita fugas de información temporal.

---

# Muestreo del 5%

El dataset original contiene más de 36 millones de viajes.

Para reducir costos y tiempos de entrenamiento se utiliza:

```sql
MOD(ABS(trip_key), 100) < 5
```

lo que conserva aproximadamente:

```text
5% de los registros
```

equivalente a:

```text
~1.6 millones de filas
```

![alt text](<../Images/ml-modelos/Captura de Pantalla 2026-10-27 a la(s) 01.00.22.png>)

---

# Variables del Modelo 1 (Regresión)

Objetivo:

```sql
fare_amount
```

Variables de entrada:

```text
trip_distance
trip_duration_min
pickup_hour
pickup_dow
passenger_count
pickup_location_id
dropoff_location_id
rate_code
is_weekend
is_rush_hour
```

---

# Variables del Modelo 2 (Clasificación)

Objetivo:

```sql
tip_alta
```

Variables de entrada:

```text
fare_amount
fare_per_mile
trip_distance
trip_duration_min
pickup_hour
pickup_dow
passenger_count
pickup_location_id
dropoff_location_id
rate_code
is_weekend
is_rush_hour
```

---

# ¿Qué hace la consulta principal?

La instrucción:

```sql
CREATE OR REPLACE TABLE ml_features
```

crea una nueva tabla que:

1. Selecciona los viajes válidos.
2. Construye las variables de entrada.
3. Genera las variables objetivo.
4. Crea las columnas de entrenamiento, evaluación y prueba.
5. Guarda el resultado para BigQuery ML.

![alt text](<../Images/ml-modelos/Captura de Pantalla 2026-10-27 a la(s) 01.01.54.png>)

---

# Verificación 1

Después de crear la tabla se ejecuta:

```sql
SELECT split_set, COUNT(*)
```

para verificar cuántas filas contiene cada grupo.

Resultado esperado:

| Split | Filas    | Fare Promedio | Filas con Tarjeta | Proporción Propina Alta |
|-------|----------|---------------|-------------------|--------------------------|
| TRAIN | 1,353,080 | 14.2          | 1,073,991         | 0.79                     |
| EVAL  | 169,021   | 15.01         | 135,627           | 0.789                    |
| TEST  | 150,245   | 14.84         | 120,742           | 0.794                    |



![alt text](<../Images/ml-modelos/Captura de Pantalla 2026-10-27 a la(s) 01.05.36.png>)


![alt text](<../Images/ml-modelos/filas, fare_promedio, filas_tarjeta, proporcion_propina_alta por split_set.png>)

---

# Verificación 2

Se ejecuta:

```sql
SELECT COUNTIF(...)
```

para detectar valores nulos.

Resultado esperado:

```text
filas_con_nulos = 0
```

Si aparecen nulos será necesario corregirlos antes de entrenar los modelos.

![alt text](<../Images/ml-modelos/Captura de Pantalla 2026-10-27 a la(s) 01.10.20.png>)
---

# Resultado Final

Al finalizar este paso se dispondrá de una tabla:

```text
ml_features
```

![alt text](<../Images/ml-modelos/Captura de Pantalla 2026-10-27 a la(s) 01.11.23.png>)

que servirá como fuente de datos para:

- Modelo de Regresión Lineal (`fare_amount`)
- Modelo de Regresión Logística (`tip_alta`)

garantizando:

- Datos limpios.
- División temporal correcta.
- Ausencia de data leakage.
- Menor costo computacional gracias al muestreo del 5%.


# Modelo 1 - Regresión Lineal (Predicción de `fare_amount`)

## Objetivo

Entrenar modelos de regresión lineal para predecir el costo base de un viaje de taxi (`fare_amount`) utilizando características del viaje como distancia, duración, hora, ubicación y número de pasajeros.

![alt text](<../Images/ml-modelos/Captura de Pantalla 2026-10-27 a la(s) 02.03.37.png>)

---

## Variable Objetivo

```text
fare_amount
```

Representa la tarifa base del viaje en dólares.

---

# Estrategias de Entrenamiento

Se entrenan dos variantes del mismo modelo para comparar métodos de validación e hiperparámetros.

## Variante A: Split Aleatorio

Modelo:

```text
m1_lin_random
```

Configuración:

```sql
data_split_method = 'RANDOM'
data_split_eval_fraction = 0.2
max_iterations = 20
```
![alt text](<../Images/ml-modelos/Captura de Pantalla 2026-10-27 a la(s) 01.42.21.png>)

Características:

- Utiliza una división aleatoria de los datos.
- 80% para entrenamiento.
- 20% para evaluación.
- No utiliza regularización.
- Puede mezclar registros de distintos meses.

![alt text](<../Images/ml-modelos/Captura de Pantalla 2026-10-27 a la(s) 01.43.17.png>)

---

## Variante B: Split Temporal Personalizado

Modelo:

```text
m1_lin_temporal
```

Configuración:

```sql
data_split_method = 'CUSTOM'
data_split_col = 'is_eval'
l2_reg = 0.1
max_iterations = 30
```
![alt text](<../Images/ml-modelos/Captura de Pantalla 2026-10-27 a la(s) 01.49.48.png>)

Características:

- Entrena con datos de enero a septiembre.
- Evalúa con datos de octubre.
- Respeta el orden temporal de los eventos.
- Utiliza regularización L2.
- Reduce el riesgo de sobreajuste.
![alt text](<../Images/ml-modelos/Captura de Pantalla 2026-10-27 a la(s) 01.50.18.png>)


### Ventaja

Representa un escenario más cercano al mundo real y evita data leakage temporal.

---

# Orden de Ejecución

## Paso 1

Crear modelo aleatorio:

```sql
CREATE OR REPLACE MODEL ... m1_lin_random
```

Esperar a que finalice el entrenamiento.

---

## Paso 2

Crear modelo temporal:

```sql
CREATE OR REPLACE MODEL ... m1_lin_temporal
```

Esperar a que finalice el entrenamiento.

---

## Paso 3

Evaluar ambos modelos:

```sql
ML.EVALUATE(...)
```

---

## Paso 4

Consultar información del entrenamiento:

```sql
ML.TRAINING_INFO(...)
```

---

## Paso 5

Consultar pesos de las variables:

```sql
ML.WEIGHTS(...)
```

---

# Evaluación del Modelo

Consulta utilizada:

```sql
ML.EVALUATE()
```

Métricas principales:

## RMSE

```text
Root Mean Squared Error
```

Mide el error promedio de predicción.

Interpretación:

```text
Menor RMSE = Mejor modelo
```

---

## MAE

```text
Mean Absolute Error
```

Indica cuánto se equivoca el modelo en promedio.

Interpretación:

```text
Menor MAE = Mejor modelo
```

---

## R² Score

```text
Coeficiente de determinación
```

Mide qué tan bien explica el modelo la variabilidad de los datos.

Interpretación:

```text
Más cercano a 1 = Mejor ajuste
```

![alt text](<../Images/ml-modelos/Captura de Pantalla 2026-10-27 a la(s) 01.54.27.png>)


![alt text](<../Images/ml-modelos/Captura de Pantalla 2026-10-27 a la(s) 01.56.02.png>)
---

# Interpretación de los resultados del Modelo 1: Regresión lineal

## 1. Comparación del desempeño de los modelos

Se evaluaron dos variantes de regresión lineal para predecir `fare_amount`:

- **`m1_lin_random`:** utiliza una división aleatoria de los datos, con 80 % para entrenamiento y 20 % para evaluación.
- **`m1_lin_temporal`:** entrena con datos de enero a septiembre y evalúa con datos de octubre, utilizando regularización L2.

Los resultados de `ML.EVALUATE` fueron los siguientes:

| Modelo | RMSE | MAE | R² |
|---|---:|---:|---:|
| `m1_lin_random` | 37.0305 | 0.9999 | -7.3136 |
| `m1_lin_temporal` | 2.9509 | 1.0030 | 0.9517 |

**Interpretación:**

- **RMSE:** el modelo temporal obtuvo un error considerablemente menor, lo que indica un mejor control de las predicciones con errores grandes.
- **MAE:** ambos modelos presentan un error absoluto promedio cercano a un dólar.
- **R²:** el modelo aleatorio obtuvo un valor negativo, mientras que el temporal alcanzó `0.9517`, lo que indica que explica aproximadamente el 95.17 % de la variabilidad de las tarifas en el conjunto de evaluación.

El RMSE del modelo temporal se redujo aproximadamente un **92.03 %** respecto al modelo aleatorio.

**Conclusión:** `m1_lin_temporal` presentó el mejor desempeño general y es la variante seleccionada para predecir las tarifas.

---

## 2. Información del entrenamiento

Se utilizó `ML.TRAINING_INFO` para consultar las pérdidas y la duración del entrenamiento de ambos modelos.

| Modelo | Iteración | Loss | Eval loss | Duración |
|---|---:|---:|---:|---:|
| `m1_lin_random` | 0 | 7.6491 | 1371.2554 | 4217 ms |
| `m1_lin_temporal` | 0 | 7.5138 | 8.7075 | 4353 ms |

**Interpretación:**

- En `m1_lin_random`, la pérdida de evaluación fue aproximadamente **179.27 veces** la pérdida de entrenamiento. Esta diferencia evidencia un comportamiento muy desfavorable en los datos de evaluación.
- En `m1_lin_temporal`, la pérdida de evaluación fue aproximadamente **15.88 % mayor** que la de entrenamiento, lo que refleja una diferencia considerablemente menor entre ambos conjuntos.
- Los tiempos de ejecución fueron similares: aproximadamente 4.2 y 4.4 segundos, respectivamente.

Solo se registró la iteración `0` para cada modelo. Por ello, no es posible analizar una tendencia de convergencia a través de múltiples iteraciones.

**Conclusión:** los resultados del entrenamiento respaldan la elección del modelo temporal por su comportamiento más estable entre los conjuntos de entrenamiento y evaluación.

---

## 3. Interpretación de los coeficientes

Mediante `ML.WEIGHTS` se obtuvieron los coeficientes del modelo `m1_lin_temporal`.

| Variable | Coeficiente | Interpretación |
|---|---:|---|
| Intercepto | 5.8152 | Valor base estimado cuando las variables numéricas valen cero y las demás condiciones de referencia se mantienen. |
| `trip_distance` | 1.9895 | Una unidad adicional de distancia se asocia con un aumento aproximado de $1.99 en la tarifa estimada. |
| `trip_duration_min` | 0.2664 | Un minuto adicional se asocia con un aumento aproximado de $0.27. |
| `is_weekend` | 0.1747 | Si es una variable binaria de 0 y 1, pasar de día laborable a fin de semana aumenta la predicción aproximadamente $0.17. |
| `is_rush_hour` | -0.1324 | Si es una variable binaria de 0 y 1, pasar de fuera de hora pico a hora pico reduce la predicción aproximadamente $0.13. |
| `passenger_count` | 0.0090 | Un pasajero adicional se asocia con un aumento aproximado de $0.009, manteniendo constantes las demás variables. |

Las interpretaciones corresponden a asociaciones estimadas por el modelo, manteniendo constantes las demás variables. No implican necesariamente relaciones causales.

La distancia presenta el mayor coeficiente positivo entre las variables numéricas mostradas. Sin embargo, los coeficientes no deben utilizarse como un ranking definitivo de importancia, ya que las variables tienen unidades y escalas diferentes.

**Conclusión:** la distancia y la duración tienen coeficientes positivos importantes en la ecuación del modelo, mientras que `is_rush_hour` presenta una asociación negativa. Estos resultados describen cómo el modelo calcula sus predicciones, pero no demuestran por sí solos qué factores causan cambios en las tarifas.

## Conclusión general

El modelo **`m1_lin_temporal`** fue la mejor variante de las dos evaluadas. Obtuvo un RMSE de `2.9509`, un MAE de `1.0030` y un R² de `0.9517`. Además, presentó una diferencia mucho menor entre la pérdida de entrenamiento y la de evaluación.

Por estas razones, se selecciona como el modelo más adecuado de los dos para la predicción de tarifas, según las métricas obtenidas en sus respectivos conjuntos de evaluación.









# Modelo 2: Regresión logística (Predicción de propina alta)

## Objetivo

Entrenar modelos de regresión logística para clasificar si un viaje de taxi recibe una propina alta, definida como una propina igual o superior al 20 % de `fare_amount`.

La variable objetivo es binaria:

- **Clase 1:** propina alta (`tip_amount >= 0.20 * fare_amount`).
- **Clase 0:** propina menor al 20 % de `fare_amount`.

Se utilizan únicamente viajes pagados con tarjeta (`payment_type = '1'`), porque en los viajes pagados en efectivo la propina no se registra de la misma manera y podría generar etiquetas incorrectas.

![alt text](<../Images/ml-modelos/M2/Captura de Pantalla 2026-10-27 a la(s) 02.16.09.png>)

---

## 1. Estrategias de entrenamiento

Se entrenaron dos variantes para comparar el método de división de los datos y las técnicas de regularización.

### Variante A: División aleatoria

**Modelo:** `m2_log_random`

Configuración:

- División aleatoria: 80 % para entrenamiento y 20 % para evaluación.
- Sin regularización explícita.
- Hasta 20 iteraciones planificadas.

El entrenamiento completó **4 de las 20 iteraciones planificadas**.

![alt text](<../Images/ml-modelos/M2/Captura de Pantalla 2026-10-27 a la(s) 02.10.28.png>)


### Variante B: División temporal personalizada

**Modelo:** `m2_log_temporal`

Configuración:

- Entrenamiento con datos de enero a septiembre.
- Evaluación con datos de octubre.
- Regularización L2 (`l2_reg = 0.1`).
- Ponderación automática de clases (`AUTO_CLASS_WEIGHTS = TRUE`).
- Hasta 30 iteraciones planificadas.

El entrenamiento completó **2 de las 30 iteraciones planificadas**.

![alt text](<../Images/ml-modelos/M2/Captura de Pantalla 2026-10-27 a la(s) 02.13.13.png>)

### Ventaja del modelo temporal

La división temporal permite evaluar el modelo con datos posteriores a los utilizados para entrenarlo, evitando mezclar aleatoriamente registros de distintos períodos. La regularización L2 ayuda a controlar el sobreajuste y la ponderación automática busca compensar el desbalance entre clases.



---

## 2. Evaluación de los modelos

Se utilizaron las métricas de clasificación obtenidas con un umbral de decisión de `0.5`.

| Métrica | `m2_log_random` | `m2_log_temporal` |
|---|---:|---:|
| Precision | 0.7920 | 0.8221 |
| Recall | 0.9990 | 0.7091 |
| Accuracy | 0.7923 | 0.6493 |
| F1-score | 0.8836 | 0.7615 |
| Log loss | 0.5028 | 0.6874 |
| ROC-AUC | 0.6116 | 0.6102 |

### Interpretación de las métricas

- **Precision:** el modelo temporal obtuvo `0.8221`, lo que significa que aproximadamente el 82.21 % de los viajes clasificados como propina alta realmente pertenecen a esa clase.
- **Recall:** el modelo aleatorio alcanzó `0.9990`, detectando casi todos los casos positivos en su evaluación. El temporal alcanzó `0.7091`, identificando aproximadamente el 70.91 % de los casos positivos.
- **Accuracy:** el modelo aleatorio obtuvo `0.7923`, mientras que el temporal alcanzó `0.6493`. Esta métrica debe interpretarse considerando el desbalance de clases.
- **F1-score:** el modelo aleatorio alcanzó `0.8836` y el temporal `0.7615`, mostrando un mejor equilibrio entre precision y recall para la variante aleatoria en su evaluación.
- **Log loss:** el modelo aleatorio obtuvo un valor menor (`0.5028` frente a `0.6874`), indicando mejores resultados en esta métrica.
- **ROC-AUC:** ambos modelos obtuvieron valores cercanos a `0.61`, lo que indica una capacidad limitada para distinguir entre viajes con propina alta y baja.

![alt text](<../Images/ml-modelos/M2/Captura de Pantalla 2026-10-27 a la(s) 02.17.21.png>)

![alt text](<../Images/ml-modelos/M2/Captura de Pantalla 2026-10-27 a la(s) 02.18.47.png>)

### Conclusión de la evaluación

El modelo aleatorio presenta mejores resultados en recall, accuracy, F1-score, log loss y ROC-AUC, mientras que el temporal obtiene una precision superior.

Sin embargo, el ROC-AUC cercano a `0.61` en ambos casos indica que la capacidad de discriminación de los modelos es limitada. Por ello, las métricas no permiten afirmar que alguno tenga una capacidad predictiva alta.

Además, las métricas corresponden a conjuntos de evaluación diferentes, por lo que la comparación debe considerar las distintas estrategias de división de los datos.

---

## 3. Información del entrenamiento

Se consultó `ML.TRAINING_INFO` para analizar la evolución de las pérdidas del modelo temporal.

| Iteración | Loss | Eval loss | Learning rate | Duración |
|---|---:|---:|---:|---:|
| 0 | 0.6893 | 0.6906 | 0.2 | 4088 ms |
| 1 | 0.6840 | 0.6874 | 0.4 | 6440 ms |

### Interpretación

- La pérdida de entrenamiento disminuyó de `0.6893` a `0.6840`.
- La pérdida de evaluación disminuyó de `0.6906` a `0.6874`.
- Ambas pérdidas descendieron ligeramente, lo que indica una mejora durante las iteraciones registradas.
- La diferencia entre la pérdida de entrenamiento y la de evaluación se mantuvo pequeña.

El entrenamiento registró únicamente dos iteraciones, por lo que todavía no es posible establecer una tendencia completa de convergencia ni asegurar que el modelo haya alcanzado su mejor rendimiento.

---

## 4. Matriz de confusión

La matriz de confusión obtenida para el modelo temporal fue la siguiente:

| Clase real | Predicción: 0 | Predicción: 1 |
|---|---:|---:|
| 0: Propina no alta | 12,139 | 16,430 |
| 1: Propina alta | 31,138 | 75,920 |

### Interpretación

- **Verdaderos negativos (12,139):** viajes sin propina alta clasificados correctamente.
- **Falsos positivos (16,430):** viajes sin propina alta clasificados incorrectamente como positivos.
- **Falsos negativos (31,138):** viajes con propina alta que el modelo no detectó.
- **Verdaderos positivos (75,920):** viajes con propina alta clasificados correctamente.

La matriz muestra que el modelo identifica numerosos casos positivos, pero también presenta una cantidad considerable de falsos negativos y falsos positivos.

Esto concuerda con el recall de `0.7091` y la precision de `0.8221`: el modelo detecta una parte importante de las propinas altas y, cuando predice esa clase, suele acertar; sin embargo, todavía deja escapar varios casos positivos.

---

## 5. Importancia de las estrategias utilizadas

### Ponderación automática de clases

La opción `AUTO_CLASS_WEIGHTS = TRUE` busca compensar el desbalance entre las clases durante el entrenamiento. Esto resulta relevante cuando una categoría aparece con mayor frecuencia que la otra.

### Regularización L2

La opción `L2_REG = 0.1` penaliza coeficientes excesivamente grandes y ayuda a reducir el sobreajuste.

### Prevención de data leakage

La separación temporal utiliza meses anteriores para entrenar y un mes posterior para evaluar. Esto evita incorporar información de octubre al entrenamiento y proporciona una evaluación más cercana al escenario de predicción futura.

---

## Conclusión general

Los modelos de regresión logística se entrenaron para identificar viajes con propinas iguales o superiores al 20 % de la tarifa base.

El modelo aleatorio obtuvo un F1-score de `0.8836` y un recall de `0.9990`, mientras que el modelo temporal obtuvo una precision de `0.8221` y un recall de `0.7091`. Ambos presentaron un ROC-AUC cercano a `0.61`, lo que evidencia una capacidad limitada para distinguir entre las dos clases.

Por tanto, **no existe un ganador absoluto en todas las métricas**. El modelo aleatorio destaca en varias métricas generales de clasificación, mientras que el temporal ofrece una evaluación temporal más realista. La elección final debe considerar si se prioriza el rendimiento observado o la capacidad de generalizar a períodos futuros.



## 8. Modelos de BigQuery ML

### 8.1 Variables de entrada, salida y objetivo

| Característica | Modelo 1: Regresión lineal | Modelo 2: Regresión logística |
|---|---|---|
| **Objetivo (label)** | `fare_amount` | `tip_alta` (1 si la propina es ≥ 20 % de `fare_amount`) |
| **Entradas** | `trip_distance`, `trip_duration_min`, `pickup_hour`, `pickup_dow`, `passenger_count`, `pickup_location_id`, `dropoff_location_id`, `rate_code`, `is_weekend`, `is_rush_hour` | Variables del Modelo 1, más `fare_amount` y `fare_per_mile` |
| **Población** | Todos los viajes limpios | Viajes pagados con tarjeta (`payment_type = '1'`) |
| **Variables excluidas** | `total_amount`, `tip_amount`, `tolls_amount`, `extra`, `mta_tax`, `imp_surcharge`, `airport_fee`, `fare_per_mile` | `tip_amount`, `tip_pct`, `total_amount`, `payment_type` |

Las variables `pickup_hour` y `pickup_dow` se convierten a tipo `STRING` para tratarlas como variables categóricas y evitar interpretarlas como valores ordinales.

**Decisión sobre `trip_duration_min`:** esta variable se conoce al finalizar el viaje. Su uso presupone que la duración puede estimarse antes de realizar la predicción. Si no se dispone de esa estimación, conviene entrenar una variante sin esta variable y comparar sus resultados.

![alt text](<../Images/ml-modelos/comparacion_modelos/Captura de Pantalla 2026-10-27 a la(s) 02.59.33.png>)



### 8.2 Prevención de *data leakage*

1. **Fuga por variables:** se excluyen las variables que contienen información posterior al cobro o que se derivan directamente de la variable objetivo.
2. **Fuga temporal:** los modelos temporales se entrenan con datos de enero a septiembre, utilizan octubre para evaluación y reservan noviembre como conjunto de prueba (`TEST`).
3. **División aleatoria:** los modelos `m1_lin_random` y `m2_log_random` utilizan una división aleatoria del 80 % para entrenamiento y 20 % para evaluación. Esta estrategia puede mezclar fechas y sirve como punto de comparación.
4. **Comparación:** los cuatro modelos se evalúan sobre el conjunto `TEST`, según los resultados de `08_comparacion_modelos.sql`.

### 8.3 Variantes e hiperparámetros

| Modelo | División de datos | Hiperparámetros |
|---|---|---|
| `m1_lin_random` | Aleatoria, 80/20 | `MAX_ITERATIONS = 20`, sin regularización explícita |
| `m1_lin_temporal` | Personalizada, temporal | `L2_REG = 0.1`, `MAX_ITERATIONS = 30` |
| `m2_log_random` | Aleatoria, 80/20 | `MAX_ITERATIONS = 20`, sin ponderación automática de clases |
| `m2_log_temporal` | Personalizada, temporal | `AUTO_CLASS_WEIGHTS = TRUE`, `L2_REG = 0.1`, `MAX_ITERATIONS = 30` |

### 8.4 Resultados sobre TEST

#### Regresión lineal

Las métricas obtenidas para predecir `fare_amount` fueron:

| Modelo | Configuración | RMSE | MAE | R² |
|---|---|---:|---:|---:|
| `baseline_promedio` | Predice el promedio de `fare_amount` del entrenamiento | 13.0730 | 8.3699 | N/D |
| `m1_lin_random` | Aleatorio 80/20, 20 iteraciones | 52.7031 | 1.1747 | -15.2912 |
| `m1_lin_temporal` | Temporal, L2 = 0.1, 30 iteraciones | 2.7590 | 0.9823 | 0.9554 |

![alt text](<../Images/ml-modelos/comparacion_modelos/rmse, mae, r2_score por modelo.png>)

**Interpretación:**

- El modelo `m1_lin_temporal` obtuvo el menor RMSE y MAE, con valores de `2.7590` y `0.9823`, respectivamente.
- Su R² de `0.9554` indica que explica aproximadamente el 95.54 % de la variabilidad de `fare_amount` en el conjunto de prueba.
- Frente al baseline, el RMSE se redujo aproximadamente un **78.89 %**, de `13.0730` a `2.7590`.
- El modelo `m1_lin_random` obtuvo un R² negativo y un RMSE de `52.7031`, lo que indica un desempeño deficiente en el conjunto de prueba.

El R² del baseline se muestra como no disponible porque no se proporcionó un valor calculado para esa métrica.

**Modelo seleccionado:** `m1_lin_temporal`, debido a su menor error de predicción y su mayor capacidad explicativa en `TEST`.

#### Regresión logística

Las métricas obtenidas para clasificar `tip_alta` fueron:

| Modelo | Precisión | Recall | F1-score | Accuracy | Log loss | ROC-AUC |
|---|---:|---:|---:|---:|---:|---:|
| `m2_log_random` | 0.7967 | 0.9987 | 0.8864 | 0.7967 | 0.4969 | 0.6115 |
| `m2_log_temporal` | 0.8256 | 0.7172 | 0.7676 | 0.6553 | 0.6864 | 0.6110 |

**Interpretación:**

- `m2_log_random` obtuvo el mayor recall (`0.9987`) y F1-score (`0.8864`), además de mayor accuracy y menor log loss.
- `m2_log_temporal` alcanzó una precisión de `0.8256`, superior a la del modelo aleatorio (`0.7967`). Esto significa que sus predicciones positivas fueron más precisas.
- Ambos modelos obtuvieron un ROC-AUC cercano a `0.61`, lo que indica una capacidad limitada para distinguir entre las clases.
- El modelo aleatorio detecta casi todos los positivos, pero esto no implica una buena discriminación general. El modelo temporal sacrifica recall y accuracy, aunque ofrece una evaluación basada en una separación temporal.

**Modelo seleccionado:** para un escenario de predicción futura, se prefiere `m2_log_temporal` por su estrategia de evaluación temporal y su mayor precisión. Sin embargo, su F1-score y ROC-AUC muestran que todavía existen oportunidades importantes de mejora. Si la prioridad fuera maximizar el recall y el F1-score en las evaluaciones realizadas, `m2_log_random` sería superior.

#### Matrices de confusión

Las matrices se obtuvieron con un umbral de clasificación de `0.5`.

**Modelo `m2_log_random`:**

| Clase real | Predicción 0 | Predicción 1 |
|---|---:|---:|
| 0: Propina no alta | 484 | 24,418 |
| 1: Propina alta | 127 | 95,713 |

![alt text](<../Images/ml-modelos/comparacion_modelos/Captura de Pantalla 2026-10-27 a la(s) 02.44.11.png>)

**Modelo `m2_log_temporal`:**

| Clase real | Predicción 0 | Predicción 1 |
|---|---:|---:|
| 0: Propina no alta | 10,378 | 14,524 |
| 1: Propina alta | 27,101 | 68,739 |

![alt text](<../Images/ml-modelos/comparacion_modelos/Captura de Pantalla 2026-10-27 a la(s) 02.46.30.png>)

**Interpretación:**

- El modelo aleatorio clasifica casi todos los viajes como positivos, lo que explica su recall elevado y la cantidad considerable de falsos positivos.
- El modelo temporal identifica correctamente `68,739` casos positivos, pero deja sin detectar `27,101`.
- Las matrices respaldan la necesidad de evaluar precision, recall y F1-score en conjunto, en lugar de seleccionar un modelo únicamente por accuracy.

![alt text](<../Images/ml-modelos/comparacion_modelos/precision, recall, accuracy, f1_score, log_loss por modelo(1).png>)

### 8.5 Rolling Forecast

Se utiliza un proceso de predicción diaria para noviembre, un período posterior al utilizado en el entrenamiento temporal.

Los resultados se almacenan en las tablas o vistas destinadas al dashboard:

- `dash_rolling_fare`: comparación entre las tarifas reales y las predichas.
- `dash_rolling_tip`: resultados de clasificación de propinas altas.

**Objetivo:** visualizar el comportamiento de las predicciones a lo largo del tiempo y analizar si los modelos mantienen un rendimiento consistente en datos futuros.

La evaluación debe comparar las predicciones con los valores reales de noviembre mediante métricas apropiadas para cada tarea: RMSE y MAE para regresión; precision, recall, F1-score y ROC-AUC para clasificación, cuando estén disponibles.


### Conclusión general

Los resultados de `TEST` muestran que **`m1_lin_temporal` es la mejor variante para la regresión lineal**, con un RMSE de `2.7590`, un MAE de `0.9823` y un R² de `0.9554`. Además, reduce el RMSE aproximadamente un 78.89 % respecto al baseline.

Para la clasificación, `m2_log_random` obtiene mejores resultados en F1-score, recall, accuracy y log loss, mientras que `m2_log_temporal` alcanza una precisión mayor y representa mejor el escenario de predicción sobre períodos futuros. Ambos presentan un ROC-AUC cercano a `0.61`, por lo que su capacidad discriminativa sigue siendo limitada.

La selección final debe considerar el objetivo de cada modelo y el contexto de uso: minimizar el error de las tarifas futuras en regresión y detectar correctamente las propinas altas en clasificación, manteniendo una evaluación temporal que evite utilizar información del futuro durante el entrenamiento.






















# 9. Predicciones sobre nuevos registros y Rolling Forecast

## 9.1 Objetivo

El archivo `09_predicciones_nuevos_registros.sql` permite utilizar los cuatro modelos entrenados en BigQuery ML para generar predicciones sobre registros del conjunto `TEST` y sobre viajes definidos manualmente.

El script cumple tres objetivos principales:

1. Predecir las tarifas de los viajes de noviembre mediante los modelos de regresión lineal.
2. Clasificar los viajes según la probabilidad de recibir una propina alta mediante los modelos de regresión logística.
3. Generar tablas agregadas por día para comparar los resultados reales con las predicciones y visualizarlos en el dashboard.

Además, se realizan predicciones sobre nuevos viajes introducidos manualmente para demostrar que los modelos pueden utilizarse con datos distintos de los empleados durante el entrenamiento.

## 9.2 Predicción de tarifas sobre noviembre

### Consulta utilizada

La primera sección utiliza `ML.PREDICT` para generar predicciones de `fare_amount` con los modelos:

- `m1_lin_random`
- `m1_lin_temporal`

Los resultados se almacenan en la tabla `pred_fare_test`.

![alt text](<../Images/ml-modelos/predic/Captura de Pantalla 2026-10-27 a la(s) 03.03.00.png>)

```sql
CREATE OR REPLACE TABLE
  `ID_Proyecto_GCP.nyc_taxi_2022.pred_fare_test` AS

SELECT
  'm1_lin_random' AS modelo,
  pickup_datetime,
  pickup_date,
  fare_amount AS fare_real,
  predicted_fare_amount AS fare_predicho,
  predicted_fare_amount - fare_amount AS error
FROM ML.PREDICT(
  MODEL `ID_Proyecto_GCP.nyc_taxi_2022.m1_lin_random`,
  (
    SELECT *
    FROM `ID_Proyecto_GCP.nyc_taxi_2022.ml_features`
    WHERE split_set = 'TEST'
  )
)

UNION ALL

SELECT
  'm1_lin_temporal',
  pickup_datetime,
  pickup_date,
  fare_amount,
  predicted_fare_amount,
  predicted_fare_amount - fare_amount
FROM ML.PREDICT(
  MODEL `ID_Proyecto_GCP.nyc_taxi_2022.m1_lin_temporal`,
  (
    SELECT *
    FROM `ID_Proyecto_GCP.nyc_taxi_2022.ml_features`
    WHERE split_set = 'TEST'
  )
);
```
![alt text](<../Images/ml-modelos/predic/Captura de Pantalla 2026-10-27 a la(s) 03.04.53.png>)

### Funcionamiento

1. Se seleccionan los registros identificados como `TEST` en `ml_features`.
2. Se ejecuta `ML.PREDICT` con cada modelo de regresión.
3. Se conserva la tarifa real (`fare_real`) y se obtiene la tarifa estimada (`fare_predicho`).
4. Se calcula el error mediante la diferencia entre la predicción y el valor real.
5. Se combinan los resultados de ambos modelos mediante `UNION ALL`.

La columna `modelo` permite identificar qué modelo generó cada predicción.

### Estructura de la tabla generada

| Campo | Descripción |
|---|---|
| `modelo` | Modelo utilizado para la predicción. |
| `pickup_datetime` | Fecha y hora de recogida. |
| `pickup_date` | Fecha del viaje. |
| `fare_real` | Tarifa registrada en los datos originales. |
| `fare_predicho` | Tarifa estimada por el modelo. |
| `error` | Diferencia entre la tarifa predicha y la real. |

El error se calcula de la siguiente manera:

\[
error = fare\_predicho - fare\_real
\]

- Un error positivo indica que el modelo sobreestimó la tarifa.
- Un error negativo indica que el modelo subestimó la tarifa.
- Un error cercano a cero indica una predicción cercana al valor real.

**Resultado esperado:** una tabla que permite comparar las predicciones de ambos modelos para cada viaje del conjunto `TEST`.

**Consideración:** aunque el script identifica `TEST` como noviembre, esto depende de que la columna `split_set` se haya asignado correctamente durante la preparación de los datos. La consulta, por sí sola, filtra por `split_set = 'TEST'`, no por el mes.

---

## 9.3 Predicción de propina alta sobre noviembre

### Objetivo

La segunda sección utiliza los modelos de regresión logística para clasificar los viajes según la variable objetivo `tip_alta`.

La clasificación es binaria:

- `1`: el viaje tiene una propina igual o superior al 20 % de `fare_amount`.
- `0`: el viaje no alcanza ese umbral.

Se utilizan los modelos `m2_log_random` y `m2_log_temporal`.

### Funcionamiento

El script ejecuta `ML.PREDICT` para cada modelo, utilizando registros que cumplen las siguientes condiciones:

```sql
WHERE split_set = 'TEST'
  AND payment_type = '1'
  AND tip_alta IS NOT NULL
```

Estas condiciones garantizan que se utilicen registros del conjunto de prueba, viajes pagados con tarjeta y observaciones cuya clase real esté disponible para evaluar los resultados.

Además de la clase predicha, se extrae la probabilidad asociada a la clase `1`:

```sql
(
  SELECT p.prob
  FROM UNNEST(predicted_tip_alta_probs) AS p
  WHERE p.label = 1
) AS prob_propina_alta
```

La función `UNNEST` permite acceder a las probabilidades almacenadas en el arreglo `predicted_tip_alta_probs` y seleccionar específicamente la correspondiente a la clase positiva.

Los resultados se almacenan en `pred_tip_test`.

![alt text](<../Images/ml-modelos/predic/Captura de Pantalla 2026-10-27 a la(s) 03.06.04.png>)

### Estructura de la tabla generada

| Campo | Descripción |
|---|---|
| `modelo` | Modelo de clasificación utilizado. |
| `pickup_datetime` | Fecha y hora de recogida. |
| `pickup_date` | Fecha del viaje. |
| `tip_real` | Clase real de propina alta. |
| `tip_predicho` | Clase estimada por el modelo. |
| `prob_propina_alta` | Probabilidad estimada de que el viaje pertenezca a la clase `1`. |

![alt text](<../Images/ml-modelos/predic/Captura de Pantalla 2026-10-27 a la(s) 03.06.59.png>)

### Interpretación

La clase predicha y su probabilidad representan información diferente.

Por ejemplo, un viaje puede tener una probabilidad de propina alta de `0.49` y clasificarse como `0` cuando el umbral de decisión es `0.5`.

La probabilidad permite analizar qué tan cerca está una predicción del umbral utilizado para clasificar el viaje.

**Resultado esperado:** una tabla con las clases reales, las clases predichas y las probabilidades estimadas por ambos modelos de clasificación.

---

## 9.4 Rolling Forecast de tarifas

### Objetivo

El Rolling Forecast permite observar el comportamiento de las predicciones a lo largo del tiempo, agrupando los resultados por día.

Para las tarifas, se genera la tabla `dash_rolling_fare`.

### Consulta utilizada

```sql
CREATE OR REPLACE TABLE
  `ID_Proyecto_GCP.nyc_taxi_2022.dash_rolling_fare` AS

SELECT
  modelo,
  pickup_date AS fecha,
  COUNT(*) AS viajes,
  ROUND(AVG(fare_real), 2) AS fare_real_prom,
  ROUND(AVG(fare_predicho), 2) AS fare_predicho_prom,
  ROUND(SQRT(AVG(POW(error, 2))), 2) AS rmse_dia
FROM `ID_Proyecto_GCP.nyc_taxi_2022.pred_fare_test`
GROUP BY modelo, fecha
ORDER BY fecha, modelo;
```
![alt text](<../Images/ml-modelos/predic/Captura de Pantalla 2026-10-27 a la(s) 03.08.55.png>) 

![alt text](<../Images/ml-modelos/predic/Captura de Pantalla 2026-10-27 a la(s) 03.09.21.png>)


### Funcionamiento

La consulta agrupa los viajes por modelo y fecha. Para cada grupo calcula:

- **`viajes`:** cantidad de registros utilizados ese día.
- **`fare_real_prom`:** promedio de las tarifas reales.
- **`fare_predicho_prom`:** promedio de las tarifas predichas.
- **`rmse_dia`:** raíz del promedio de los errores al cuadrado para ese día.

El RMSE diario se calcula mediante:

\[
RMSE_d = \sqrt{\frac{1}{n}\sum_{i=1}^{n}
(\hat{y}_i-y_i)^2}
\]

Donde:

- \(n\) representa la cantidad de viajes del día.
- \(\hat{y}_i\) es la tarifa predicha.
- \(y_i\) es la tarifa real.

### Interpretación

La tabla permite identificar los días en los que el modelo presenta errores más elevados y comparar la tarifa promedio predicha con la tarifa promedio real.

Un RMSE diario bajo indica que las predicciones estuvieron relativamente cerca de los valores reales durante ese día. Un RMSE alto indica que hubo errores más grandes, aunque el resultado también depende de la distribución de los viajes y de la presencia de valores extremos.

**Aplicación en el dashboard:** se pueden representar las tarifas promedio reales y predichas como series de tiempo, y utilizar el RMSE diario para observar las variaciones del error.

---

## 9.5 Rolling Forecast de propinas

### Objetivo

Para el modelo de clasificación se genera la tabla `dash_rolling_tip`, que resume diariamente las clases reales, las clases predichas y las probabilidades de propina alta.

### Consulta utilizada

```sql
CREATE OR REPLACE TABLE
  `ID_Proyecto_GCP.nyc_taxi_2022.dash_rolling_tip` AS

SELECT
  modelo,
  pickup_date AS fecha,
  COUNT(*) AS viajes,
  ROUND(AVG(tip_real), 3) AS tasa_real_propina_alta,
  ROUND(AVG(tip_predicho), 3) AS tasa_predicha_propina_alta,
  ROUND(AVG(prob_propina_alta), 3) AS prob_promedio
FROM `ID_Proyecto_GCP.nyc_taxi_2022.pred_tip_test`
GROUP BY modelo, fecha
ORDER BY fecha, modelo;
```



### Funcionamiento

Para cada modelo y día se calculan tres indicadores principales:

- **`tasa_real_propina_alta`:** proporción de viajes que realmente tuvieron una propina alta.
- **`tasa_predicha_propina_alta`:** proporción de viajes que el modelo clasificó como propina alta.
- **`prob_promedio`:** promedio de las probabilidades estimadas de pertenecer a la clase positiva.

Las tasas se calculan mediante promedios porque las variables `tip_real` y `tip_predicho` están representadas por valores binarios de `0` y `1`.

Por ejemplo, una tasa real de `0.65` indica que el 65 % de los viajes considerados ese día perteneció a la clase de propina alta.

### Interpretación

Comparar la tasa real con la tasa predicha permite observar si el modelo tiende a identificar una proporción de viajes con propina alta similar a la observada.

Si ambas tasas presentan valores próximos, el modelo está estimando una frecuencia similar de la clase positiva. Sin embargo, esto no demuestra por sí solo que clasifique correctamente cada viaje.

La probabilidad promedio complementa el análisis porque muestra el nivel promedio de probabilidad que el modelo asigna a la clase positiva.

**Aplicación en el dashboard:** se pueden representar las tasas reales y predichas como líneas temporales y comparar el comportamiento de ambos modelos de clasificación.

---

## 9.6 Predicciones sobre viajes nuevos definidos manualmente

Además de predecir sobre el conjunto `TEST`, el script incluye registros construidos manualmente para demostrar que los modelos pueden recibir nuevas observaciones y generar resultados.

Estos registros no representan resultados históricos recuperados de la tabla original: son ejemplos de entrada definidos directamente en SQL.

### 9.6.1 Predicción de tarifa

Se utiliza el modelo `m1_lin_temporal` para estimar la tarifa de tres viajes.

Los registros incluyen distancia, duración, hora, día de la semana, cantidad de pasajeros, zonas de recogida y destino, código de tarifa e indicadores de fin de semana y hora pico.

### Resultados obtenidos

| Viaje | Distancia | Duración (min) | Hora | Día (`pickup_dow`) | Pasajeros | Tarifa predicha |
|---|---:|---:|---|---|---:|---:|
| 1 | 5.2 | 22 | 18 | 6 | 1 | $19.12 |
| 2 | 17.5 | 45 | 14 | 1 | 2 | $49.54 |
| 3 | 1.1 | 8 | 9 | 3 | 1 | $7.34 |

Los valores de tarifa se presentan redondeados a dos decimales.

![alt text](<../Images/ml-modelos/predic/Captura de Pantalla 2026-10-27 a la(s) 03.11.49.png>)

![alt text](<../Images/ml-modelos/predic/trip_distance, trip_duration_min, passenger_count, is_weekend, is_rush_hour por predicted_fare_amount.png>)

### Interpretación

- **Viaje 1:** para una distancia de 5.2 unidades y una duración de 22 minutos, el modelo estima una tarifa de aproximadamente $19.12.
- **Viaje 2:** para una distancia de 17.5 unidades y una duración de 45 minutos, la tarifa estimada es de aproximadamente $49.54.
- **Viaje 3:** para un recorrido corto de 1.1 unidades y 8 minutos, el modelo estima una tarifa de aproximadamente $7.34.

Los resultados muestran que el modelo puede recibir nuevos registros y producir estimaciones sin necesitar que la tarifa real esté incluida en los datos de entrada.

Las tarifas son predicciones del modelo, no valores garantizados ni cotizaciones oficiales. Su precisión dependerá de la calidad de los datos y de qué tan similares sean los viajes nuevos a los utilizados para entrenarlo.

**Nota sobre los datos:** el segundo registro utiliza `pickup_dow = '1'` junto con `is_weekend = 1`. Conviene verificar que ambos campos sean coherentes con la codificación del día de la semana utilizada en el proyecto.

---

## 9.7 Predicciones manuales de propina alta

Para demostrar el funcionamiento del modelo de clasificación, se utiliza `m2_log_temporal` con dos viajes definidos manualmente.

A diferencia de la predicción de tarifas, este modelo recibe también `fare_amount` y `fare_per_mile` como variables de entrada.

### Resultados obtenidos

| Viaje | Tarifa ($) | Distancia | Duración (min) | Probabilidad de propina alta | Clase predicha |
|---|---:|---:|---:|---:|---:|
| 1 | 22.00 | 5.5 | 24 | 49.52 % | 0 |
| 2 | 70.00 | 17.0 | 50 | 38.19 % | 0 |

![alt text](<../Images/ml-modelos/predic/Captura de Pantalla 2026-10-27 a la(s) 03.12.09.png>)

### Interpretación

**Viaje 1**

El modelo estima una probabilidad de propina alta de `0.4952`, equivalente aproximadamente al 49.52 %. Como esta probabilidad es inferior al umbral de decisión de `0.5`, la clase predicha es `0`.

**Viaje 2**

El modelo estima una probabilidad de propina alta de `0.3819`, equivalente aproximadamente al 38.19 %. Al ser inferior a `0.5`, el modelo también clasifica este viaje como `0`.


![alt text](<../Images/ml-modelos/predic/trip_distance por prob_propina_alta.png>)

### Consideraciones

- La clase `0` significa que el modelo no identifica una propina alta según el umbral de clasificación; no significa que el viaje no vaya a recibir propina.
- El primer viaje presenta una probabilidad cercana al umbral de `0.5`, por lo que su clasificación podría cambiar si se utiliza otro umbral.
- Las probabilidades estimadas no son garantías de que el resultado real vaya a coincidir con la predicción.

Estos ejemplos demuestran que el modelo puede generar una clasificación y una probabilidad para registros nuevos, incluso cuando todavía no se conoce la propina real.

---

## 9.8 Tablas generadas y su uso en el dashboard

El script crea cuatro tablas principales para almacenar las predicciones y facilitar su análisis.

| Tabla | Contenido | Uso |
|---|---|---|
| `pred_fare_test` | Tarifas reales, predichas y errores individuales | Comparación de predicciones de regresión. |
| `pred_tip_test` | Clases reales, clases predichas y probabilidades | Análisis de clasificación de propinas. |
| `dash_rolling_fare` | Métricas diarias de tarifas | Gráficas temporales de tarifas reales, predichas y RMSE. |
| `dash_rolling_tip` | Tasas diarias reales y predichas de propina alta | Gráficas temporales de clasificación y probabilidades. |

Las dos primeras tablas conservan el detalle por viaje. Las dos últimas contienen datos agregados por día y modelo, lo que facilita la construcción de visualizaciones.

### Visualizaciones recomendadas

**Para `dash_rolling_fare`:**

- Gráfica de líneas con la tarifa real promedio y la tarifa predicha promedio.
- Gráfica de líneas o barras para comparar el RMSE diario entre modelos.
- Indicador del número de viajes evaluados por día.

**Para `dash_rolling_tip`:**

- Gráfica de líneas para comparar la tasa real y la tasa predicha de propina alta.
- Gráfica de la probabilidad promedio de propina alta.
- Comparación entre los modelos aleatorio y temporal.


![alt text](<../Images/dashboad/Captura de Pantalla 2026-10-27 a la(s) 17.09.38.png>)


---

## 9.9 Consideraciones sobre las predicciones y el Rolling Forecast

1. **Separación temporal:** el uso de `TEST` permite evaluar los modelos con registros reservados, siempre que la asignación temporal de los datos se haya realizado correctamente.
2. **Valores reales disponibles:** las consultas de evaluación utilizan `fare_amount` y `tip_alta` para comparar las predicciones con los resultados observados. En una predicción operativa futura, esos valores podrían no estar disponibles todavía.
3. **Error de regresión:** el error se define como predicción menos valor real. Su signo permite identificar sobreestimaciones y subestimaciones.
4. **Umbral de clasificación:** la clase predicha depende del umbral de decisión utilizado. En las matrices de confusión del proyecto se utiliza `0.5`.
5. **Agregación diaria:** las tasas y los promedios diarios resumen el comportamiento general, pero no reemplazan las métricas de evaluación calculadas sobre todos los registros.
6. **Interpretación del Rolling Forecast:** en este script se agrupan predicciones de un conjunto de prueba por día. No se observa un reentrenamiento diario de los modelos; por tanto, se trata de un seguimiento diario de predicciones, no de un proceso de reentrenamiento móvil.

**Importante:** aunque el comentario del script se refiere a noviembre como período de prueba, debe verificarse que `split_set = 'TEST'` corresponda efectivamente a noviembre. También conviene verificar que las variables de entrada disponibles en producción puedan calcularse sin utilizar información futura.

---

## 9.10 Conclusión

El archivo `09_predicciones_nuevos_registros.sql` conecta los modelos entrenados con su aplicación práctica. Mediante `ML.PREDICT`, genera predicciones individuales de tarifas y clasificaciones de propinas altas, tanto para registros de prueba como para viajes definidos manualmente.

Las tablas `pred_fare_test` y `pred_tip_test` almacenan los resultados detallados, mientras que `dash_rolling_fare` y `dash_rolling_tip` resumen las predicciones por día para su visualización en el dashboard.

Las pruebas manuales produjeron tarifas estimadas de $19.12, $49.54 y $7.34. En clasificación, los dos viajes evaluados obtuvieron probabilidades de propina alta de aproximadamente 49.52 % y 38.19 %, y ambos fueron clasificados como clase `0` con un umbral de `0.5`.

En conjunto, el script demuestra cómo aplicar los modelos a nuevos registros, comparar las estimaciones con los valores reales y preparar resultados para analizar su comportamiento a lo largo del tiempo.
