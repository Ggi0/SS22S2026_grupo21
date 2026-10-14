# Makefile — atajos para ejecutar cada etapa del pipeline 
# Uso:  make <objetivo>      (make help lista los objetivos)

PY      := PYTHONPATH=src python -m sgfood_etl
DBT_DIR := dbt/sgfood_dw

help:            ## Lista los objetivos
	@grep -E '^[a-z_-]+:.*##' Makefile | sed 's/:.*##/ -> /'

init:            ## 1) Crea schemas raw/staging/intermediate/marts y tablas raw
	$(PY) init-dw

oltp:            ## 2) (solo desarrollo) Carga sgfood_oltp.sql en la BD fuente
	$(PY) load-oltp-source

extract-load:    ## 3) Python: extrae OLTP + archivos y carga schema raw
	$(PY) extract-load

dbt-build:       ## 4) dbt: staging -> marts + pruebas
	bash scripts/run_dbt.sh build

constraints:     ## 5) Aplica PK/FK del modelo estrella
	$(PY) apply-constraints

validate:        ## 6) Consultas de validación (conteos, integridad)
	$(PY) validate

docs:            ## dbt docs generate + serve (http://localhost:8080)
	bash scripts/run_dbt.sh docs

all:             ## Ejecuta 1..6 en orden
	bash scripts/run_all.sh
