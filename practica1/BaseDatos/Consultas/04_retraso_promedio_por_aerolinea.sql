/* ============================================================================
   Consulta 4: Retraso promedio y maximo por aerolinea
   Objetivo: identificar que aerolineas presentan mas problemas de puntualidad.
   Solo considera vuelos que efectivamente volaron (no CANCELLED, ya que esos
   no tienen retraso_min).
   ============================================================================ */
USE VuelosBI;
GO

SELECT
    al.nombre                        AS aerolinea,
    COUNT(*)                         AS vuelos_operados,
    SUM(CASE WHEN ev.nombre_estado = 'DELAYED' THEN 1 ELSE 0 END) AS vuelos_retrasados,
    CAST(AVG(CAST(f.retraso_min AS FLOAT)) AS DECIMAL(6,1))       AS retraso_promedio_min,
    MAX(f.retraso_min)               AS retraso_maximo_min
FROM dbo.Fact_Vuelos f
JOIN dbo.Dim_Aerolinea al ON al.aerolinea_key = f.aerolinea_key
JOIN dbo.Dim_EstadoVuelo ev ON ev.estado_vuelo_key = f.estado_vuelo_key
WHERE ev.nombre_estado <> 'CANCELLED'
GROUP BY al.nombre
ORDER BY retraso_promedio_min DESC;
