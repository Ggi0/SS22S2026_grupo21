-- =============================================================================
-- 04_marts_reference_ddl.sql — DDL de REFERENCIA del modelo estrella (schema marts)
-- Generado con pg_dump -s a partir de lo que construye dbt + 03_constraints_dw.sql.
-- ES DOCUMENTACIÓN / ENTREGABLE: no hace falta ejecutarlo; el flujo real es
--   dbt build  ->  apply-constraints.  Úselo para revisar tipos, PK y FK.
-- =============================================================================

\restrict oeeOmi0MoSyya58zRRqKnLzg1pl0kWK0JsdlPvAM56MDi6XJhLwcEgCBI3pQBob

-- Name: marts; Type: SCHEMA; Schema: -; Owner: -

CREATE SCHEMA marts;

-- Name: audit_calidad_datos; Type: TABLE; Schema: marts; Owner: -

CREATE TABLE marts.audit_calidad_datos (
    regla text,
    entidad text,
    campo text,
    severidad text,
    afectados bigint,
    total bigint,
    porcentaje numeric,
    calculado_en timestamp with time zone
);

-- Name: dim_canal_pago; Type: TABLE; Schema: marts; Owner: -

CREATE TABLE marts.dim_canal_pago (
    canal_pago_key bigint NOT NULL,
    canal text,
    metodo_pago text
);

-- Name: dim_cliente; Type: TABLE; Schema: marts; Owner: -

CREATE TABLE marts.dim_cliente (
    cliente_key bigint NOT NULL,
    id_cliente bigint,
    nit text,
    nombre_cliente text,
    tipo_cliente text,
    municipio text,
    departamento text,
    fecha_alta date
);

-- Name: dim_fecha; Type: TABLE; Schema: marts; Owner: -

CREATE TABLE marts.dim_fecha (
    fecha_key integer NOT NULL,
    fecha date,
    anio integer,
    trimestre integer,
    mes integer,
    nombre_mes text,
    periodo text,
    dia_semana integer,
    nombre_dia text,
    es_fin_de_semana boolean,
    semana_iso integer
);

-- Name: dim_producto; Type: TABLE; Schema: marts; Owner: -

CREATE TABLE marts.dim_producto (
    producto_key bigint NOT NULL,
    id_producto bigint,
    sku text,
    nombre_producto text,
    id_categoria bigint,
    categoria text,
    id_marca bigint,
    marca text,
    unidad_medida text,
    costo_base numeric,
    precio_lista numeric,
    activo boolean,
    margen_lista_pct numeric
);

-- Name: dim_promocion; Type: TABLE; Schema: marts; Owner: -

CREATE TABLE marts.dim_promocion (
    promocion_key bigint NOT NULL,
    id_promocion bigint,
    nombre_promocion text,
    fecha_inicio date,
    fecha_fin date,
    duracion_dias integer,
    id_categoria bigint,
    categoria text,
    porcentaje_descuento numeric
);

-- Name: dim_proveedor; Type: TABLE; Schema: marts; Owner: -

CREATE TABLE marts.dim_proveedor (
    proveedor_key bigint NOT NULL,
    id_proveedor bigint,
    nombre_proveedor text
);

-- Name: dim_sucursal; Type: TABLE; Schema: marts; Owner: -

CREATE TABLE marts.dim_sucursal (
    sucursal_key bigint NOT NULL,
    id_sucursal bigint,
    nombre_sucursal text,
    ciudad text,
    departamento text
);

-- Name: fact_devoluciones; Type: TABLE; Schema: marts; Owner: -

CREATE TABLE marts.fact_devoluciones (
    devolucion_key bigint NOT NULL,
    id_venta bigint,
    fecha_key integer,
    producto_key bigint,
    sucursal_key bigint,
    cliente_key bigint,
    motivo text,
    cantidad bigint,
    cantidad_vendida numeric,
    existe_venta_producto boolean,
    excede_vendido boolean,
    monto_devuelto_estimado numeric
);

-- Name: fact_inventario; Type: TABLE; Schema: marts; Owner: -

