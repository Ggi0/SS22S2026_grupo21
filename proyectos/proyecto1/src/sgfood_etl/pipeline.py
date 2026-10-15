"""pipeline.py — funciones de alto nivel del pipeline Python.

Responsabilidad:
    Orquestar (en el sentido simple de "llamar en orden") extract.py + load.py
    y las utilerías de DDL/validación. Cada función es independiente y
    devuelve datos serializables, de modo que luego Airflow pueda usarlas
    directamente como ``python_callable`` de un PythonOperator
    (una tarea por función).
"""
from __future__ import annotations

import logging
from datetime import datetime, timezone

from . import extract, load
from .config import ROOT, Settings, load_settings
from .db import connect, run_sql_file
from .registry import FILE_SOURCES, OLTP_TABLES, oltp_raw_table

log = logging.getLogger(__name__)

SQL_DIR = ROOT / "sql"


def new_batch_id() -> str:
    """Identificador de corrida: timestamp UTC (ej. 20261012T153000Z)."""
    return datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")


# ------------------------------- preparación ------------------------------- #
def init_warehouse(settings: Settings | None = None) -> None:
    """Crea schemas (raw, staging, intermediate, marts) y tablas raw. Idempotente."""
    s = settings or load_settings()
    conn = connect(s, "dw")
    try:
        run_sql_file(conn, SQL_DIR / "ddl" / "01_schemas.sql")
        run_sql_file(conn, SQL_DIR / "ddl" / "02_raw_tables.sql")
    finally:
        conn.close()


def load_oltp_source(settings: Settings | None = None) -> None:
    """SOLO DESARROLLO: instala sgfood_oltp.sql en la BD fuente.

    En un entorno real el OLTP ya existe y este paso se omite.
    """
    s = settings or load_settings()
    if not s.oltp_sql_file.exists():
        raise FileNotFoundError(f"No existe {s.oltp_sql_file}")
    conn = connect(s, "src")
    try:
        run_sql_file(conn, s.oltp_sql_file)
    finally:
        conn.close()


# ---------------------------- extracción + carga ---------------------------- #
def extract_load_oltp(batch_id: str | None = None, settings: Settings | None = None) -> dict:
    """OLTP -> raw.oltp_*. Devuelve {tabla_raw: filas}."""
    s = settings or load_settings()
    batch_id = batch_id or new_batch_id()
    result: dict[str, int] = {}
    src, dw = connect(s, "src"), connect(s, "dw")
    try:
        for table in OLTP_TABLES:
            raw_table = oltp_raw_table(table)
            cols = load.raw_columns(dw, raw_table)
            batches = extract.extract_oltp(src, s.src_schema, table, cols)
            result[raw_table] = load.load_table(
                dw, raw_table, cols, batches, batch_id, f"{s.src_schema}.{table}")
    finally:
        src.close()
        dw.close()
    return result


def extract_load_files(batch_id: str | None = None, settings: Settings | None = None) -> dict:
    """CSV/XLSX -> raw.csv_* / raw.xlsx_*. Devuelve {tabla_raw: filas}."""
    s = settings or load_settings()
    batch_id = batch_id or new_batch_id()
    result: dict[str, int] = {}
    dw = connect(s, "dw")
    try:
        for fs in FILE_SOURCES:
            path = s.files_dir / fs.filename
            if not path.exists():
                raise FileNotFoundError(f"Falta el archivo de entrada: {path}")
            cols = load.raw_columns(dw, fs.raw_table)
            if fs.kind == "csv":
                batches = extract.read_csv(path, cols, s.csv_delimiter, s.null_tokens)
            else:
                batches = extract.read_xlsx(path, cols)
            result[fs.raw_table] = load.load_table(
                dw, fs.raw_table, cols, batches, batch_id, fs.filename)
    finally:
        dw.close()
    return result


def extract_load_all(settings: Settings | None = None) -> dict:
    """Ejecuta OLTP + archivos con el mismo batch_id."""
    s = settings or load_settings()
    batch_id = new_batch_id()
    out = extract_load_oltp(batch_id, s)
    out.update(extract_load_files(batch_id, s))
    return out


# ------------------------- constraints y validación ------------------------- #
def apply_constraints(settings: Settings | None = None) -> None:
    """Aplica PK/FK al modelo estrella construido por dbt (idempotente)."""
    s = settings or load_settings()
    conn = connect(s, "dw")
    try:
        run_sql_file(conn, SQL_DIR / "ddl" / "03_constraints_dw.sql")
    finally:
        conn.close()


def validate(settings: Settings | None = None) -> int:
    """Ejecuta sql/validation/*.sql. Cada archivo devuelve filas
    (check_name, esperado, obtenido, resultado). Retorna # de FALLAS."""
    s = settings or load_settings()
    conn = connect(s, "dw")
    failures = 0
    try:
        for path in sorted((SQL_DIR / "validation").glob("*.sql")):
            with conn.cursor() as cur:
                cur.execute(path.read_text(encoding="utf-8"))
                rows = cur.fetchall()
            conn.commit()
            print(f"\n== {path.name} ==")
            for name, expected, got, status in rows:
                print(f"  [{status:5}] {name:55} esperado={expected} obtenido={got}")
                failures += status == "FALLA"
    finally:
        conn.close()
    print(f"\nValidaciones con falla: {failures}")
    return failures
