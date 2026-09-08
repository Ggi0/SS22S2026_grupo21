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


/*
canal_venta	metodo_pago	total_transacciones	ingresos_totales_usd	ticket_promedio_usd

CALL_CENTER	TARJETA	394	33327.94	84.59	
AGENCIA	TARJETA	417	33285.19	79.82	
CALL_CENTER	EFECTIVO	406	33131.39	81.60	
APP	PUNTOS	398	33118.62	83.21	
AEROPUERTO	PAYPAL	406	33057.64	81.42	
WEB	PAYPAL	421	32769.80	77.84	
APP	TARJETA	411	32483.32	79.03	
AGENCIA	PAYPAL	441	32114.85	72.82	
WEB	EFECTIVO	402	31746.88	78.97	
AEROPUERTO	TRANSFERENCIA	408	30984.02	75.94	
WEB	TRANSFERENCIA	406	30590.21	75.35	
CALL_CENTER	TRANSFERENCIA	388	30517.66	78.65	
WEB	TARJETA	382	30481.25	79.79	
AEROPUERTO	PUNTOS	407	29948.91	73.58	
AEROPUERTO	TARJETA	406	29718.33	73.20	
AEROPUERTO	EFECTIVO	397	29661.00	74.71	
APP	PAYPAL	379	29381.87	77.52	
WEB	PUNTOS	384	29336.06	76.40	
CALL_CENTER	PAYPAL	397	29086.32	73.27	
APP	TRANSFERENCIA	371	28755.18	77.51	
AGENCIA	TRANSFERENCIA	384	28475.03	74.15	
AGENCIA	PUNTOS	376	27617.13	73.45	
APP	EFECTIVO	373	27098.61	72.65	
AGENCIA	EFECTIVO	340	26394.29	77.63	
CALL_CENTER	PUNTOS	362	25991.93	71.80	
SIN_DATO	PUNTOS	31	2733.50	88.18	
SIN_DATO	TARJETA	32	2661.81	83.18	
SIN_DATO	TRANSFERENCIA	27	2090.96	77.44	
SIN_DATO	EFECTIVO	31	1884.90	60.80	
SIN_DATO	PAYPAL	23	1580.11	68.70	



*/