CREATE TABLE marts.fact_inventario (
    inventario_key bigint NOT NULL,
    fecha_key integer,
    sucursal_key bigint,
    producto_key bigint,
    lote text,
    fecha_vencimiento date,
    dias_para_vencer integer,
    fecha_vencimiento_estado text,
    stock_disponible bigint,
    stock_minimo bigint,
    stock_maximo bigint,
    bajo_minimo boolean,
    sobre_maximo boolean,
    dq_stock_negativo boolean,
    dq_vencido_al_corte boolean
);

-- Name: fact_metas_ventas; Type: TABLE; Schema: marts; Owner: -

CREATE TABLE marts.fact_metas_ventas (
    meta_key bigint NOT NULL,
    fecha_key integer,
    sucursal_key bigint,
    periodo text,
    meta_ventas numeric,
    meta_unidades bigint,
    dq_meta_cero boolean
);

-- Name: fact_precios_proveedor; Type: TABLE; Schema: marts; Owner: -

CREATE TABLE marts.fact_precios_proveedor (
    precio_key bigint NOT NULL,
    proveedor_key bigint,
    producto_key bigint,
    fecha_vigencia_key integer,
    costo_proveedor numeric,
    costo_proveedor_estado text,
    plazo_dias bigint,
    costo_base_producto numeric,
    variacion_vs_costo_base_pct numeric
);

-- Name: fact_ventas; Type: TABLE; Schema: marts; Owner: -

CREATE TABLE marts.fact_ventas (
    detalle_key bigint NOT NULL,
    id_venta bigint,
    fecha_key integer,
    cliente_key bigint,
    sucursal_key bigint,
    producto_key bigint,
    canal_pago_key bigint,
    promocion_key bigint,
    estado_venta text,
    es_venta_efectiva boolean,
    cantidad bigint,
    precio_unitario numeric,
    descuento_pct numeric,
    monto_bruto numeric,
    monto_descuento numeric,
    monto_neto numeric,
    costo_estimado numeric,
    margen_estimado numeric,
    dq_subtotal_inconsistente boolean
);

-- Name: mart_cumplimiento_metas; Type: TABLE; Schema: marts; Owner: -

CREATE TABLE marts.mart_cumplimiento_metas (
    periodo text,
    nombre_sucursal text,
    meta_ventas numeric,
    venta_real numeric,
    brecha_ventas numeric,
    cumplimiento_ventas_pct numeric,
    meta_unidades bigint,
    unidades_reales numeric,
    cumplimiento_unidades_pct numeric
);

-- Name: dim_canal_pago pk_dim_canal_pago; Type: CONSTRAINT; Schema: marts; Owner: -

ALTER TABLE ONLY marts.dim_canal_pago
    ADD CONSTRAINT pk_dim_canal_pago PRIMARY KEY (canal_pago_key);

-- Name: dim_cliente pk_dim_cliente; Type: CONSTRAINT; Schema: marts; Owner: -

ALTER TABLE ONLY marts.dim_cliente
    ADD CONSTRAINT pk_dim_cliente PRIMARY KEY (cliente_key);

-- Name: dim_fecha pk_dim_fecha; Type: CONSTRAINT; Schema: marts; Owner: -

ALTER TABLE ONLY marts.dim_fecha
    ADD CONSTRAINT pk_dim_fecha PRIMARY KEY (fecha_key);

-- Name: dim_producto pk_dim_producto; Type: CONSTRAINT; Schema: marts; Owner: -

ALTER TABLE ONLY marts.dim_producto
    ADD CONSTRAINT pk_dim_producto PRIMARY KEY (producto_key);

-- Name: dim_promocion pk_dim_promocion; Type: CONSTRAINT; Schema: marts; Owner: -

ALTER TABLE ONLY marts.dim_promocion
    ADD CONSTRAINT pk_dim_promocion PRIMARY KEY (promocion_key);

-- Name: dim_proveedor pk_dim_proveedor; Type: CONSTRAINT; Schema: marts; Owner: -

ALTER TABLE ONLY marts.dim_proveedor
    ADD CONSTRAINT pk_dim_proveedor PRIMARY KEY (proveedor_key);

-- Name: dim_sucursal pk_dim_sucursal; Type: CONSTRAINT; Schema: marts; Owner: -

ALTER TABLE ONLY marts.dim_sucursal
    ADD CONSTRAINT pk_dim_sucursal PRIMARY KEY (sucursal_key);

