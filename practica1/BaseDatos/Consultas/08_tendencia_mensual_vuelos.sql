/* ============================================================================
   Consulta 8: Tendencia mensual de vuelos e ingresos
   Objetivo: analizar estacionalidad del negocio a lo largo del tiempo,
   usando la dimension de fecha (fecha de salida del vuelo).
   ============================================================================ */
USE VuelosBI;
GO

SELECT
    d.anio,
    d.mes,
    d.nombre_mes,
    COUNT(*)                                        AS total_vuelos,
    CAST(SUM(f.precio_ticket_usd) AS DECIMAL(12,2))  AS ingresos_usd
FROM dbo.Fact_Vuelos f
JOIN dbo.Dim_Fecha d ON d.fecha_key = f.fecha_salida_key
GROUP BY d.anio, d.mes, d.nombre_mes
ORDER BY d.anio, d.mes;



/*
anio  mes  nombre_mes  total_vuelos  ingresos_usd
2024	1	January	423	36994.06	
2024	2	February	380	29885.21	
2024	3	March	416	31655.59	
2024	4	April	420	29700.08	
2024	5	May	402	30694.57	
2024	6	June	370	28798.63	
2024	7	July	404	31192.90	
2024	8	August	428	36729.57	
2024	9	September	391	29815.49	
2024	10	October	464	33291.14	
2024	11	November	389	32405.70	
2024	12	December	440	34171.77	
2025	1	January	421	32539.74	
2025	2	February	402	31139.86	
2025	3	March	397	30391.92	
2025	4	April	449	32150.23	
2025	5	May	423	32568.67	
2025	6	June	459	34245.38	
2025	7	July	448	36367.10	
2025	8	August	404	30261.96	
2025	9	September	391	27832.64	
2025	10	October	411	31157.24	
2025	11	November	430	32470.25	
2025	12	December	438	33565.01	



*/