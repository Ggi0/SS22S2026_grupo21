

IF DB_ID('VuelosBI') IS NULL
BEGIN
    CREATE DATABASE VuelosBI;
END
GO

USE VuelosBI;
GO

/* 
   Limpieza (permite re-ejecutar el script sin errores)
*/
IF OBJECT_ID('dbo.Fact_Vuelos', 'U') IS NOT NULL DROP TABLE dbo.Fact_Vuelos;
IF OBJECT_ID('dbo.Dim_Pasajero', 'U') IS NOT NULL DROP TABLE dbo.Dim_Pasajero;
IF OBJECT_ID('dbo.Dim_Aerolinea', 'U') IS NOT NULL DROP TABLE dbo.Dim_Aerolinea;
IF OBJECT_ID('dbo.Dim_Aeropuerto', 'U') IS NOT NULL DROP TABLE dbo.Dim_Aeropuerto;
IF OBJECT_ID('dbo.Dim_Aeronave', 'U') IS NOT NULL DROP TABLE dbo.Dim_Aeronave;
IF OBJECT_ID('dbo.Dim_ClaseCabina', 'U') IS NOT NULL DROP TABLE dbo.Dim_ClaseCabina;
IF OBJECT_ID('dbo.Dim_CanalVenta', 'U') IS NOT NULL DROP TABLE dbo.Dim_CanalVenta;
IF OBJECT_ID('dbo.Dim_MetodoPago', 'U') IS NOT NULL DROP TABLE dbo.Dim_MetodoPago;
IF OBJECT_ID('dbo.Dim_EstadoVuelo', 'U') IS NOT NULL DROP TABLE dbo.Dim_EstadoVuelo;
IF OBJECT_ID('dbo.Dim_Fecha', 'U') IS NOT NULL DROP TABLE dbo.Dim_Fecha;
GO

/* 
                       DIMENSIONES
*/

-- Dimension Aerolinea 
CREATE TABLE dbo.Dim_Aerolinea (
    aerolinea_key   INT IDENTITY(1,1) PRIMARY KEY,
    codigo_iata     VARCHAR(3)  NOT NULL,
    nombre          VARCHAR(100) NOT NULL,
    CONSTRAINT UQ_Aerolinea_Codigo UNIQUE (codigo_iata)
);
GO

-- Dimension Aeropuerto (usada dos veces en el hecho: origen y destino)
CREATE TABLE dbo.Dim_Aeropuerto (
    aeropuerto_key  INT IDENTITY(1,1) PRIMARY KEY,
    codigo_iata     VARCHAR(3)  NOT NULL,
    nombre          VARCHAR(150) NULL,
    ciudad          VARCHAR(100) NULL,
    pais            VARCHAR(100) NULL,
    CONSTRAINT UQ_Aeropuerto_Codigo UNIQUE (codigo_iata)
);
GO

-- Dimension Aeronave ---
CREATE TABLE dbo.Dim_Aeronave (
    aeronave_key    INT IDENTITY(1,1) PRIMARY KEY,
    tipo_aeronave   VARCHAR(20) NOT NULL,
    CONSTRAINT UQ_Aeronave_Tipo UNIQUE (tipo_aeronave)
);
GO

-- Dimension Clase de Cabina 
CREATE TABLE dbo.Dim_ClaseCabina (
    clase_cabina_key INT IDENTITY(1,1) PRIMARY KEY,
    nombre_clase     VARCHAR(30) NOT NULL,
    CONSTRAINT UQ_ClaseCabina UNIQUE (nombre_clase)
);
GO

-- Dimension Canal de Venta 
CREATE TABLE dbo.Dim_CanalVenta (
    canal_venta_key INT IDENTITY(1,1) PRIMARY KEY,
    nombre_canal    VARCHAR(30) NOT NULL,
    CONSTRAINT UQ_CanalVenta UNIQUE (nombre_canal)
);
GO

-- Dimension Metodo de Pago 
CREATE TABLE dbo.Dim_MetodoPago (
    metodo_pago_key INT IDENTITY(1,1) PRIMARY KEY,
    nombre_metodo   VARCHAR(30) NOT NULL,
    CONSTRAINT UQ_MetodoPago UNIQUE (nombre_metodo)
);
GO

-- Dimension Estado del Vuelo
CREATE TABLE dbo.Dim_EstadoVuelo (
    estado_vuelo_key INT IDENTITY(1,1) PRIMARY KEY,
    nombre_estado    VARCHAR(20) NOT NULL,
    CONSTRAINT UQ_EstadoVuelo UNIQUE (nombre_estado)
);
GO

-- Dimension Pasajero 
-- Clave de negocio (passenger_id, UUID de la fuente) para evitar duplicar
-- pasajeros que aparecen en varios vuelos.
CREATE TABLE dbo.Dim_Pasajero (
    pasajero_key    INT IDENTITY(1,1) PRIMARY KEY,
    passenger_id    UNIQUEIDENTIFIER NOT NULL,
    genero          CHAR(1) NOT NULL,           -- 'M','F','X'
    edad            SMALLINT NULL,
    nacionalidad    CHAR(2)  NULL,              -- codigo ISO pais
    CONSTRAINT UQ_Pasajero_PassengerId UNIQUE (passenger_id),
    CONSTRAINT CK_Pasajero_Genero CHECK (genero IN ('M','F','X')),
    CONSTRAINT CK_Pasajero_Edad CHECK (edad IS NULL OR edad BETWEEN 0 AND 120)
);
GO

