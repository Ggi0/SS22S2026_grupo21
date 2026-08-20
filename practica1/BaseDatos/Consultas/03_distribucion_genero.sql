/* ============================================================================
   Consulta 3: Distribucion de vuelos por genero del pasajero
   Objetivo: indicador de negocio solicitado explicitamente en el enunciado.
   ============================================================================ */
USE VuelosBI;
GO

SELECT
    p.genero,
    COUNT(*)                                                  AS total_vuelos,
    CAST(100.0 * COUNT(*) / SUM(COUNT(*)) OVER () AS DECIMAL(5,2)) AS porcentaje
FROM dbo.Fact_Vuelos f
JOIN dbo.Dim_Pasajero p ON p.pasajero_key = f.pasajero_key
GROUP BY p.genero
ORDER BY total_vuelos DESC;
