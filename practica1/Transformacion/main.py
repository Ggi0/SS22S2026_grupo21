
import sys
import time

from extract import extract, ExtractionError
from transform import transform
from load import load, LoadError
from logger import get_logger

log = get_logger("main")


def run_etl() -> int:
    inicio = time.time()
    log.info("          INICIO DEL PROCESO ETL - VuelosBI")

    try:
        log.info("[1/3] Extraccion...")
        df_crudo = extract()

        log.info("[2/3] Transformacion...")
        tablas = transform(df_crudo)

        log.info("[3/3] Carga a SQL Server...")
        load(tablas)

    except ExtractionError as e:
        log.error("El proceso se detuvo en la fase de EXTRACCION: %s", e)
        return 1
    except LoadError as e:
        log.error("El proceso se detuvo en la fase de CARGA: %s", e)
        return 1
    except Exception as e:
        # Cualquier error no anticipado tambien queda registrado en el log
        log.exception("Error inesperado durante el ETL: %s", e)
        return 1

    duracion = time.time() - inicio
    log.info("      PROCESO ETL FINALIZADO CORRECTAMENTE en %.2f segundos", duracion)
    return 0


if __name__ == "__main__":
    sys.exit(run_etl())
