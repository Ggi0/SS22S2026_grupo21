-- 01_schemas.sql — Crea los schemas del Data Warehouse (arquitectura por capas)

--   raw          datos tal cual llegan de la fuente (todo TEXT) — lo escribe Python
--   staging      limpieza, tipado y banderas de calidad  — lo construye dbt
--   intermediate uniones/reglas de negocio reutilizables — lo construye dbt
--   marts        modelo dimensional + analítica — lo construye dbt

CREATE SCHEMA IF NOT EXISTS raw;
CREATE SCHEMA IF NOT EXISTS staging;
CREATE SCHEMA IF NOT EXISTS intermediate;
CREATE SCHEMA IF NOT EXISTS marts;
