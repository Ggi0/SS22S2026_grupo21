-- 03_llaves_no_resueltas.sql — registros que cayeron en el miembro -1 "NO DEFINIDO".
-- No es un error del pipeline sino un hallazgo de calidad de la fuente:
-- resultado 'OK' si 0, 'WARN' si hay (el runner solo cuenta 'FALLA' como error).
SELECT check_name, 0::text AS esperado, n::text AS obtenido,
       CASE WHEN n = 0 THEN 'OK' ELSE 'WARN' END AS resultado
FROM (
    SELECT 'fact_ventas con cliente_key = -1' AS check_name, count(*) AS n FROM marts.fact_ventas WHERE cliente_key = -1
    UNION ALL SELECT 'fact_ventas con producto_key = -1', count(*) FROM marts.fact_ventas WHERE producto_key = -1
    UNION ALL SELECT 'fact_devoluciones con sucursal_key = -1 (venta inexistente)', count(*) FROM marts.fact_devoluciones WHERE sucursal_key = -1
    UNION ALL SELECT 'fact_inventario con producto_key = -1', count(*) FROM marts.fact_inventario WHERE producto_key = -1
    UNION ALL SELECT 'fact_precios_proveedor con producto_key = -1', count(*) FROM marts.fact_precios_proveedor WHERE producto_key = -1
) t
ORDER BY check_name;
