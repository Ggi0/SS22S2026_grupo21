-- 02_integridad_referencial.sql — ¿alguna FK de hechos apunta a una dimensión inexistente?
-- Esperado: 0 huérfanas en cada relación. 'OK' | 'FALLA'.
SELECT check_name, 0::text AS esperado, huerfanas::text AS obtenido,
       CASE WHEN huerfanas = 0 THEN 'OK' ELSE 'FALLA' END AS resultado
FROM (
    SELECT 'fact_ventas -> dim_fecha' AS check_name, count(*) AS huerfanas
      FROM marts.fact_ventas f LEFT JOIN marts.dim_fecha d USING (fecha_key) WHERE d.fecha_key IS NULL
    UNION ALL SELECT 'fact_ventas -> dim_cliente', count(*)
      FROM marts.fact_ventas f LEFT JOIN marts.dim_cliente d USING (cliente_key) WHERE d.cliente_key IS NULL
    UNION ALL SELECT 'fact_ventas -> dim_sucursal', count(*)
      FROM marts.fact_ventas f LEFT JOIN marts.dim_sucursal d USING (sucursal_key) WHERE d.sucursal_key IS NULL
    UNION ALL SELECT 'fact_ventas -> dim_producto', count(*)
      FROM marts.fact_ventas f LEFT JOIN marts.dim_producto d USING (producto_key) WHERE d.producto_key IS NULL
    UNION ALL SELECT 'fact_ventas -> dim_canal_pago', count(*)
      FROM marts.fact_ventas f LEFT JOIN marts.dim_canal_pago d USING (canal_pago_key) WHERE d.canal_pago_key IS NULL
    UNION ALL SELECT 'fact_ventas -> dim_promocion', count(*)
      FROM marts.fact_ventas f LEFT JOIN marts.dim_promocion d USING (promocion_key) WHERE d.promocion_key IS NULL
    UNION ALL SELECT 'fact_devoluciones -> dim_producto', count(*)
      FROM marts.fact_devoluciones f LEFT JOIN marts.dim_producto d USING (producto_key) WHERE d.producto_key IS NULL
    UNION ALL SELECT 'fact_inventario -> dim_producto', count(*)
      FROM marts.fact_inventario f LEFT JOIN marts.dim_producto d USING (producto_key) WHERE d.producto_key IS NULL
    UNION ALL SELECT 'fact_inventario -> dim_sucursal', count(*)
      FROM marts.fact_inventario f LEFT JOIN marts.dim_sucursal d USING (sucursal_key) WHERE d.sucursal_key IS NULL
    UNION ALL SELECT 'fact_metas_ventas -> dim_sucursal', count(*)
      FROM marts.fact_metas_ventas f LEFT JOIN marts.dim_sucursal d USING (sucursal_key) WHERE d.sucursal_key IS NULL
    UNION ALL SELECT 'fact_precios_proveedor -> dim_proveedor', count(*)
      FROM marts.fact_precios_proveedor f LEFT JOIN marts.dim_proveedor d USING (proveedor_key) WHERE d.proveedor_key IS NULL
) t
ORDER BY check_name;
