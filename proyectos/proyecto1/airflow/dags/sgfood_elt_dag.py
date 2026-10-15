from __future__ import annotations

import logging
import os
import sys
from datetime import timedelta

import pendulum
from airflow.providers.standard.operators.bash import BashOperator
from airflow.providers.standard.operators.python import PythonOperator
from airflow.sdk import DAG, Param

log = logging.getLogger(__name__)

PROJECT_DIR = os.getenv("SGFOOD_PROJECT_DIR", "/opt/airflow/project")   
DBT_DIR = f"{PROJECT_DIR}/dbt/sgfood_dw"                                   
DBT_BIN = os.getenv("DBT_BIN", "dbt")                                      
ARTIFACTS_DIR = os.getenv("SGFOOD_ARTIFACTS_DIR", "/opt/airflow/artifacts")  

sys.path.insert(0, f"{PROJECT_DIR}/src")

DBT_FLAGS = (
    f'--profiles-dir "{DBT_DIR}" '
    f'--target-path "{ARTIFACTS_DIR}/dbt_target" '
    f'--log-path "{ARTIFACTS_DIR}/dbt_logs"'
)


def dbt_command(subcommand: str) -> str:
    """Arma el comando bash de dbt. `set -e` hace que cualquier error falle la tarea."""
    return f'set -e; cd "{DBT_DIR}"; "{DBT_BIN}" {subcommand} {DBT_FLAGS}'


def _init_dw() -> None:
    """Crea schemas raw/staging/intermediate/marts y tablas raw (idempotente)."""
    from sgfood_etl import pipeline
    pipeline.init_warehouse()


def _cargar_oltp_fuente(**context) -> str:
    """SOLO DESARROLLO: instala sgfood_oltp.sql en la BD fuente.

    Se ejecuta únicamente si al disparar el DAG se marca el parámetro
    `cargar_oltp_dev = true`. En una corrida normal (OLTP ya existente) no hace nada.
    """
    if not context["params"]["cargar_oltp_dev"]:
        log.info("cargar_oltp_dev = false -> se omite la instalación del OLTP de prueba.")
        return "omitido"
    from sgfood_etl import pipeline
    pipeline.load_oltp_source()
    return "cargado"


def _extract_load_oltp(batch_id: str) -> dict:
    """OLTP -> raw.oltp_*. Devuelve {tabla: filas} (queda en XCom como evidencia)."""
    from sgfood_etl import pipeline
    return pipeline.extract_load_oltp(batch_id=batch_id)


def _extract_load_files(batch_id: str) -> dict:
    """CSV/XLSX -> raw.csv_* / raw.xlsx_*. Devuelve {tabla: filas}."""
    from sgfood_etl import pipeline
    return pipeline.extract_load_files(batch_id=batch_id)


def _apply_constraints() -> None:
    """Agrega PK/FK al modelo estrella (dbt recrea las tablas, así que va después)."""
    from sgfood_etl import pipeline
    pipeline.apply_constraints()


def _validate_sql() -> None:
    """Ejecuta sql/validation/*.sql. Si alguna validación da 'FALLA', la tarea falla."""
    from sgfood_etl import pipeline
    fallas = pipeline.validate()
    if fallas:
        raise ValueError(f"Validaciones SQL con falla: {fallas}. Revise el log de la tarea.")


default_args = {
    "owner": "sgfood",
    "retries": 1,                          # un reintento ante fallas transitorias (BD ocupada, red)
    "retry_delay": timedelta(minutes=2),
}

with DAG(
    dag_id="sgfood_elt",
    description="SG-Food: fuentes -> Python -> RAW -> dbt STAGING -> dbt MARTS -> validaciones",
    doc_md=__doc__,
    schedule="0 2 * * *",                  
    start_date=pendulum.datetime(2026, 10, 1, tz="America/Guatemala"),
    catchup=False,                         
    max_active_runs=1,                  
    is_paused_upon_creation=True,         
    default_args=default_args,
    params={
        "cargar_oltp_dev": Param(
            False, type="boolean",
            description="Solo desarrollo: instalar sgfood_oltp.sql en la BD fuente antes de extraer.",
        ),
    },
    tags=["sgfood", "elt", "dbt", "seminario2"],
) as dag:

    init_dw = PythonOperator(task_id="init_dw", python_callable=_init_dw)

    cargar_oltp_fuente = PythonOperator(
        task_id="cargar_oltp_fuente", python_callable=_cargar_oltp_fuente)

    extract_load_oltp = PythonOperator(
        task_id="extract_load_oltp",
        python_callable=_extract_load_oltp,
        op_kwargs={"batch_id": "{{ run_id }}"},
    )
    extract_load_files = PythonOperator(
        task_id="extract_load_files",
        python_callable=_extract_load_files,
        op_kwargs={"batch_id": "{{ run_id }}"},
    )

    dbt_run_staging = BashOperator(
        task_id="dbt_run_staging",
        bash_command=dbt_command("run --select staging"),
    )
    dbt_run_marts = BashOperator(
        task_id="dbt_run_marts",
        bash_command=dbt_command("run --select intermediate marts"),
    )

    apply_constraints = PythonOperator(
        task_id="apply_constraints", python_callable=_apply_constraints)

    dbt_test = BashOperator(task_id="dbt_test", bash_command=dbt_command("test"))
    validate_sql = PythonOperator(task_id="validate_sql", python_callable=_validate_sql)

    dbt_docs = BashOperator(task_id="dbt_docs", bash_command=dbt_command("docs generate"))

    (
        init_dw
        >> cargar_oltp_fuente
        >> [extract_load_oltp, extract_load_files]
        >> dbt_run_staging
        >> dbt_run_marts
        >> apply_constraints
        >> dbt_test
        >> validate_sql
        >> dbt_docs
    )
