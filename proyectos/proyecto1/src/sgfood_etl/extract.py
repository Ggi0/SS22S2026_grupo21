"""extract.py — lectura (E de ELT) de las fuentes. NO transforma el negocio.

Responsabilidad:
    Convertir cada fuente en lotes (listas) de tuplas de TEXTO alineadas con las
    columnas de la tabla raw destino.

Convención NULL vs VACÍO (requisito del proyecto, se conserva hasta staging):
    * NULL  -> dato ausente. En CSV: el campo trae un token de ``NULL_TOKENS``
               (NULL, null, \\N, NaN, None). En Excel: celda realmente vacía.
               En OLTP: valor NULL de la base de datos.
    * VACÍO -> el campo existe pero contiene cadena vacía "" (o solo espacios).
    Raw guarda ambos tal cual; dbt los distingue (macro ``estado_dato``).
"""
from __future__ import annotations

import csv
import logging
import re
import unicodedata
from pathlib import Path
from typing import Iterator, Sequence

import openpyxl
from psycopg2 import sql

log = logging.getLogger(__name__)

BATCH_SIZE = 5000


def _to_text(value):
    """Valor Python -> texto raw. None se conserva como NULL."""
    if value is None:
        return None
    if isinstance(value, bool):
        return "true" if value else "false"
    return str(value)


def _normalize_header(name: str) -> str:
    """'Entidad/Archivo' -> 'entidad_archivo' (minúsculas, sin tildes, con _)."""
    name = unicodedata.normalize("NFKD", str(name)).encode("ascii", "ignore").decode()
    return re.sub(r"[^a-z0-9]+", "_", name.strip().lower()).strip("_")


# --------------------------------------------------------------------------- #
# OLTP
# --------------------------------------------------------------------------- #
def extract_oltp(conn, schema: str, table: str, columns: Sequence[str]) -> Iterator[list[tuple]]:
    """Lee una tabla del OLTP con cursor del lado del servidor, por lotes."""
    query = sql.SQL("SELECT {cols} FROM {sch}.{tab}").format(
        cols=sql.SQL(", ").join(sql.Identifier(c) for c in columns),
        sch=sql.Identifier(schema),
        tab=sql.Identifier(table),
    )
    with conn.cursor(name=f"extract_{table}") as cur:
        cur.itersize = BATCH_SIZE
        cur.execute(query)
        while True:
            rows = cur.fetchmany(BATCH_SIZE)
            if not rows:
                break
            yield [tuple(_to_text(v) for v in r) for r in rows]
    conn.commit()


# --------------------------------------------------------------------------- #
# CSV
# --------------------------------------------------------------------------- #
def read_csv(path: Path, columns: Sequence[str], delimiter: str,
             null_tokens: frozenset[str]) -> Iterator[list[tuple]]:
    """Lee un CSV (UTF-8, con o sin BOM) y entrega lotes alineados a ``columns``."""
    with path.open(newline="", encoding="utf-8-sig") as fh:
        reader = csv.reader(fh, delimiter=delimiter)
        header = [_normalize_header(h) for h in next(reader)]
        missing = [c for c in columns if c not in header]
        if missing:
            raise ValueError(f"{path.name}: faltan columnas {missing}. Encabezado: {header}")
        extra = [h for h in header if h not in columns]
        if extra:
            log.warning("%s: columnas ignoradas (no existen en raw): %s", path.name, extra)
        idx = [header.index(c) for c in columns]

        batch: list[tuple] = []
        for row in reader:
            if not row:                       # línea completamente en blanco
                continue
            values = []
            for i in idx:
                cell = row[i] if i < len(row) else None   # fila corta -> NULL
                if cell is not None and cell.strip() in null_tokens:
                    cell = None                           # token NULL -> NULL real
                values.append(cell)                       # "" se queda como ""
            batch.append(tuple(values))
            if len(batch) >= BATCH_SIZE:
                yield batch
                batch = []
        if batch:
            yield batch


# --------------------------------------------------------------------------- #
# XLSX
# --------------------------------------------------------------------------- #
def read_xlsx(path: Path, columns: Sequence[str]) -> Iterator[list[tuple]]:
    """Lee la primera hoja de un .xlsx.

    Soporta dos formas: columnas normales, o una sola columna cuyo texto viene
    separado por ';' (como se ve en el catálogo de insumos).
    Celda vacía -> NULL;  texto "" -> VACÍO.
    """
    wb = openpyxl.load_workbook(path, read_only=True, data_only=True)
    rows = wb.worksheets[0].iter_rows(values_only=True)
    raw_header = next(rows)
    non_empty = [h for h in raw_header if h is not None]
    packed = len(non_empty) == 1 and ";" in str(non_empty[0])

    def expand(row):
        if not packed:
            return list(row)
        cell = row[0]
        if cell is None:
            return [None] * len(columns)
        return str(cell).split(";", len(columns) - 1)

    header = [_normalize_header(h) for h in expand(raw_header)]
    missing = [c for c in columns if c not in header]
    if missing:
        raise ValueError(f"{path.name}: faltan columnas {missing}. Encabezado: {header}")
    idx = [header.index(c) for c in columns]

    batch: list[tuple] = []
    for row in rows:
        cells = expand(row)
        if all(c is None for c in cells):
            continue
        batch.append(tuple(_to_text(cells[i]) if i < len(cells) else None for i in idx))
        if len(batch) >= BATCH_SIZE:
            yield batch
            batch = []
    if batch:
        yield batch
    wb.close()
