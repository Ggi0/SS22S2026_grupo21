/* ============================================================================
   Consulta 6: Tasa de cancelacion por aerolinea
   Objetivo: indicador de calidad de servicio; porcentaje de vuelos
   cancelados sobre el total vendido por cada aerolinea.
   ============================================================================ */
USE VuelosBI;
GO

SELECT
    al.nombre                    AS aerolinea,
    COUNT(*)                     AS total_vuelos_vendidos,
    SUM(CASE WHEN ev.nombre_estado = 'CANCELLED' THEN 1 ELSE 0 END) AS vuelos_cancelados,
    CAST(100.0 * SUM(CASE WHEN ev.nombre_estado = 'CANCELLED' THEN 1 ELSE 0 END)
         / COUNT(*) AS DECIMAL(5,2))                                AS tasa_cancelacion_pct
FROM dbo.Fact_Vuelos f
JOIN dbo.Dim_Aerolinea al ON al.aerolinea_key = f.aerolinea_key
JOIN dbo.Dim_EstadoVuelo ev ON ev.estado_vuelo_key = f.estado_vuelo_key
GROUP BY al.nombre
ORDER BY tasa_cancelacion_pct DESC;
