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


/*

aerolinea            vuelos_operados  vuelos_retrasados  retraso_promedio_min  retraso_maximo_min
Ryanair	804	172	29.4	239	
Southwest	821	184	28.2	240	
Iberia	825	185	27.0	239	
Aeromexico	729	151	26.8	239	
United	749	160	26.8	240	
LATAM	757	155	26.7	239	
British Airways	776	153	25.7	240	
Avianca	775	162	25.6	235	
Copa Airlines	830	167	25.1	240	
American Airlines	776	166	24.5	240	
Delta	779	160	23.8	239	
JetBlue	819	155	23.3	238	


*/