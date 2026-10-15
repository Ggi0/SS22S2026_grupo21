"""__main__.py — interfaz de línea de comandos del paquete.

Uso:  PYTHONPATH=src python -m sgfood_etl <comando>

Comandos:
    init-dw            crea schemas y tablas raw
    load-oltp-source   (dev) instala sgfood_oltp.sql en la BD fuente
    extract-load       OLTP + CSV/XLSX -> raw
    apply-constraints  PK/FK del modelo estrella (después de dbt)
    validate           consultas de validación (sql/validation)

Cada comando es solo una llamada a una función de pipeline.py; Airflow usará
esas mismas funciones.
"""
from __future__ import annotations

import argparse
import logging
import sys

from . import pipeline

COMMANDS = {
    "init-dw": pipeline.init_warehouse,
    "load-oltp-source": pipeline.load_oltp_source,
    "extract-load": pipeline.extract_load_all,
    "apply-constraints": pipeline.apply_constraints,
    "validate": pipeline.validate,
}


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(prog="sgfood_etl", description=__doc__,
                                     formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("command", choices=COMMANDS)
    parser.add_argument("-v", "--verbose", action="store_true")
    args = parser.parse_args(argv)
    logging.basicConfig(level=logging.DEBUG if args.verbose else logging.INFO,
                        format="%(asctime)s %(levelname)-7s %(name)s: %(message)s")
    result = COMMANDS[args.command]()
    if isinstance(result, dict):
        print(f"Total de filas cargadas: {sum(result.values())}")
    return 1 if (args.command == "validate" and result) else 0


if __name__ == "__main__":
    sys.exit(main())
