FROM apache/airflow:3.3.2

USER airflow

RUN pip install --no-cache-dir python-dotenv openpyxl psycopg2-binary asyncpg

RUN python -m venv /home/airflow/dbt-venv \
 && /home/airflow/dbt-venv/bin/pip install --no-cache-dir "dbt-postgres>=1.10,<2"
