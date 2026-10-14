"""config.py — ÚNICA fuente de configuración del código Python.

Responsabilidad:
    Leer el archivo ``.env`` (o las variables de entorno reales, p. ej. las que
    inyectará Docker/Airflow) y exponerlas como objetos tipados.

Por qué existe:
    Aísla las credenciales. Cambiar de PostgreSQL local a Docker o a la nube
    implica editar únicamente ``.env``; ningún otro módulo conoce hosts/usuarios.
"""
from __future__ import annotations

import os
from dataclasses import dataclass
from pathlib import Path

from dotenv import load_dotenv

# Raíz del proyecto = carpeta Proyecto1 (dos niveles arriba de este archivo).
ROOT: Path = Path(__file__).resolve().parents[2]

# Las variables ya definidas en el entorno tienen prioridad sobre el .env
# (así Airflow/Docker pueden sobreescribirlas sin tocar archivos).
load_dotenv(ROOT / ".env", override=False)


def _env(name: str, default: str = "") -> str:
    """Devuelve la variable de entorno; si está vacía o no existe, el default."""
    value = os.getenv(name, "")
    return value if value.strip() != "" else default


@dataclass(frozen=True)
class DbSettings:
    """Parámetros de conexión a una instancia PostgreSQL."""

    host: str
    port: int
    dbname: str
    user: str
    password: str
    sslmode: str

    def psycopg2_kwargs(self) -> dict:
        """Argumentos listos para ``psycopg2.connect(**kwargs)``."""
        return {
            "host": self.host,
            "port": self.port,
            "dbname": self.dbname,
            "user": self.user,
            "password": self.password,
            "sslmode": self.sslmode,
        }


@dataclass(frozen=True)
class Settings:
    """Configuración completa del pipeline."""

    dw: DbSettings                 # destino (raw / staging / marts)
    src: DbSettings                # fuente OLTP
    src_schema: str                # schema del OLTP dentro de la fuente
    oltp_sql_file: Path            # script sgfood_oltp.sql (solo desarrollo)
    files_dir: Path                # carpeta con CSV/XLSX
    csv_delimiter: str
    null_tokens: frozenset[str]    # textos que se interpretan como NULL


def _abs(path_str: str) -> Path:
    """Convierte rutas relativas del .env en rutas absolutas desde la raíz."""
    p = Path(path_str)
    return p if p.is_absolute() else ROOT / p


def load_settings() -> Settings:
    """Construye ``Settings`` desde el entorno. Se llama una vez por proceso."""
    dw = DbSettings(
        host=_env("DW_HOST", "localhost"),
        port=int(_env("DW_PORT", "5432")),
        dbname=_env("POSTGRES_DB", "sgfood_dw"),
        user=_env("POSTGRES_USER", "postgres"),
        password=_env("POSTGRES_PASSWORD", ""),
        sslmode=_env("DW_SSLMODE", "prefer"),
    )
    # La fuente hereda del DW todo lo que no se defina explícitamente.
    src = DbSettings(
        host=_env("SRC_HOST", dw.host),
        port=int(_env("SRC_PORT", str(dw.port))),
        dbname=_env("SRC_DB", dw.dbname),
        user=_env("SRC_USER", dw.user),
        password=_env("SRC_PASSWORD", dw.password),
        sslmode=_env("SRC_SSLMODE", dw.sslmode),
    )
    tokens = [t for t in _env("NULL_TOKENS", "NULL,null,\\N,NaN,None").split(",") if t]
    return Settings(
        dw=dw,
        src=src,
        src_schema=_env("SRC_SCHEMA", "oltp_sgfood"),
        oltp_sql_file=_abs(_env("OLTP_SQL_FILE", "data/oltp/sgfood_oltp.sql")),
        files_dir=_abs(_env("FILES_DIR", "data/files")),
        csv_delimiter=_env("CSV_DELIMITER", ","),
        null_tokens=frozenset(tokens),
    )
