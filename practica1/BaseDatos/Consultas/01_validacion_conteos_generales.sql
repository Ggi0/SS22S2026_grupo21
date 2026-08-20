/* ============================================================================
   Consulta 1: Validacion de carga - conteos generales
   Objetivo: confirmar que el ETL cargo la cantidad esperada de registros
   en la tabla de hechos y en cada dimension. Es la primera validacion que
   se corre despues de ejecutar el proceso de carga (load.py).
   ============================================================================ */
USE VuelosBI;
GO

SELECT 'Fact_Vuelos'      AS tabla, COUNT(*) AS total_registros FROM dbo.Fact_Vuelos
UNION ALL
SELECT 'Dim_Aerolinea',    COUNT(*) FROM dbo.Dim_Aerolinea
UNION ALL
SELECT 'Dim_Aeropuerto',   COUNT(*) FROM dbo.Dim_Aeropuerto
UNION ALL
SELECT 'Dim_Aeronave',     COUNT(*) FROM dbo.Dim_Aeronave
UNION ALL
SELECT 'Dim_Pasajero',     COUNT(*) FROM dbo.Dim_Pasajero
UNION ALL
SELECT 'Dim_ClaseCabina',  COUNT(*) FROM dbo.Dim_ClaseCabina
UNION ALL
SELECT 'Dim_CanalVenta',   COUNT(*) FROM dbo.Dim_CanalVenta
UNION ALL
SELECT 'Dim_MetodoPago',   COUNT(*) FROM dbo.Dim_MetodoPago
UNION ALL
SELECT 'Dim_EstadoVuelo',  COUNT(*) FROM dbo.Dim_EstadoVuelo
UNION ALL
SELECT 'Dim_Fecha',        COUNT(*) FROM dbo.Dim_Fecha;

-- Chequeo adicional: no debe haber claves foraneas huerfanas (NULL) en el hecho
SELECT COUNT(*) AS filas_con_fk_nula
FROM dbo.Fact_Vuelos
WHERE aerolinea_key IS NULL OR aeropuerto_origen_key IS NULL
   OR aeropuerto_destino_key IS NULL OR aeronave_key IS NULL
   OR clase_cabina_key IS NULL OR pasajero_key IS NULL
   OR canal_venta_key IS NULL OR metodo_pago_key IS NULL
   OR estado_vuelo_key IS NULL OR fecha_salida_key IS NULL
   OR fecha_reserva_key IS NULL;
