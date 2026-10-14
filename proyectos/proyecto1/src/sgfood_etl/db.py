"""
db.py — ÚNICO módulo que abre conexiones a PostgreSQL.

    Entregar conexiones psycopg2 al DW o a la fuente OLTP y ejecutar archivos .sql.
"""
from __future__ import annotations

import logging
from pathlib import Path
from typing import Literal

import psycopg2

from .config import Settings

log = logging.getLogger(__name__)

Role = Literal["dw", "src"]


def connect(settings: Settings, role: Role = "dw"):
    """Abre una conexión. ``role='dw'`` -> Data Warehouse; ``'src'`` -> fuente OLTP."""
    cfg = settings.dw if role == "dw" else settings.src
    log.debug("Conectando a %s:%s/%s como %s (%s)", cfg.host, cfg.port, cfg.dbname, cfg.user, role)
    return psycopg2.connect(**cfg.psycopg2_kwargs())


def run_sql_file(conn, path: Path) -> None:
    """Ejecuta un archivo .sql completo (varias sentencias) en una transacción."""
    sql_text = path.read_text(encoding="utf-8")
    with conn.cursor() as cur:
        cur.execute(sql_text)
    conn.commit()
    log.info("SQL ejecutado: %s", path.name)
