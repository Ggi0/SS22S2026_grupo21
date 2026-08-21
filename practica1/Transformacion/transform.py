"""
transform.py
------------
FASE 2: TRANSFORMACION

Limpia, homologa y estandariza los datos crudos del vuelo, y los deja
listos en forma de "tablas" (DataFrames) que representan exactamente las
dimensiones y el hecho del modelo en estrella de BaseDatos/database.sql.

Problemas de calidad de datos detectados en el CSV fuente y su solucion:

1. Fechas en DOS formatos distintos dentro de la misma columna:
     - "20/01/2024 10:14"        -> DD/MM/AAAA, 24 horas
     - "03-15-2025 01:58 PM"     -> MM-DD-AAAA, 12 horas AM/PM
   Se distinguen por el separador y la presencia de AM/PM.

2. Codigos de aeropuerto en minuscula ("jfk", "cun") -> se normalizan a
   mayuscula.

3. Nombre de aerolinea inconsistente para el mismo codigo IATA
   ("Ryanair" / "RYANAIR", "American Airlines" / "AMERICAN AIRLINES" /
   "aa0848" con codigo de vuelo en minuscula) -> se homologa usando
   config.AIRLINE_CATALOG por codigo IATA (fuente de verdad = codigo).

4. Genero del pasajero con distintas representaciones
   ("M"/"F"/"X"/"m"/"f"/"Masculino"/"Femenino") -> se homologa a
   M / F / X.

5. Precio del ticket con separador decimal de coma en vez de punto
   ("77,60") -> se convierte a notacion con punto.

6. Valores nulos legitimos en vuelos CANCELLED (arrival_datetime,
   duration_min, delay_min vacios) -> se conservan como NULL, no se
   inventan valores.

7. numero de vuelo en minuscula ("aa0848") -> se normaliza a mayuscula.
"""

import re
from datetime import datetime

import numpy as np
import pandas as pd

from config import AIRLINE_CATALOG, AIRPORT_CATALOG
from logger import get_logger

log = get_logger(__name__)

_AMPM_RE = re.compile(r"(AM|PM)\s*$", re.IGNORECASE)

_GENDER_MAP = {
    "M": "M", "F": "F", "X": "X",
    "MASCULINO": "M", "FEMENINO": "F",
}


def _parse_datetime(value):
    """Convierte un string de fecha en datetime, soportando los dos
    formatos detectados en el CSV fuente. Devuelve pd.NaT si no se
    puede interpretar (y lo registra para revision)."""
    if pd.isna(value):
        return pd.NaT

    v = str(value).strip()
    if not v:
        return pd.NaT

    try:
        if _AMPM_RE.search(v):
            return datetime.strptime(v, "%m-%d-%Y %I:%M %p")
        return datetime.strptime(v, "%d/%m/%Y %H:%M")
    except ValueError:
        # Formatos alternos de respaldo, por si aparecen variantes
        for fmt in ("%m-%d-%Y %H:%M", "%d-%m-%Y %H:%M", "%m/%d/%Y %H:%M",
                     "%d/%m/%Y %I:%M %p"):
            try:
                return datetime.strptime(v, fmt)
            except ValueError:
                continue
        log.warning("Fecha no reconocida, se descarta: '%s'", v)
        return pd.NaT


def _parse_price(value):
    """Convierte el precio a float, soportando coma decimal ('77,60')."""
    if pd.isna(value):
        return np.nan
    v = str(value).strip()
    if "," in v and "." not in v:
        v = v.replace(",", ".")
    try:
        return float(v)
    except ValueError:
        log.warning("Precio no valido, se descarta: '%s'", value)
        return np.nan


def _normalize_gender(value):
    if pd.isna(value):
        return "X"
    key = str(value).strip().upper()
    return _GENDER_MAP.get(key, "X")


def _canonical_airline_name(code, fallback_name):
    code = str(code).strip().upper()
    if code in AIRLINE_CATALOG:
        return AIRLINE_CATALOG[code]
    # Codigo desconocido: se usa el nombre tal cual venga, en formato titulo
    return str(fallback_name).strip().title() if pd.notna(fallback_name) else code


