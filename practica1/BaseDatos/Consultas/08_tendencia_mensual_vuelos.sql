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

