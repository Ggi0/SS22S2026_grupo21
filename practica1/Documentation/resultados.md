# Documentación Técnica — Consultas Analíticas VuelosBI

## 1. Introducción

Este documento describe las consultas SQL analíticas desarrolladas contra el modelo dimensional
de VuelosBI, ubicadas en `BaseDatos/Consultas/`. Su propósito es doble: validar que el proceso
ETL cargó correctamente la información en SQL Server, y generar indicadores de negocio relevantes
a partir del modelo en estrella.

```
BaseDatos/Consultas/
├── 01_validacion_conteos_generales.sql
├── 02_top5_destinos_frecuentes.sql
├── 03_distribucion_genero.sql
├── 04_retraso_promedio_por_aerolinea.sql
├── 05_ingresos_por_canal_y_pago.sql
├── 06_tasa_cancelacion_por_aerolinea.sql
├── 07_top5_nacionalidades_pasajeros.sql
├── 08_tendencia_mensual_vuelos.sql
└── 09_top10_rutas_mas_rentables.sql
```

Los resultados que se documentan a continuación corresponden a una ejecución de referencia
contra la base de datos ya cargada con los 10,000 registros del archivo fuente.

## 2. Consulta 1 — Validación de conteos generales

**Objetivo:** confirmar que el proceso ETL cargó la cantidad esperada de registros en la tabla de
hechos y en cada dimensión, y que no existan filas con claves foráneas nulas. Es la primera
validación que debe ejecutarse después de correr `load.py`.

**Resultado:**

| Tabla | Total de registros |
|---|---|
| `Fact_Vuelos` | 10,000 |
| `Dim_Aerolinea` | 12 |
| `Dim_Aeropuerto` | 15 |
| `Dim_Aeronave` | 12 |
| `Dim_Pasajero` | 10,000 |
| `Dim_ClaseCabina` | 4 |
| `Dim_CanalVenta` | 6 |
| `Dim_MetodoPago` | 5 |
| `Dim_EstadoVuelo` | 4 |
| `Dim_Fecha` | 861 |

Filas con clave foránea nula en `Fact_Vuelos`: **0**.

**Interpretación:** las 10,000 filas del archivo fuente se cargaron íntegramente en la tabla de
hechos, sin pérdida de registros y sin inconsistencias de integridad referencial. La cardinalidad
de cada dimensión es consistente con la diversidad real de valores categóricos presentes en los
datos (por ejemplo, `Dim_CanalVenta` tiene 6 valores: los 5 canales originales del negocio más la
categoría `SIN_DATO`, utilizada para homologar los registros donde el canal de venta llegó vacío
en el archivo fuente).

## 3. Consulta 2 — Top 5 destinos más frecuentes

**Objetivo:** identificar los aeropuertos de destino con mayor cantidad de vuelos vendidos.

**Resultado:**

| Destino | Ciudad | País | Total de vuelos |
|---|---|---|---|
| SAP | San Pedro Sula | Honduras | 701 |
| CUN | Cancún | México | 699 |
| BOG | Bogotá | Colombia | 696 |
| BCN | Barcelona | España | 696 |
| HAV | La Habana | Cuba | 693 |

**Interpretación:** la distribución de vuelos por destino es relativamente uniforme entre los
principales aeropuertos, sin un destino que concentre una proporción desproporcionada del total,
lo que es consistente con la naturaleza sintética y balanceada del conjunto de datos.

## 4. Consulta 3 — Distribución de vuelos por género del pasajero

**Objetivo:** conocer la composición demográfica de los pasajeros por género.

**Resultado:**

| Género | Total de vuelos | Porcentaje |
|---|---|---|
| M | 4,912 | 49.12% |
| F | 4,698 | 46.98% |
| X | 390 | 3.90% |

**Interpretación:** la distribución está mayoritariamente equilibrada entre los géneros `M` y
`F`. La categoría `X` agrupa tanto los valores explícitamente no binarios del CSV fuente como
cualquier valor de género no reconocido durante la homologación (ver documento de documentación
del ETL, sección de tratamiento de datos).

## 5. Consulta 4 — Retraso promedio y máximo por aerolínea

**Objetivo:** identificar qué aerolíneas presentan mayores problemas de puntualidad. Solo
considera vuelos que efectivamente operaron (excluye `CANCELLED`, que no tienen `retraso_min`).

**Resultado:**

