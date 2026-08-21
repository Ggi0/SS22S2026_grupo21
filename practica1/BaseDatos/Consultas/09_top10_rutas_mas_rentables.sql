/* ============================================================================
   Consulta 9: Top 10 rutas (origen -> destino) mas rentables
   Objetivo: consulta analitica adicional que combina dos roles de la misma
   dimension (Dim_Aeropuerto como origen y como destino), demostrando el
   uso de "role-playing dimensions" en el modelo en estrella.
   ============================================================================ */
USE VuelosBI;
GO

SELECT TOP 10
    ao.codigo_iata + ' -> ' + ad.codigo_iata   AS ruta,
    COUNT(*)                                    AS total_vuelos,
    CAST(SUM(f.precio_ticket_usd) AS DECIMAL(12,2)) AS ingresos_totales_usd,
    CAST(AVG(f.precio_ticket_usd) AS DECIMAL(10,2)) AS ticket_promedio_usd
FROM dbo.Fact_Vuelos f
JOIN dbo.Dim_Aeropuerto ao ON ao.aeropuerto_key = f.aeropuerto_origen_key
JOIN dbo.Dim_Aeropuerto ad ON ad.aeropuerto_key = f.aeropuerto_destino_key
GROUP BY ao.codigo_iata, ad.codigo_iata
ORDER BY ingresos_totales_usd DESC;