-- Dimension Fecha 
-- Se usa con "roles": el hecho la referencia una vez para fecha de salida
-- y otra vez para fecha de reserva (role-playing dimension).
CREATE TABLE dbo.Dim_Fecha (
    fecha_key       INT PRIMARY KEY,   -- formato YYYYMMDD
    fecha_completa  DATE NOT NULL,
    anio            SMALLINT NOT NULL,
    mes             TINYINT NOT NULL,
    nombre_mes      VARCHAR(15) NOT NULL,
    dia             TINYINT NOT NULL,
    trimestre       TINYINT NOT NULL,
    nombre_dia      VARCHAR(15) NOT NULL,
    es_fin_semana   BIT NOT NULL
);
GO

/* 
                            TABLA DE HECHOS
   Grano: un registro por vuelo/boleto (record_id de la fuente).
*/
CREATE TABLE dbo.Fact_Vuelos (
    vuelo_key           BIGINT IDENTITY(1,1) PRIMARY KEY,
    record_id           INT NOT NULL,   -- clave de negocio (fuente CSV)

    -- Claves foraneas a dimensiones
    aerolinea_key        INT NOT NULL REFERENCES dbo.Dim_Aerolinea(aerolinea_key),
    aeropuerto_origen_key      INT NOT NULL REFERENCES dbo.Dim_Aeropuerto(aeropuerto_key),
    aeropuerto_destino_key     INT NOT NULL REFERENCES dbo.Dim_Aeropuerto(aeropuerto_key),
    aeronave_key          INT NOT NULL REFERENCES dbo.Dim_Aeronave(aeronave_key),
    clase_cabina_key       INT NOT NULL REFERENCES dbo.Dim_ClaseCabina(clase_cabina_key),
    pasajero_key          INT NOT NULL REFERENCES dbo.Dim_Pasajero(pasajero_key),
    canal_venta_key       INT NOT NULL REFERENCES dbo.Dim_CanalVenta(canal_venta_key),
    metodo_pago_key       INT NOT NULL REFERENCES dbo.Dim_MetodoPago(metodo_pago_key),
    estado_vuelo_key       INT NOT NULL REFERENCES dbo.Dim_EstadoVuelo(estado_vuelo_key),
    fecha_salida_key      INT NOT NULL REFERENCES dbo.Dim_Fecha(fecha_key),
    fecha_reserva_key      INT NOT NULL REFERENCES dbo.Dim_Fecha(fecha_key),

    -- Dimensiones degeneradas (viven en el hecho, no ameritan tabla propia)
    numero_vuelo         VARCHAR(10) NOT NULL,
    asiento             VARCHAR(6) NULL,

    -- Marcas de tiempo completas (para calculos de duracion exacta)
    fecha_hora_salida       DATETIME2 NOT NULL,
    fecha_hora_llegada       DATETIME2 NULL,
    fecha_hora_reserva       DATETIME2 NOT NULL,

    -- Metricas (hechos aditivos y semi-aditivos)
    duracion_min          SMALLINT NULL,
    retraso_min           SMALLINT NULL,
    precio_ticket_original    DECIMAL(10,2) NOT NULL,
    moneda_original        CHAR(3) NOT NULL,
    precio_ticket_usd       DECIMAL(10,2) NOT NULL,
    maletas_total          TINYINT NOT NULL DEFAULT 0,
    maletas_facturadas       TINYINT NOT NULL DEFAULT 0,

    CONSTRAINT UQ_Fact_RecordId UNIQUE (record_id)
);
GO

-- Indices para acelerar las consultas analiticas mas comunes
CREATE INDEX IX_Fact_AerolineaKey ON dbo.Fact_Vuelos(aerolinea_key);
CREATE INDEX IX_Fact_DestinoKey ON dbo.Fact_Vuelos(aeropuerto_destino_key);
CREATE INDEX IX_Fact_OrigenKey ON dbo.Fact_Vuelos(aeropuerto_origen_key);
CREATE INDEX IX_Fact_FechaSalidaKey ON dbo.Fact_Vuelos(fecha_salida_key);
CREATE INDEX IX_Fact_PasajeroKey ON dbo.Fact_Vuelos(pasajero_key);
CREATE INDEX IX_Fact_EstadoVueloKey ON dbo.Fact_Vuelos(estado_vuelo_key);
GO

/* 
   El ETL en Python inserta/actualiza estas dimensiones automaticamente
   (patron "get or create"), por lo que estos INSERT no son obligatorios,
   pero se dejan como referencia / para pruebas manuales del modelo.
*/

INSERT INTO dbo.Dim_EstadoVuelo (nombre_estado) VALUES ('ON_TIME'), ('DELAYED'), ('CANCELLED');
GO

INSERT INTO dbo.Dim_ClaseCabina (nombre_clase) VALUES ('ECONOMY'), ('PREMIUM_ECONOMY'), ('BUSINESS');
GO

INSERT INTO dbo.Dim_CanalVenta (nombre_canal) VALUES ('APP'), ('WEB'), ('AEROPUERTO'), ('CALL_CENTER'), ('AGENCIA');
GO

INSERT INTO dbo.Dim_MetodoPago (nombre_metodo) VALUES ('EFECTIVO'), ('TARJETA'), ('TRANSFERENCIA'), ('PAYPAL'), ('PUNTOS');
GO
