/* ============================================================================
   Consulta 5: Ingresos totales (USD) por canal de venta y metodo de pago
   Objetivo: entender de donde provienen los ingresos, util para decisiones
   comerciales (que canal/metodo de pago potenciar).
   ============================================================================ */
USE VuelosBI;
GO

SELECT
    cv.nombre_canal                          AS canal_venta,
    mp.nombre_metodo                         AS metodo_pago,
    COUNT(*)                                 AS total_transacciones,
    CAST(SUM(f.precio_ticket_usd) AS DECIMAL(12,2))  AS ingresos_totales_usd,
    CAST(AVG(f.precio_ticket_usd) AS DECIMAL(10,2))  AS ticket_promedio_usd
FROM dbo.Fact_Vuelos f
JOIN dbo.Dim_CanalVenta cv ON cv.canal_venta_key = f.canal_venta_key
JOIN dbo.Dim_MetodoPago mp ON mp.metodo_pago_key = f.metodo_pago_key
GROUP BY cv.nombre_canal, mp.nombre_metodo
ORDER BY ingresos_totales_usd DESC;