def transform(raw_df: pd.DataFrame) -> dict:
    """Aplica limpieza y devuelve un dict de DataFrames listos para carga:
    {
      'dim_aerolinea', 'dim_aeropuerto', 'dim_aeronave', 'dim_clase_cabina',
      'dim_canal_venta', 'dim_metodo_pago', 'dim_estado_vuelo',
      'dim_pasajero', 'fact_vuelos'
    }
    """
    df = raw_df.copy()
    n_inicial = len(df)
    log.info("Iniciando transformacion de %d registros", n_inicial)

    # --- Tipos numericos basicos -------------------------------------------------
    df["record_id"] = pd.to_numeric(df["record_id"], errors="coerce").astype("Int64")
    df["duration_min"] = pd.to_numeric(df["duration_min"], errors="coerce")
    df["delay_min"] = pd.to_numeric(df["delay_min"], errors="coerce").fillna(0)
    df["passenger_age"] = pd.to_numeric(df["passenger_age"], errors="coerce")
    df["bags_total"] = pd.to_numeric(df["bags_total"], errors="coerce").fillna(0).astype(int)
    df["bags_checked"] = pd.to_numeric(df["bags_checked"], errors="coerce").fillna(0).astype(int)

    # Filas sin record_id no se pueden trazar -> se descartan y se registran
    sin_id = df["record_id"].isna().sum()
    if sin_id:
        log.warning("Se descartan %d filas sin record_id valido", sin_id)
    df = df.dropna(subset=["record_id"])

    # --- Fechas --------------------------------------------------------------
    df["departure_datetime"] = df["departure_datetime"].apply(_parse_datetime)
    df["arrival_datetime"] = df["arrival_datetime"].apply(_parse_datetime)
    df["booking_datetime"] = df["booking_datetime"].apply(_parse_datetime)

    # Un vuelo debe tener fecha de salida y de reserva validas para ser util
    # analiticamente; si faltan, se descarta y se deja constancia en el log.
    invalidas = df["departure_datetime"].isna() | df["booking_datetime"].isna()
    if invalidas.any():
        log.warning(
            "Se descartan %d filas con fecha de salida/reserva invalida (record_id=%s)",
            invalidas.sum(), df.loc[invalidas, "record_id"].tolist(),
        )
    df = df[~invalidas]

    # Chequeo de consistencia: llegada anterior a salida -> anomalia de origen,
    # se anula la llegada (no se descarta el vuelo completo) y se deja log.
    llegada_antes = df["arrival_datetime"].notna() & (df["arrival_datetime"] < df["departure_datetime"])
    if llegada_antes.any():
        log.warning(
            "%d vuelos con arrival_datetime anterior a departure_datetime; se anula la llegada (record_id=%s)",
            llegada_antes.sum(), df.loc[llegada_antes, "record_id"].tolist(),
        )
        df.loc[llegada_antes, "arrival_datetime"] = pd.NaT

    # --- Texto: codigos de aeropuerto, numero de vuelo, asiento ---------------
    df["origin_airport"] = df["origin_airport"].str.strip().str.upper()
    df["destination_airport"] = df["destination_airport"].str.strip().str.upper()
    df["flight_number"] = df["flight_number"].str.strip().str.upper()
    df["seat"] = df["seat"].str.strip().str.upper()
    df["airline_code"] = df["airline_code"].str.strip().str.upper()
    df["status"] = df["status"].str.strip().str.upper()
    df["cabin_class"] = df["cabin_class"].str.strip().str.upper()
    df["sales_channel"] = df["sales_channel"].str.strip().str.upper()
    df["payment_method"] = df["payment_method"].str.strip().str.upper()
    df["aircraft_type"] = df["aircraft_type"].str.strip().str.upper()
    df["currency"] = df["currency"].str.strip().str.upper()
    df["passenger_nationality"] = df["passenger_nationality"].str.strip().str.upper()

    # Campos categoricos vacios en el CSV fuente (ej. sales_channel="" en
    # algunas filas -> queda como NaN tras el parseo). Si se dejan como NaN,
    # Dim_CanalVenta (y las demas dimensiones categoricas) nunca registran
    # ese valor, el merge de load.py no encuentra la FK correspondiente, y
    # la fila COMPLETA del hecho se descarta -> se pierde un vuelo valido
    # solo porque le faltaba un dato categorico. En vez de perder el vuelo,
    # se homologa el vacio a la categoria explicita "SIN_DATO".
    columnas_categoricas_con_default = [
        "aircraft_type", "cabin_class", "sales_channel", "payment_method", "status",
    ]
    for col in columnas_categoricas_con_default:
        faltantes = df[col].isna().sum()
        if faltantes:
            log.warning("%d filas con '%s' vacio se homologan a 'SIN_DATO'", faltantes, col)
        df[col] = df[col].fillna("SIN_DATO")

    # --- Homologaciones especificas -------------------------------------------
    df["airline_name_clean"] = df.apply(
        lambda r: _canonical_airline_name(r["airline_code"], r["airline_name"]), axis=1
    )
    df["passenger_gender_clean"] = df["passenger_gender"].apply(_normalize_gender)
    df["ticket_price_clean"] = df["ticket_price"].apply(_parse_price)
    df["ticket_price_usd_clean"] = df["ticket_price_usd_est"].apply(_parse_price)

    # Precio invalido -> no se puede calcular ingreso, se descarta la fila
    precio_invalido = df["ticket_price_clean"].isna() | df["ticket_price_usd_clean"].isna()
    if precio_invalido.any():
        log.warning("Se descartan %d filas con precio invalido", precio_invalido.sum())
    df = df[~precio_invalido]

    # Edad fuera de rango razonable -> se deja como NULL en vez de descartar el vuelo
    edad_invalida = df["passenger_age"].notna() & ((df["passenger_age"] < 0) | (df["passenger_age"] > 120))
    if edad_invalida.any():
        log.warning("%d edades fuera de rango se marcan como NULL", edad_invalida.sum())
        df.loc[edad_invalida, "passenger_age"] = np.nan

    log.info("Transformacion de columnas terminada. Filas resultantes: %d (de %d)", len(df), n_inicial)

    # =====================================================================
    # Construccion de DIMENSIONES (deduplicadas)
    # =====================================================================

    dim_aerolinea = (
        df[["airline_code", "airline_name_clean"]]
        .drop_duplicates(subset=["airline_code"])
        .rename(columns={"airline_code": "codigo_iata", "airline_name_clean": "nombre"})
        .reset_index(drop=True)
    )

    aeropuertos = pd.unique(pd.concat([df["origin_airport"], df["destination_airport"]]))
    dim_aeropuerto = pd.DataFrame({"codigo_iata": aeropuertos})
    dim_aeropuerto["nombre"] = dim_aeropuerto["codigo_iata"].map(lambda c: AIRPORT_CATALOG.get(c, (None, None, None))[0])
    dim_aeropuerto["ciudad"] = dim_aeropuerto["codigo_iata"].map(lambda c: AIRPORT_CATALOG.get(c, (None, None, None))[1])
    dim_aeropuerto["pais"] = dim_aeropuerto["codigo_iata"].map(lambda c: AIRPORT_CATALOG.get(c, (None, None, None))[2])

    dim_aeronave = pd.DataFrame({"tipo_aeronave": df["aircraft_type"].dropna().unique()})
    dim_clase_cabina = pd.DataFrame({"nombre_clase": df["cabin_class"].dropna().unique()})
    dim_canal_venta = pd.DataFrame({"nombre_canal": df["sales_channel"].dropna().unique()})
    dim_metodo_pago = pd.DataFrame({"nombre_metodo": df["payment_method"].dropna().unique()})
    dim_estado_vuelo = pd.DataFrame({"nombre_estado": df["status"].dropna().unique()})

    dim_pasajero = (
        df[["passenger_id", "passenger_gender_clean", "passenger_age", "passenger_nationality"]]
        .drop_duplicates(subset=["passenger_id"])
        .rename(columns={
            "passenger_gender_clean": "genero",
            "passenger_age": "edad",
            "passenger_nationality": "nacionalidad",
        })
        .reset_index(drop=True)
    )

    # =====================================================================
    # Dimension Fecha (a partir de todas las fechas de salida y reserva)
    # =====================================================================
    todas_fechas = pd.concat([
        df["departure_datetime"].dt.normalize(),
        df["booking_datetime"].dt.normalize(),
    ]).dropna().unique()

    dim_fecha = pd.DataFrame({"fecha_completa": pd.to_datetime(todas_fechas)})
    dim_fecha["fecha_key"] = dim_fecha["fecha_completa"].dt.strftime("%Y%m%d").astype(int)
    dim_fecha["anio"] = dim_fecha["fecha_completa"].dt.year
    dim_fecha["mes"] = dim_fecha["fecha_completa"].dt.month
    dim_fecha["nombre_mes"] = dim_fecha["fecha_completa"].dt.month_name()
    dim_fecha["dia"] = dim_fecha["fecha_completa"].dt.day
    dim_fecha["trimestre"] = dim_fecha["fecha_completa"].dt.quarter
    dim_fecha["nombre_dia"] = dim_fecha["fecha_completa"].dt.day_name()
    dim_fecha["es_fin_semana"] = dim_fecha["fecha_completa"].dt.dayofweek >= 5
    dim_fecha = dim_fecha.sort_values("fecha_key").reset_index(drop=True)

    # =====================================================================
    # Tabla de HECHOS (las FK reales a surrogate keys se resuelven en load.py,
    # aqui se dejan las claves de negocio necesarias para hacer el merge)
    # =====================================================================
    fact_vuelos = df[[
        "record_id", "airline_code", "origin_airport", "destination_airport",
        "aircraft_type", "cabin_class", "passenger_id", "sales_channel",
        "payment_method", "status", "flight_number", "seat",
        "departure_datetime", "arrival_datetime", "booking_datetime",
        "duration_min", "delay_min", "ticket_price_clean", "currency",
        "ticket_price_usd_clean", "bags_total", "bags_checked",
    ]].rename(columns={
        "ticket_price_clean": "precio_ticket_original",
        "ticket_price_usd_clean": "precio_ticket_usd",
        "currency": "moneda_original",
    }).reset_index(drop=True)

    fact_vuelos["fecha_salida_key"] = fact_vuelos["departure_datetime"].dt.strftime("%Y%m%d").astype(int)
    fact_vuelos["fecha_reserva_key"] = fact_vuelos["booking_datetime"].dt.strftime("%Y%m%d").astype(int)

    log.info(
        "Dimensiones construidas -> aerolineas:%d aeropuertos:%d aeronaves:%d "
        "clases:%d canales:%d pagos:%d estados:%d pasajeros:%d fechas:%d",
        len(dim_aerolinea), len(dim_aeropuerto), len(dim_aeronave), len(dim_clase_cabina),
        len(dim_canal_venta), len(dim_metodo_pago), len(dim_estado_vuelo), len(dim_pasajero), len(dim_fecha),
    )
    log.info("Hecho construido: %d filas listas para cargar", len(fact_vuelos))

    return {
        "dim_aerolinea": dim_aerolinea,
        "dim_aeropuerto": dim_aeropuerto,
        "dim_aeronave": dim_aeronave,
        "dim_clase_cabina": dim_clase_cabina,
        "dim_canal_venta": dim_canal_venta,
        "dim_metodo_pago": dim_metodo_pago,
        "dim_estado_vuelo": dim_estado_vuelo,
        "dim_pasajero": dim_pasajero,
        "dim_fecha": dim_fecha,
        "fact_vuelos": fact_vuelos,
    }


if __name__ == "__main__":
    # Permite probar la transformacion de forma aislada: python transform.py
    from extract import extract
    resultado = transform(extract())
    for nombre, tabla in resultado.items():
        print(f"\n--- {nombre} ({len(tabla)} filas) ---")
        print(tabla.head(3))