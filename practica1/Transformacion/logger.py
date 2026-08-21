"""
logger.py
---------
Configuracion centralizada de logging para todo el proceso ETL.
Escribe simultaneamente a consola y a un archivo en logs/etl.log,
con rotacion diaria implicita por timestamp en cada corrida.
"""

import logging
import sys
from datetime import datetime
from config import LOG_DIR


def get_logger(name: str) -> logging.Logger:
    logger = logging.getLogger(name)
    if logger.handlers:
        # Evita duplicar handlers si get_logger se llama varias veces
        return logger

    logger.setLevel(logging.DEBUG)

    formatter = logging.Formatter(
        "%(asctime)s | %(levelname)-8s | %(name)s | %(message)s",
        datefmt="%Y-%m-%d %H:%M:%S",
    )

    # Handler de consola
    console_handler = logging.StreamHandler(sys.stdout)
    console_handler.setLevel(logging.INFO)
    console_handler.setFormatter(formatter)

    # Handler de archivo (una corrida = un archivo, para trazabilidad)
    log_file = LOG_DIR / f"etl_{datetime.now().strftime('%Y%m%d_%H%M%S')}.log"
    file_handler = logging.FileHandler(log_file, encoding="utf-8")
    file_handler.setLevel(logging.DEBUG)
    file_handler.setFormatter(formatter)

    logger.addHandler(console_handler)
    logger.addHandler(file_handler)

    return logger
