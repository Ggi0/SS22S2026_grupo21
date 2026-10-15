-- 03_constraints_dw.sql — Llaves primarias y foráneas del modelo (marts)

-- Se ejecuta DESPUÉS de dbt (las tablas de marts las crea dbt; este script les
-- agrega las restricciones físicas). 

-- Es IDEMPOTENTE: solo agrega lo que falta.

-- Ejecutar: make constraints   |   python -m sgfood_etl apply-constraints

-- dbt reconstruye las tablas en cada corrida (se pierden las restricciones),
-- por eso este paso va siempre al final del flujo (y será una tarea de Airflow).
-- Las llaves huérfanas no rompen las FK porque apuntan al miembro -1 de la dimensión.

DO $$
DECLARE r record;
BEGIN
    -- ---------------------------- PRIMARY KEYS ----------------------------
    FOR r IN SELECT * FROM (VALUES
        ('dim_fecha',              'fecha_key'),
        ('dim_sucursal',           'sucursal_key'),
        ('dim_producto',           'producto_key'),
        ('dim_cliente',            'cliente_key'),
        ('dim_proveedor',          'proveedor_key'),
        ('dim_canal_pago',         'canal_pago_key'),
        ('dim_promocion',          'promocion_key'),
        ('fact_ventas',            'detalle_key'),
        ('fact_devoluciones',      'devolucion_key'),
        ('fact_inventario',        'inventario_key'),
        ('fact_metas_ventas',      'meta_key'),
        ('fact_precios_proveedor', 'precio_key')
    ) AS t(tbl, col) LOOP
        IF NOT EXISTS (SELECT 1 FROM pg_constraint
                       WHERE conname = 'pk_' || r.tbl
                         AND conrelid = format('marts.%I', r.tbl)::regclass) THEN
            EXECUTE format('ALTER TABLE marts.%I ADD CONSTRAINT %I PRIMARY KEY (%I)',
                           r.tbl, 'pk_' || r.tbl, r.col);
        END IF;
    END LOOP;

    -- ---------------------------- FOREIGN KEYS ----------------------------
    FOR r IN SELECT * FROM (VALUES
        ('fact_ventas',            'fecha_key',          'dim_fecha',      'fecha_key'),
        ('fact_ventas',            'cliente_key',        'dim_cliente',    'cliente_key'),
        ('fact_ventas',            'sucursal_key',       'dim_sucursal',   'sucursal_key'),
        ('fact_ventas',            'producto_key',       'dim_producto',   'producto_key'),
        ('fact_ventas',            'canal_pago_key',     'dim_canal_pago', 'canal_pago_key'),
        ('fact_ventas',            'promocion_key',      'dim_promocion',  'promocion_key'),
        ('fact_devoluciones',      'fecha_key',          'dim_fecha',      'fecha_key'),
        ('fact_devoluciones',      'producto_key',       'dim_producto',   'producto_key'),
        ('fact_devoluciones',      'sucursal_key',       'dim_sucursal',   'sucursal_key'),
        ('fact_devoluciones',      'cliente_key',        'dim_cliente',    'cliente_key'),
        ('fact_inventario',        'fecha_key',          'dim_fecha',      'fecha_key'),
        ('fact_inventario',        'sucursal_key',       'dim_sucursal',   'sucursal_key'),
        ('fact_inventario',        'producto_key',       'dim_producto',   'producto_key'),
        ('fact_metas_ventas',      'fecha_key',          'dim_fecha',      'fecha_key'),
        ('fact_metas_ventas',      'sucursal_key',       'dim_sucursal',   'sucursal_key'),
        ('fact_precios_proveedor', 'proveedor_key',      'dim_proveedor',  'proveedor_key'),
        ('fact_precios_proveedor', 'producto_key',       'dim_producto',   'producto_key'),
        ('fact_precios_proveedor', 'fecha_vigencia_key', 'dim_fecha',      'fecha_key')
    ) AS t(tbl, col, ref_tbl, ref_col) LOOP
        IF NOT EXISTS (SELECT 1 FROM pg_constraint
                       WHERE conname = 'fk_' || r.tbl || '_' || r.col
                         AND conrelid = format('marts.%I', r.tbl)::regclass) THEN
            EXECUTE format(
                'ALTER TABLE marts.%I ADD CONSTRAINT %I FOREIGN KEY (%I) REFERENCES marts.%I (%I)',
                r.tbl, 'fk_' || r.tbl || '_' || r.col, r.col, r.ref_tbl, r.ref_col);
        END IF;
    END LOOP;
END $$;