| Aerolínea | Vuelos operados | Vuelos retrasados | Retraso promedio (min) | Retraso máximo (min) |
|---|---|---|---|---|
| Ryanair | 804 | 172 | 29.4 | 239 |
| Southwest | 821 | 184 | 28.2 | 240 |
| Iberia | 825 | 185 | 27.0 | 239 |
| Aeromexico | 729 | 151 | 26.8 | 239 |
| United | 749 | 160 | 26.8 | 240 |
| LATAM | 757 | 155 | 26.7 | 239 |
| British Airways | 776 | 153 | 25.7 | 240 |
| Avianca | 775 | 162 | 25.6 | 235 |
| Copa Airlines | 830 | 167 | 25.1 | 240 |
| American Airlines | 776 | 166 | 24.5 | 240 |
| Delta | 779 | 160 | 23.8 | 239 |
| JetBlue | 819 | 155 | 23.3 | 238 |

**Interpretación:** Ryanair presenta el mayor retraso promedio (29.4 minutos), mientras que
JetBlue presenta el menor (23.3 minutos). El retraso máximo observado se encuentra en un rango
similar (235–240 minutos) en todas las aerolíneas, lo que sugiere un tope consistente en los
datos fuente más que una diferencia estructural entre aerolíneas.

## 6. Consulta 5 — Ingresos totales por canal de venta y método de pago

**Objetivo:** entender de dónde provienen los ingresos, para apoyar decisiones comerciales sobre
qué canal o método de pago priorizar.

**Resultado (resumen de los 5 canales/métodos con mayores ingresos, y la categoría `SIN_DATO`):**

| Canal de venta | Método de pago | Transacciones | Ingresos totales (USD) | Ticket promedio (USD) |
|---|---|---|---|---|
| CALL_CENTER | TARJETA | 394 | 33,327.94 | 84.59 |
| AGENCIA | TARJETA | 417 | 33,285.19 | 79.82 |
| CALL_CENTER | EFECTIVO | 406 | 33,131.39 | 81.60 |
| APP | PUNTOS | 398 | 33,118.62 | 83.21 |
| AEROPUERTO | PAYPAL | 406 | 33,057.64 | 81.42 |
| SIN_DATO | PUNTOS | 31 | 2,733.50 | 88.18 |
| SIN_DATO | TARJETA | 32 | 2,661.81 | 83.18 |
| SIN_DATO | TRANSFERENCIA | 27 | 2,090.96 | 77.44 |
| SIN_DATO | EFECTIVO | 31 | 1,884.90 | 60.80 |
| SIN_DATO | PAYPAL | 23 | 1,580.11 | 68.70 |

**Interpretación:** los ingresos están razonablemente distribuidos entre canales y métodos de
pago, sin una combinación dominante. Las combinaciones con canal `SIN_DATO` representan en
conjunto 144 transacciones (equivalentes a los 144 vuelos cuyo `sales_channel` llegó vacío en el
archivo fuente y fue homologado durante la transformación), con ingresos proporcionalmente
menores al resto por tratarse de un subconjunto más pequeño de registros.

## 7. Consulta 6 — Tasa de cancelación por aerolínea

**Objetivo:** indicador de calidad de servicio; porcentaje de vuelos cancelados sobre el total
vendido por cada aerolínea.

**Resultado:**

| Aerolínea | Vuelos vendidos | Vuelos cancelados | Tasa de cancelación |
|---|---|---|---|
| Avianca | 835 | 60 | 7.19% |
| Copa Airlines | 888 | 58 | 6.53% |
| British Airways | 829 | 53 | 6.39% |
| United | 797 | 48 | 6.02% |
| American Airlines | 824 | 48 | 5.83% |
| LATAM | 803 | 46 | 5.73% |
| Aeromexico | 772 | 43 | 5.57% |
| Ryanair | 850 | 46 | 5.41% |
| Southwest | 868 | 47 | 5.41% |
| Iberia | 867 | 42 | 4.84% |
| Delta | 814 | 35 | 4.30% |
| JetBlue | 853 | 34 | 3.99% |

**Interpretación:** Avianca presenta la tasa de cancelación más alta (7.19%), mientras que
JetBlue presenta la más baja (3.99%). Todas las aerolíneas se ubican en un rango relativamente
estrecho (entre 4% y 7.2%), sin valores atípicos que sugieran un problema operativo aislado en
alguna de ellas.

## 8. Consulta 7 — Top 5 nacionalidades de pasajeros

**Objetivo:** entender el perfil demográfico de los clientes por nacionalidad.

**Resultado:**

| Nacionalidad | Pasajeros únicos | Total de vuelos comprados |
|---|---|---|
| PA | 923 | 923 |
| US | 909 | 909 |
| MX | 908 | 908 |
| SV | 900 | 900 |
| ES | 899 | 899 |

