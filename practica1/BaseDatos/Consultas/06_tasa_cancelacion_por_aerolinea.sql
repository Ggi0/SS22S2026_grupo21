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

/*

aerolinea            total_vuelos_vendidos  vuelos_cancelados  tasa_cancelacion_pct
Avianca	835	60	7.19	
Copa Airlines	888	58	6.53	
British Airways	829	53	6.39	
United	797	48	6.02	
American Airlines	824	48	5.83	
LATAM	803	46	5.73	
Aeromexico	772	43	5.57	
Ryanair	850	46	5.41	
Southwest	868	47	5.41	
Iberia	867	42	4.84	
Delta	814	35	4.30	
JetBlue	853	34	3.99	


*/