-- Name: fact_devoluciones pk_fact_devoluciones; Type: CONSTRAINT; Schema: marts; Owner: -

ALTER TABLE ONLY marts.fact_devoluciones
    ADD CONSTRAINT pk_fact_devoluciones PRIMARY KEY (devolucion_key);

-- Name: fact_inventario pk_fact_inventario; Type: CONSTRAINT; Schema: marts; Owner: -

ALTER TABLE ONLY marts.fact_inventario
    ADD CONSTRAINT pk_fact_inventario PRIMARY KEY (inventario_key);

-- Name: fact_metas_ventas pk_fact_metas_ventas; Type: CONSTRAINT; Schema: marts; Owner: -

ALTER TABLE ONLY marts.fact_metas_ventas
    ADD CONSTRAINT pk_fact_metas_ventas PRIMARY KEY (meta_key);

-- Name: fact_precios_proveedor pk_fact_precios_proveedor; Type: CONSTRAINT; Schema: marts; Owner: -

ALTER TABLE ONLY marts.fact_precios_proveedor
    ADD CONSTRAINT pk_fact_precios_proveedor PRIMARY KEY (precio_key);

-- Name: fact_ventas pk_fact_ventas; Type: CONSTRAINT; Schema: marts; Owner: -

ALTER TABLE ONLY marts.fact_ventas
    ADD CONSTRAINT pk_fact_ventas PRIMARY KEY (detalle_key);

-- Name: fact_devoluciones fk_fact_devoluciones_cliente_key; Type: FK CONSTRAINT; Schema: marts; Owner: -

ALTER TABLE ONLY marts.fact_devoluciones
    ADD CONSTRAINT fk_fact_devoluciones_cliente_key FOREIGN KEY (cliente_key) REFERENCES marts.dim_cliente(cliente_key);

-- Name: fact_devoluciones fk_fact_devoluciones_fecha_key; Type: FK CONSTRAINT; Schema: marts; Owner: -

ALTER TABLE ONLY marts.fact_devoluciones
    ADD CONSTRAINT fk_fact_devoluciones_fecha_key FOREIGN KEY (fecha_key) REFERENCES marts.dim_fecha(fecha_key);

-- Name: fact_devoluciones fk_fact_devoluciones_producto_key; Type: FK CONSTRAINT; Schema: marts; Owner: -

ALTER TABLE ONLY marts.fact_devoluciones
    ADD CONSTRAINT fk_fact_devoluciones_producto_key FOREIGN KEY (producto_key) REFERENCES marts.dim_producto(producto_key);

-- Name: fact_devoluciones fk_fact_devoluciones_sucursal_key; Type: FK CONSTRAINT; Schema: marts; Owner: -

ALTER TABLE ONLY marts.fact_devoluciones
    ADD CONSTRAINT fk_fact_devoluciones_sucursal_key FOREIGN KEY (sucursal_key) REFERENCES marts.dim_sucursal(sucursal_key);

-- Name: fact_inventario fk_fact_inventario_fecha_key; Type: FK CONSTRAINT; Schema: marts; Owner: -

ALTER TABLE ONLY marts.fact_inventario
    ADD CONSTRAINT fk_fact_inventario_fecha_key FOREIGN KEY (fecha_key) REFERENCES marts.dim_fecha(fecha_key);

-- Name: fact_inventario fk_fact_inventario_producto_key; Type: FK CONSTRAINT; Schema: marts; Owner: -

ALTER TABLE ONLY marts.fact_inventario
    ADD CONSTRAINT fk_fact_inventario_producto_key FOREIGN KEY (producto_key) REFERENCES marts.dim_producto(producto_key);

-- Name: fact_inventario fk_fact_inventario_sucursal_key; Type: FK CONSTRAINT; Schema: marts; Owner: -

ALTER TABLE ONLY marts.fact_inventario
    ADD CONSTRAINT fk_fact_inventario_sucursal_key FOREIGN KEY (sucursal_key) REFERENCES marts.dim_sucursal(sucursal_key);

-- Name: fact_metas_ventas fk_fact_metas_ventas_fecha_key; Type: FK CONSTRAINT; Schema: marts; Owner: -

