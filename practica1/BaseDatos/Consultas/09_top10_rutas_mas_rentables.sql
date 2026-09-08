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


/*
ruta  total_vuelos  ingresos_totales_usd  ticket_promedio_usd
MIA -> HAV	76	5621.97	73.97	
HAV -> PTY	51	5405.44	105.99	
MIA -> GUA	52	5253.85	101.04	
MIA -> SAP	51	5181.44	101.60	
HAV -> BOG	59	5144.49	87.19	
HAV -> GUA	63	5137.62	81.55	
SAL -> CUN	60	5114.84	85.25	
BCN -> MEX	57	5079.74	89.12	
SAL -> LAX	64	4986.49	77.91	
CUN -> BOG	62	4951.79	79.87	

*/