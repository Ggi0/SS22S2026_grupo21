"""load.py — carga (L de ELT) de lotes de texto al schema raw.

Responsabilidad:
    * Descubrir las columnas de una tabla raw (el DDL es la fuente de verdad).
    * Hacer TRUNCATE + INSERT dentro de UNA transacción (si algo falla, la
      tabla conserva su carga anterior: la carga es atómica e idempotente).
    * Estampar trazabilidad: _batch_id (corrida) y _source_file (origen).
"""
from __future__ import annotations

import logging
from typing import Iterable, Sequence

from psycopg2 import sql
from psycopg2.extras import execute_values

from .registry import META_COLUMNS, RAW_SCHEMA

log = logging.getLogger(__name__)


def raw_columns(conn, table: str) -> list[str]:
    """Columnas de datos de raw.<table> (sin columnas de control), en orden."""
    with conn.cursor() as cur:
        cur.execute(
            """SELECT column_name FROM information_schema.columns
               WHERE table_schema = %s AND table_name = %s
               ORDER BY ordinal_position""",
            (RAW_SCHEMA, table),
        )
        cols = [r[0] for r in cur.fetchall() if r[0] not in META_COLUMNS]
    if not cols:
        raise RuntimeError(
            f"La tabla {RAW_SCHEMA}.{table} no existe. Ejecute primero: init-dw")
    return cols


def load_table(conn, table: str, columns: Sequence[str],
               batches: Iterable[list[tuple]], batch_id: str, source_file: str) -> int:
    """Reemplaza el contenido de raw.<table>. Devuelve filas insertadas."""
    target = sql.SQL("{}.{}").format(sql.Identifier(RAW_SCHEMA), sql.Identifier(table))
    all_cols = list(columns) + ["_batch_id", "_source_file"]
    insert = sql.SQL("INSERT INTO {t} ({c}) VALUES %s").format(
        t=target, c=sql.SQL(", ").join(sql.Identifier(c) for c in all_cols))
    total = 0
    try:
        with conn.cursor() as cur:
            cur.execute(sql.SQL("TRUNCATE TABLE {}").format(target))
            insert_sql = insert.as_string(cur)
            for batch in batches:
                rows = [tuple(r) + (batch_id, source_file) for r in batch]
                execute_values(cur, insert_sql, rows, page_size=1000)
                total += len(rows)
        conn.commit()
    except Exception:
        conn.rollback()
        raise
    log.info("raw.%-26s %6d filas  (lote %s)", table, total, batch_id)
    return total
