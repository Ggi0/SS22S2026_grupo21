-- 02_raw_tables.sql — Tablas del schema RAW (aterrizaje de datos crudos)

-- Reglas de la capa raw:
--   * TODAS las columnas de datos son TEXT: raw nunca rechaza una fila por tipo,
--     así los datos "sucios" llegan intactos y dbt decide qué hacer con ellos.
--   * NULL (dato ausente) y '' (vacío) se guardan distintos; no se transforman.
--   * Sin PK/FK/CHECK: raw es un reflejo fiel, la calidad se valida en dbt.
--   * Columnas de control: _batch_id (corrida), _loaded_at, _source_file (origen).
-- Python hace TRUNCATE + INSERT en cada corrida (carga completa e idempotente).
-- Esta definición es la FUENTE DE VERDAD: el cargador lee las columnas de aquí.

-- Origen: OLTP oltp_sgfood.sucursal
CREATE TABLE IF NOT EXISTS raw.oltp_sucursal (
    id_sucursal        TEXT,
    nombre             TEXT,
    ciudad             TEXT,
    departamento       TEXT,
    _batch_id          TEXT,
    _loaded_at         TIMESTAMPTZ NOT NULL DEFAULT now(),
    _source_file       TEXT
);

-- Origen: OLTP oltp_sgfood.categoria
CREATE TABLE IF NOT EXISTS raw.oltp_categoria (
    id_categoria       TEXT,
    nombre             TEXT,
    _batch_id          TEXT,
    _loaded_at         TIMESTAMPTZ NOT NULL DEFAULT now(),
    _source_file       TEXT
);

-- Origen: OLTP oltp_sgfood.marca
CREATE TABLE IF NOT EXISTS raw.oltp_marca (
    id_marca           TEXT,
    nombre             TEXT,
    _batch_id          TEXT,
    _loaded_at         TIMESTAMPTZ NOT NULL DEFAULT now(),
    _source_file       TEXT
);

-- Origen: OLTP oltp_sgfood.producto
CREATE TABLE IF NOT EXISTS raw.oltp_producto (
    id_producto        TEXT,
    sku                TEXT,
    nombre             TEXT,
    id_categoria       TEXT,
    id_marca           TEXT,
    unidad_medida      TEXT,
    costo_base         TEXT,
    precio_lista       TEXT,
    activo             TEXT,
    _batch_id          TEXT,
    _loaded_at         TIMESTAMPTZ NOT NULL DEFAULT now(),
    _source_file       TEXT
);

-- Origen: OLTP oltp_sgfood.cliente
CREATE TABLE IF NOT EXISTS raw.oltp_cliente (
    id_cliente         TEXT,
    nit                TEXT,
    nombre             TEXT,
    tipo_cliente       TEXT,
    municipio          TEXT,
    departamento       TEXT,
    fecha_alta         TEXT,
    _batch_id          TEXT,
    _loaded_at         TIMESTAMPTZ NOT NULL DEFAULT now(),
    _source_file       TEXT
);

-- Origen: OLTP oltp_sgfood.venta
CREATE TABLE IF NOT EXISTS raw.oltp_venta (
    id_venta           TEXT,
    fecha              TEXT,
    id_cliente         TEXT,
    id_sucursal        TEXT,
    canal              TEXT,
    metodo_pago        TEXT,
    estado             TEXT,
    _batch_id          TEXT,
    _loaded_at         TIMESTAMPTZ NOT NULL DEFAULT now(),
    _source_file       TEXT
);

-- Origen: OLTP oltp_sgfood.venta_detalle
CREATE TABLE IF NOT EXISTS raw.oltp_venta_detalle (
    id_detalle         TEXT,
    id_venta           TEXT,
    id_producto        TEXT,
    cantidad           TEXT,
    precio_unitario    TEXT,
    descuento          TEXT,
    subtotal           TEXT,
    _batch_id          TEXT,
    _loaded_at         TIMESTAMPTZ NOT NULL DEFAULT now(),
    _source_file       TEXT
);

-- Origen: CSV inventario_bodega.csv
CREATE TABLE IF NOT EXISTS raw.csv_inventario_bodega (
    fecha_corte        TEXT,
    id_sucursal        TEXT,
    id_producto        TEXT,
    stock_disponible   TEXT,
    stock_minimo       TEXT,
    stock_maximo       TEXT,
    lote               TEXT,
    fecha_vencimiento  TEXT,
    _batch_id          TEXT,
    _loaded_at         TIMESTAMPTZ NOT NULL DEFAULT now(),
    _source_file       TEXT
);

-- Origen: CSV proveedores_precios.csv
CREATE TABLE IF NOT EXISTS raw.csv_proveedores_precios (
    id_proveedor       TEXT,
    proveedor          TEXT,
    id_producto        TEXT,
    costo_proveedor    TEXT,
    plazo_dias         TEXT,
    fecha_vigencia     TEXT,
    _batch_id          TEXT,
    _loaded_at         TIMESTAMPTZ NOT NULL DEFAULT now(),
    _source_file       TEXT
);

-- Origen: CSV promociones.csv
CREATE TABLE IF NOT EXISTS raw.csv_promociones (
    id_promocion       TEXT,
    nombre             TEXT,
    fecha_inicio       TEXT,
    fecha_fin          TEXT,
    id_categoria       TEXT,
    porcentaje_descuento TEXT,
    _batch_id          TEXT,
    _loaded_at         TIMESTAMPTZ NOT NULL DEFAULT now(),
    _source_file       TEXT
);

-- Origen: CSV metas_ventas.csv
CREATE TABLE IF NOT EXISTS raw.csv_metas_ventas (
    periodo            TEXT,
    id_sucursal        TEXT,
    meta_ventas        TEXT,
    meta_unidades      TEXT,
    _batch_id          TEXT,
    _loaded_at         TIMESTAMPTZ NOT NULL DEFAULT now(),
    _source_file       TEXT
);

-- Origen: CSV devoluciones.csv
CREATE TABLE IF NOT EXISTS raw.csv_devoluciones (
    id_devolucion      TEXT,
    fecha              TEXT,
    id_venta           TEXT,
    id_producto        TEXT,
    cantidad           TEXT,
    motivo             TEXT,
    _batch_id          TEXT,
    _loaded_at         TIMESTAMPTZ NOT NULL DEFAULT now(),
    _source_file       TEXT
);

-- Origen: CSV casos_calidad_opcionales.csv
CREATE TABLE IF NOT EXISTS raw.csv_casos_calidad (
    entidad            TEXT,
    campo              TEXT,
    valor_prueba       TEXT,
    tipo_incidencia    TEXT,
    _batch_id          TEXT,
    _loaded_at         TIMESTAMPTZ NOT NULL DEFAULT now(),
    _source_file       TEXT
);

-- Origen: XLSX catalogo_insumos_sgfood.xlsx
CREATE TABLE IF NOT EXISTS raw.xlsx_catalogo_insumos (
    fuente             TEXT,
    entidad_archivo    TEXT,
    campo              TEXT,
    tipo               TEXT,
    clave_regla        TEXT,
    descripcion        TEXT,
    _batch_id          TEXT,
    _loaded_at         TIMESTAMPTZ NOT NULL DEFAULT now(),
    _source_file       TEXT
);
