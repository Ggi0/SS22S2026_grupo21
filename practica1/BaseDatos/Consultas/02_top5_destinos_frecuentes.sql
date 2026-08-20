/* ============================================================================
   Consulta 2: Top 5 destinos mas frecuentes
   Objetivo: indicador de negocio solicitado explicitamente en el enunciado.
   ============================================================================ */
USE VuelosBI;
GO

SELECT TOP 5
    a.codigo_iata          AS destino,
    a.ciudad,
    a.pais,
    COUNT(*)               AS total_vuelos
FROM dbo.Fact_Vuelos f
JOIN dbo.Dim_Aeropuerto a ON a.aeropuerto_key = f.aeropuerto_destino_key
GROUP BY a.codigo_iata, a.ciudad, a.pais
ORDER BY total_vuelos DESC;
