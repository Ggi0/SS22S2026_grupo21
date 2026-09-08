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


/*

genero total_vuelos porcentaje
M	4912	49.12	
F	4698	46.98	
X	390	3.90	



*/