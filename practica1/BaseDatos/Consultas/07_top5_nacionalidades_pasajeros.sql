/* ============================================================================
   Consulta 7: Top 5 nacionalidades de pasajeros
   Objetivo: entender el perfil demografico de los clientes.
   ============================================================================ */
USE VuelosBI;
GO

SELECT TOP 5
    p.nacionalidad,
    COUNT(DISTINCT p.pasajero_key)   AS pasajeros_unicos,
    COUNT(*)                         AS total_vuelos_comprados
FROM dbo.Fact_Vuelos f
JOIN dbo.Dim_Pasajero p ON p.pasajero_key = f.pasajero_key
GROUP BY p.nacionalidad
ORDER BY total_vuelos_comprados DESC;
