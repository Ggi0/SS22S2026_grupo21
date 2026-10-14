-- 01_conteos_raw_vs_marts.sql — ¿llegó todo? Conteos y sumas raw vs marts.
-- Salida obligatoria: (check_name, esperado, obtenido, resultado) con resultado 'OK' | 'FALLA'.
SELECT check_name, esperado::text, obtenido::text,
       CASE WHEN esperado = obtenido THEN 'OK' ELSE 'FALLA' END AS resultado
FROM (
    SELECT 'filas fact_ventas = raw.oltp_venta_detalle' AS check_name,
           (SELECT count(*) FROM raw.oltp_venta_detalle)::numeric AS esperado,
           (SELECT count(*) FROM marts.fact_ventas)::numeric      AS obtenido
    UNION ALL
    SELECT 'suma monto_neto = suma raw.subtotal',
           (SELECT round(sum(btrim(subtotal)::numeric), 2) FROM raw.oltp_venta_detalle),
           (SELECT round(sum(monto_neto), 2) FROM marts.fact_ventas)
    UNION ALL
    SELECT 'dim_sucursal = raw + miembro -1',
           (SELECT count(*) + 1 FROM raw.oltp_sucursal), (SELECT count(*) FROM marts.dim_sucursal)
    UNION ALL
    SELECT 'dim_producto = raw + miembro -1',
           (SELECT count(*) + 1 FROM raw.oltp_producto), (SELECT count(*) FROM marts.dim_producto)
    UNION ALL
    SELECT 'dim_cliente (id válido) = raw + miembro -1',
           (SELECT count(*) + 1 FROM raw.oltp_cliente WHERE btrim(id_cliente) ~ '^[0-9]+$'),
           (SELECT count(*) FROM marts.dim_cliente)
    UNION ALL
    SELECT 'fact_devoluciones = devoluciones distintas en raw',
           (SELECT count(DISTINCT id_devolucion) FROM raw.csv_devoluciones WHERE btrim(id_devolucion) ~ '^[0-9]+$'),
           (SELECT count(*) FROM marts.fact_devoluciones)
    UNION ALL
    SELECT 'fact_inventario = combinaciones distintas en raw',
           (SELECT count(*) FROM (SELECT DISTINCT fecha_corte, id_sucursal, id_producto
                                  FROM raw.csv_inventario_bodega
                                  WHERE btrim(id_sucursal) ~ '^[0-9]+$' AND btrim(id_producto) ~ '^[0-9]+$'
                                    AND btrim(fecha_corte) ~ '^[0-9]{4}-[0-9]{2}-[0-9]{2}$') x),
           (SELECT count(*) FROM marts.fact_inventario)
    UNION ALL
    SELECT 'fact_metas_ventas = combinaciones distintas en raw',
           (SELECT count(*) FROM (SELECT DISTINCT periodo, id_sucursal FROM raw.csv_metas_ventas
                                  WHERE btrim(id_sucursal) ~ '^[0-9]+$' AND btrim(periodo) ~ '^[0-9]{4}-[0-9]{2}$') x),
           (SELECT count(*) FROM marts.fact_metas_ventas)
) t
ORDER BY check_name;
