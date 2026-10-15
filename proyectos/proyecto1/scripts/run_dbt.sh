#!/usr/bin/env bash

# run_dbt.sh — ejecuta dbt con las credenciales del .env (aislamiento de conexión)
# Uso: bash scripts/run_dbt.sh <build|run|test|docs|debug|staging|marts>
#   build   : run + test de todos los modelos en orden de dependencias (default)
#   staging : solo la capa staging           
# marts : solo marts (+ sus dependencias)
#   docs    : genera la documentación y la sirve en http://localhost:8080
# Airflow usará este mismo script (BashOperator) o el comando dbt directo.


set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [ -f "$ROOT/.env" ]; then set -a; . "$ROOT/.env"; set +a; fi   # exporta DW_* para profiles.yml
cd "$ROOT/dbt/sgfood_dw"
CMD="${1:-build}"
case "$CMD" in
  build)   dbt build   --profiles-dir . ;;
  run)     dbt run     --profiles-dir . ;;
  test)    dbt test    --profiles-dir . ;;
  debug)   dbt debug   --profiles-dir . ;;
  staging) dbt build   --profiles-dir . --select staging ;;
  marts)   dbt build   --profiles-dir . --select +marts ;;
  docs)    dbt docs generate --profiles-dir . && dbt docs serve --profiles-dir . --port 8080 ;;
  *) echo "Comando desconocido: $CMD"; exit 2 ;;
esac