**Interpretación:** al coincidir el número de pasajeros únicos con el total de vuelos comprados
para cada nacionalidad, se confirma que, dentro de este top 5, cada pasajero de estas
nacionalidades compró exactamente un vuelo en el conjunto de datos analizado, sin pasajeros
recurrentes destacados en las nacionalidades líderes.

## 9. Consulta 8 — Tendencia mensual de vuelos e ingresos

**Objetivo:** analizar la estacionalidad del negocio a lo largo del tiempo, utilizando la fecha
de salida del vuelo.

**Resultado:**

| Año | Mes | Total de vuelos | Ingresos (USD) |
|---|---|---|---|
| 2024 | Enero | 423 | 36,994.06 |
| 2024 | Febrero | 380 | 29,885.21 |
| 2024 | Marzo | 416 | 31,655.59 |
| 2024 | Abril | 420 | 29,700.08 |
| 2024 | Mayo | 402 | 30,694.57 |
| 2024 | Junio | 370 | 28,798.63 |
| 2024 | Julio | 404 | 31,192.90 |
| 2024 | Agosto | 428 | 36,729.57 |
| 2024 | Septiembre | 391 | 29,815.49 |
| 2024 | Octubre | 464 | 33,291.14 |
| 2024 | Noviembre | 389 | 32,405.70 |
| 2024 | Diciembre | 440 | 34,171.77 |
| 2025 | Enero | 421 | 32,539.74 |
| 2025 | Febrero | 402 | 31,139.86 |
| 2025 | Marzo | 397 | 30,391.92 |
| 2025 | Abril | 449 | 32,150.23 |
| 2025 | Mayo | 423 | 32,568.67 |
| 2025 | Junio | 459 | 34,245.38 |
| 2025 | Julio | 448 | 36,367.10 |
| 2025 | Agosto | 404 | 30,261.96 |
| 2025 | Septiembre | 391 | 27,832.64 |
| 2025 | Octubre | 411 | 31,157.24 |
| 2025 | Noviembre | 430 | 32,470.25 |
| 2025 | Diciembre | 438 | 33,565.01 |

**Interpretación:** el volumen mensual de vuelos se mantiene relativamente estable a lo largo de
los dos años analizados (entre 370 y 464 vuelos por mes), sin una estacionalidad marcada. Los
ingresos siguen un patrón similar al volumen de vuelos, con picos moderados en enero y agosto de
2024 y en julio de 2025.

## 10. Consulta 9 — Top 10 rutas más rentables

**Objetivo:** consulta analítica adicional que combina dos roles de la misma dimensión
(`Dim_Aeropuerto` como origen y como destino), demostrando el uso de dimensiones de rol múltiple
(*role-playing dimensions*) en el modelo en estrella.

**Resultado:**

| Ruta | Total de vuelos | Ingresos totales (USD) | Ticket promedio (USD) |
|---|---|---|---|
| MIA → HAV | 76 | 5,621.97 | 73.97 |
| HAV → PTY | 51 | 5,405.44 | 105.99 |
| MIA → GUA | 52 | 5,253.85 | 101.04 |
| MIA → SAP | 51 | 5,181.44 | 101.60 |
| HAV → BOG | 59 | 5,144.49 | 87.19 |
| HAV → GUA | 63 | 5,137.62 | 81.55 |
| SAL → CUN | 60 | 5,114.84 | 85.25 |
| BCN → MEX | 57 | 5,079.74 | 89.12 |
| SAL → LAX | 64 | 4,986.49 | 77.91 |
| CUN → BOG | 62 | 4,951.79 | 79.87 |

**Interpretación:** la ruta Miami–La Habana (MIA → HAV) concentra el mayor volumen de vuelos e
ingresos totales del top 10, aunque no el ticket promedio más alto. Las rutas con mayor ticket
promedio (HAV → PTY y MIA → SAP, ambas por encima de USD 100) sugieren tramos de mayor distancia
o de clase de cabina superior, mientras que las rutas con mayor volumen compensan un ticket
promedio menor con un número más alto de transacciones.

## 11. Conclusiones generales

El conjunto de nueve consultas analíticas cumple un doble propósito: las consultas 1 funcionan
como mecanismo de validación de integridad y completitud de la carga, mientras que las consultas
2 a 9 cubren los indicadores de negocio solicitados explícitamente en el enunciado de la práctica
(número de vuelos, destinos más frecuentes, distribución por género) y los complementan con
indicadores adicionales de puntualidad, cancelación, ingresos, demografía, estacionalidad y
rentabilidad por ruta, todos ellos derivados directamente del modelo dimensional en estrella
implementado en `BaseDatos/database.sql`.