ALTER TABLE ONLY marts.fact_metas_ventas
    ADD CONSTRAINT fk_fact_metas_ventas_fecha_key FOREIGN KEY (fecha_key) REFERENCES marts.dim_fecha(fecha_key);

-- Name: fact_metas_ventas fk_fact_metas_ventas_sucursal_key; Type: FK CONSTRAINT; Schema: marts; Owner: -

ALTER TABLE ONLY marts.fact_metas_ventas
    ADD CONSTRAINT fk_fact_metas_ventas_sucursal_key FOREIGN KEY (sucursal_key) REFERENCES marts.dim_sucursal(sucursal_key);

-- Name: fact_precios_proveedor fk_fact_precios_proveedor_fecha_vigencia_key; Type: FK CONSTRAINT; Schema: marts; Owner: -

ALTER TABLE ONLY marts.fact_precios_proveedor
    ADD CONSTRAINT fk_fact_precios_proveedor_fecha_vigencia_key FOREIGN KEY (fecha_vigencia_key) REFERENCES marts.dim_fecha(fecha_key);

-- Name: fact_precios_proveedor fk_fact_precios_proveedor_producto_key; Type: FK CONSTRAINT; Schema: marts; Owner: -

ALTER TABLE ONLY marts.fact_precios_proveedor
    ADD CONSTRAINT fk_fact_precios_proveedor_producto_key FOREIGN KEY (producto_key) REFERENCES marts.dim_producto(producto_key);

-- Name: fact_precios_proveedor fk_fact_precios_proveedor_proveedor_key; Type: FK CONSTRAINT; Schema: marts; Owner: -

ALTER TABLE ONLY marts.fact_precios_proveedor
    ADD CONSTRAINT fk_fact_precios_proveedor_proveedor_key FOREIGN KEY (proveedor_key) REFERENCES marts.dim_proveedor(proveedor_key);

-- Name: fact_ventas fk_fact_ventas_canal_pago_key; Type: FK CONSTRAINT; Schema: marts; Owner: -

ALTER TABLE ONLY marts.fact_ventas
    ADD CONSTRAINT fk_fact_ventas_canal_pago_key FOREIGN KEY (canal_pago_key) REFERENCES marts.dim_canal_pago(canal_pago_key);

-- Name: fact_ventas fk_fact_ventas_cliente_key; Type: FK CONSTRAINT; Schema: marts; Owner: -

ALTER TABLE ONLY marts.fact_ventas
    ADD CONSTRAINT fk_fact_ventas_cliente_key FOREIGN KEY (cliente_key) REFERENCES marts.dim_cliente(cliente_key);

-- Name: fact_ventas fk_fact_ventas_fecha_key; Type: FK CONSTRAINT; Schema: marts; Owner: -

ALTER TABLE ONLY marts.fact_ventas
    ADD CONSTRAINT fk_fact_ventas_fecha_key FOREIGN KEY (fecha_key) REFERENCES marts.dim_fecha(fecha_key);

-- Name: fact_ventas fk_fact_ventas_producto_key; Type: FK CONSTRAINT; Schema: marts; Owner: -

ALTER TABLE ONLY marts.fact_ventas
    ADD CONSTRAINT fk_fact_ventas_producto_key FOREIGN KEY (producto_key) REFERENCES marts.dim_producto(producto_key);

-- Name: fact_ventas fk_fact_ventas_promocion_key; Type: FK CONSTRAINT; Schema: marts; Owner: -

ALTER TABLE ONLY marts.fact_ventas
    ADD CONSTRAINT fk_fact_ventas_promocion_key FOREIGN KEY (promocion_key) REFERENCES marts.dim_promocion(promocion_key);

-- Name: fact_ventas fk_fact_ventas_sucursal_key; Type: FK CONSTRAINT; Schema: marts; Owner: -

ALTER TABLE ONLY marts.fact_ventas
    ADD CONSTRAINT fk_fact_ventas_sucursal_key FOREIGN KEY (sucursal_key) REFERENCES marts.dim_sucursal(sucursal_key);

\unrestrict oeeOmi0MoSyya58zRRqKnLzg1pl0kWK0JsdlPvAM56MDi6XJhLwcEgCBI3pQBob

