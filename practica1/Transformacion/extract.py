
import glob
import sys

import pandas as pd

from config import DATA_DIR, SOURCE_FILES_PATTERN
from logger import get_logger

log = get_logger(__name__)

EXPECTED_COLUMNS = [
    "record_id",          "airline_code",     "airline_name", 
    "flight_number",      "origin_airport",   "destination_airport", 
    "departure_datetime", "arrival_datetime", "duration_min", 
    "status",             "delay_min",        "aircraft_type", 
    "cabin_class",        "seat",             "passenger_id",
    "passenger_gender",   "passenger_age",    "passenger_nationality",
    "booking_datetime",   "sales_channel",    "payment_method",
    "ticket_price",       "currency",         "ticket_price_usd_est",
    "bags_total",         "bags_checked",
]


class ExtractionError(Exception):
    """Error especifico de la fase de extraccion."""


def extract() -> pd.DataFrame:
    """Extrae y concatena todos los CSV encontrados en data/.

    Retorna un DataFrame crudo (sin limpiar) con una columna adicional
    'source_file' para trazabilidad de origen de cada registro.
    """
    files = sorted(glob.glob(str(DATA_DIR / SOURCE_FILES_PATTERN)))

    if not files:
        raise ExtractionError(f"No se encontraron archivos CSV en {DATA_DIR}")

    log.info("Archivos fuente encontrados: %s", files)

    frames = []
    for file_path in files:
        try:
            df = pd.read_csv(file_path, dtype=str, keep_default_na=True)
        except Exception as exc:
            log.error("No se pudo leer %s: %s", file_path, exc)
            raise ExtractionError(f"Error leyendo {file_path}") from exc

        missing_cols = set(EXPECTED_COLUMNS) - set(df.columns)
        if missing_cols:
            raise ExtractionError(
                f"El archivo {file_path} no tiene las columnas esperadas: {missing_cols}"
            )

        df["source_file"] = file_path
        frames.append(df)
        log.info("  -> %s: %d filas leidas", file_path, len(df))

    raw_df = pd.concat(frames, ignore_index=True)

    # Deduplicado basico por record_id (misma fuente duplicada por error)
    before = len(raw_df)
    raw_df = raw_df.drop_duplicates(subset=["record_id"], keep="first")
    if before != len(raw_df):
        log.warning("Se eliminaron %d filas duplicadas por record_id", before - len(raw_df))

    log.info("Extraccion completa: %d registros crudos en total", len(raw_df))
    return raw_df


if __name__ == "__main__":
    # Permite probar la extraccion de forma aislada: python extract.py
    try:
        df = extract()
        print(df.head())
        print(f"\nTotal filas extraidas: {len(df)}")
    except ExtractionError as e:
        log.error("Fallo la extraccion: %s", e)
        sys.exit(1)
