"""registry.py — catálogo de qué se extrae y a qué tabla raw va.

Responsabilidad:
    Declarar (en un solo lugar) las entidades del OLTP y los archivos de entrada
    con su tabla destino en ``raw``. Agregar una fuente nueva = agregar una línea
    aquí + su tabla en sql/ddl/02_raw_tables.sql.

Convención de nombres en raw:
    oltp_<tabla>   datos de la BD transaccional
    csv_<archivo>  archivos delimitados
    xlsx_<archivo> hojas de cálculo
"""
from __future__ import annotations

from dataclasses import dataclass

RAW_SCHEMA = "raw"

# Columnas de control que agrega la carga (no vienen de la fuente).
META_COLUMNS = ("_batch_id", "_loaded_at", "_source_file")

# Orden respeta dependencias lógicas (solo informativo; raw no tiene FKs).
OLTP_TABLES: tuple[str, ...] = (
    "sucursal", "categoria", "marca", "producto", "cliente", "venta", "venta_detalle",
)


@dataclass(frozen=True)
class FileSource:
    """Un archivo de entrada y su tabla destino en raw."""

    filename: str
    raw_table: str
    kind: str  # 'csv' | 'xlsx'


FILE_SOURCES: tuple[FileSource, ...] = (
    FileSource("inventario_bodega.csv", "csv_inventario_bodega", "csv"),
    FileSource("proveedores_precios.csv", "csv_proveedores_precios", "csv"),
    FileSource("promociones.csv", "csv_promociones", "csv"),
    FileSource("metas_ventas.csv", "csv_metas_ventas", "csv"),
    FileSource("devoluciones.csv", "csv_devoluciones", "csv"),
    FileSource("casos_calidad_opcionales.csv", "csv_casos_calidad", "csv"),
    FileSource("catalogo_insumos_sgfood.xlsx", "xlsx_catalogo_insumos", "xlsx"),
)


def oltp_raw_table(table: str) -> str:
    """Nombre de la tabla raw para una tabla del OLTP."""
    return f"oltp_{table}"
