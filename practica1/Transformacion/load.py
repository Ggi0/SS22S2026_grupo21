"""
load.py
-------
FASE 3: CARGA

Toma los DataFrames ya limpios (salida de transform.py) y los carga en
VuelosBI (SQL Server) respetando el modelo en estrella de
BaseDatos/database.sql:

  1. Carga cada dimension con patron "get or create": si el valor de
     negocio (ej. codigo_iata, passenger_id) ya existe, no lo vuelve a
     insertar; si no existe, lo inserta y obtiene la surrogate key nueva.
  2. Una vez todas las dimensiones tienen su surrogate key resuelta,
     arma la tabla de hechos reemplazando las claves de negocio por las
     surrogate keys (aerolinea_key, aeropuerto_key, etc.) y la inserta
     con executemany en un solo batch por eficiencia.

Usa SQLAlchemy + pyodbc, tal como sugiere el enunciado de la practica.
"""

import sys

import pandas as pd
from sqlalchemy import create_engine, text

from config import get_connection_string
from logger import get_logger

log = get_logger(__name__)


class LoadError(Exception):
    """Error especifico de la fase de carga."""


def _get_or_create_dim(
    engine, df: pd.DataFrame, table: str, unique_cols: list, key_col: str,
    insert_cols: list = None,
) -> pd.DataFrame:
    """Inserta en `table` las filas de `df` cuya clave de negocio
    (`unique_cols`) no exista todavia, y devuelve `df` con la columna
    `key_col` (surrogate key) agregada para cada fila.

    IMPORTANTE: la comparacion de "ya existe / es nuevo" se hace SOLO por
    `unique_cols` (la clave de negocio real, la que tiene el UNIQUE
    constraint en SQL Server) y no por todas las columnas de la dimension.

    Ademas, la conversion a texto para comparar se hace con CAST del lado
    de SQL Server (no con .astype(str) del lado de pandas). Motivo: segun
    el driver/version de pyodbc, una columna UNIQUEIDENTIFIER puede volver
    a Python como str, como uuid.UUID o incluso como bytes crudos sin
    decodificar -- si vuelve como bytes, str(valor) da una representacion
    binaria que NUNCA coincide con el string del CSV, sin importar cuanto
    se intente normalizar del lado de Python. Pidiendole a SQL Server que
    haga el CAST a NVARCHAR antes de que el dato salga del servidor
    elimina ese problema de raiz, sea cual sea el driver.
    """
    insert_cols = insert_cols or unique_cols
    df = df.copy()

    tmp_cols = [f"__cmp_{c}" for c in unique_cols]
    for col, tmp in zip(unique_cols, tmp_cols):
        df[tmp] = df[col].astype(str).str.strip().str.lower()

    cast_select = ", ".join(
        f"LOWER(LTRIM(RTRIM(CAST({col} AS NVARCHAR(200))))) AS __cmp_{col}" for col in unique_cols
    )

    with engine.begin() as conn:
        existentes = pd.read_sql(text(f"SELECT *, {cast_select} FROM dbo.{table}"), conn)

    nuevos = df.merge(existentes[tmp_cols], on=tmp_cols, how="left", indicator=True)
    nuevos = nuevos[nuevos["_merge"] == "left_only"][insert_cols].drop_duplicates(subset=unique_cols)

    if len(nuevos) > 0:
        nuevos.to_sql(table, engine, schema="dbo", if_exists="append", index=False)
        log.info("  %s: %d filas nuevas insertadas", table, len(nuevos))
    else:
        log.info("  %s: sin filas nuevas (ya existian)", table)

    with engine.begin() as conn:
        actualizados = pd.read_sql(text(f"SELECT *, {cast_select} FROM dbo.{table}"), conn)

    resultado = df.merge(actualizados[[key_col] + tmp_cols], on=tmp_cols, how="left")
    return resultado.drop(columns=tmp_cols)


def load(tables: dict, engine=None) -> None:
    """Carga todas las dimensiones y el hecho en SQL Server.

    `tables` es el dict devuelto por transform.transform().
    `engine` se puede inyectar para pruebas; si no se pasa, se crea uno
    nuevo con la cadena de conexion de config.py.
    """
    if engine is None:
        engine = create_engine(get_connection_string(), fast_executemany=True)

    log.info("Iniciando carga a SQL Server...")

    # --- 1) Dimensiones simples --------------------------------------------
    # unique_cols = la clave de negocio real (la que tiene UNIQUE en SQL Server),
    # usada SOLO para decidir si una fila ya existe. insert_cols = todas las
    # columnas que efectivamente se insertan cuando la fila es nueva.
    dim_aerolinea = _get_or_create_dim(
        engine, tables["dim_aerolinea"], "Dim_Aerolinea",
        unique_cols=["codigo_iata"], key_col="aerolinea_key",
        insert_cols=["codigo_iata", "nombre"],
    )
    dim_aeropuerto = _get_or_create_dim(
        engine, tables["dim_aeropuerto"], "Dim_Aeropuerto",
        unique_cols=["codigo_iata"], key_col="aeropuerto_key",
        insert_cols=["codigo_iata", "nombre", "ciudad", "pais"],
    )
    dim_aeronave = _get_or_create_dim(
        engine, tables["dim_aeronave"], "Dim_Aeronave",
        unique_cols=["tipo_aeronave"], key_col="aeronave_key",
    )
    dim_clase_cabina = _get_or_create_dim(
        engine, tables["dim_clase_cabina"], "Dim_ClaseCabina",
        unique_cols=["nombre_clase"], key_col="clase_cabina_key",
    )
    dim_canal_venta = _get_or_create_dim(
        engine, tables["dim_canal_venta"], "Dim_CanalVenta",
        unique_cols=["nombre_canal"], key_col="canal_venta_key",
    )
    dim_metodo_pago = _get_or_create_dim(
        engine, tables["dim_metodo_pago"], "Dim_MetodoPago",
        unique_cols=["nombre_metodo"], key_col="metodo_pago_key",
    )
    dim_estado_vuelo = _get_or_create_dim(
        engine, tables["dim_estado_vuelo"], "Dim_EstadoVuelo",
        unique_cols=["nombre_estado"], key_col="estado_vuelo_key",
    )
    dim_pasajero = _get_or_create_dim(
        engine, tables["dim_pasajero"], "Dim_Pasajero",
        unique_cols=["passenger_id"], key_col="pasajero_key",
        insert_cols=["passenger_id", "genero", "edad", "nacionalidad"],
    )
    dim_fecha = _get_or_create_dim(
        engine, tables["dim_fecha"], "Dim_Fecha",
        unique_cols=["fecha_key"], key_col="fecha_key",
        insert_cols=["fecha_key", "fecha_completa", "anio", "mes", "nombre_mes",
                     "dia", "trimestre", "nombre_dia", "es_fin_semana"],
    )

    # --- 2) Resolver surrogate keys en el hecho -----------------------------
    fact = tables["fact_vuelos"].copy()

    fact = fact.merge(dim_aerolinea[["codigo_iata", "aerolinea_key"]],
                       left_on="airline_code", right_on="codigo_iata", how="left")

    fact = fact.merge(
        dim_aeropuerto[["codigo_iata", "aeropuerto_key"]].rename(columns={"aeropuerto_key": "aeropuerto_origen_key"}),
        left_on="origin_airport", right_on="codigo_iata", how="left", suffixes=("", "_o"),
    )
    fact = fact.merge(
        dim_aeropuerto[["codigo_iata", "aeropuerto_key"]].rename(columns={"aeropuerto_key": "aeropuerto_destino_key"}),
        left_on="destination_airport", right_on="codigo_iata", how="left", suffixes=("", "_d"),
    )

    fact = fact.merge(dim_aeronave[["tipo_aeronave", "aeronave_key"]],
                       left_on="aircraft_type", right_on="tipo_aeronave", how="left")
    fact = fact.merge(dim_clase_cabina[["nombre_clase", "clase_cabina_key"]],
                       left_on="cabin_class", right_on="nombre_clase", how="left")
    fact = fact.merge(dim_pasajero[["passenger_id", "pasajero_key"]],
                       on="passenger_id", how="left")
    fact = fact.merge(dim_canal_venta[["nombre_canal", "canal_venta_key"]],
                       left_on="sales_channel", right_on="nombre_canal", how="left")
    fact = fact.merge(dim_metodo_pago[["nombre_metodo", "metodo_pago_key"]],
                       left_on="payment_method", right_on="nombre_metodo", how="left")
    fact = fact.merge(dim_estado_vuelo[["nombre_estado", "estado_vuelo_key"]],
                       left_on="status", right_on="nombre_estado", how="left")

    fact_final = fact[[
        "record_id", "aerolinea_key", "aeropuerto_origen_key", "aeropuerto_destino_key",
        "aeronave_key", "clase_cabina_key", "pasajero_key", "canal_venta_key",
        "metodo_pago_key", "estado_vuelo_key", "fecha_salida_key", "fecha_reserva_key",
        "flight_number", "seat", "departure_datetime", "arrival_datetime", "booking_datetime",
        "duration_min", "delay_min", "precio_ticket_original", "moneda_original",
        "precio_ticket_usd", "bags_total", "bags_checked",
    ]].rename(columns={
        "flight_number": "numero_vuelo",
        "seat": "asiento",
        "departure_datetime": "fecha_hora_salida",
        "arrival_datetime": "fecha_hora_llegada",
        "booking_datetime": "fecha_hora_reserva",
        "duration_min": "duracion_min",
        "delay_min": "retraso_min",
        "bags_total": "maletas_total",
        "bags_checked": "maletas_facturadas",
    })

    # Filas que no encontraron alguna FK (dato inconsistente) se excluyen y
    # se reportan; no deben insertarse para no romper la integridad referencial.
    fk_cols = [
        "aerolinea_key", "aeropuerto_origen_key", "aeropuerto_destino_key", "aeronave_key",
        "clase_cabina_key", "pasajero_key", "canal_venta_key", "metodo_pago_key",
        "estado_vuelo_key", "fecha_salida_key", "fecha_reserva_key",
    ]
    incompletas = fact_final[fk_cols].isna().any(axis=1)
    if incompletas.any():
        log.warning(
            "%d filas del hecho se excluyen por FK sin resolver (record_id=%s)",
            incompletas.sum(), fact_final.loc[incompletas, "record_id"].tolist(),
        )
    fact_final = fact_final[~incompletas]

    # --- 3) Insertar solo los record_id que todavia no existen (carga incremental) --
    with engine.begin() as conn:
        ya_cargados = pd.read_sql(text("SELECT record_id FROM dbo.Fact_Vuelos"), conn)

    fact_final = fact_final[~fact_final["record_id"].isin(ya_cargados["record_id"])]

    if len(fact_final) == 0:
        log.info("No hay registros nuevos que cargar en Fact_Vuelos (ya estaban cargados).")
        return

    fact_final.to_sql("Fact_Vuelos", engine, schema="dbo", if_exists="append", index=False)
    log.info("Carga completa: %d filas nuevas insertadas en Fact_Vuelos", len(fact_final))


if __name__ == "__main__":
    # Permite probar la carga de forma aislada: python load.py
    from extract import extract
    from transform import transform

    try:
        load(transform(extract()))
    except Exception as exc:
        log.error("Fallo la carga: %s", exc)
        sys.exit(1)