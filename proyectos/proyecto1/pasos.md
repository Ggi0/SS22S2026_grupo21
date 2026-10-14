

# creacion de la base de datos

```bash
gio@gio:~/Documentos/26S2/seminario2/proyecto/SS22S2026_grupo21/proyectos/proyecto1$ docker compose up -d
WARN[0000] The "POSTGRES_USER" variable is not set. Defaulting to a blank string. 
WARN[0000] The "POSTGRES_PASSWORD" variable is not set. Defaulting to a blank string. 
WARN[0000] The "POSTGRES_DB" variable is not set. Defaulting to a blank string. 
[+] Running 15/15
 ✔ postgres Pulled                                                                                                           30.1s 
   ✔ ecc510c1e359 Pull complete                                                                                               7.8s 
   ✔ 79faf13a8736 Pull complete                                                                                               7.8s 
   ✔ 6456bfbf35e7 Pull complete                                                                                               8.0s 
   ✔ b353db459ed1 Pull complete                                                                                               8.1s 
   ✔ 99f49de4fe2b Pull complete                                                                                              11.9s 
   ✔ 83d1a2a3917c Pull complete                                                                                              12.0s 
   ✔ 715ea0948cb1 Pull complete                                                                                              12.0s 
   ✔ 486e8305f56f Pull complete                                                                                              12.1s 
   ✔ e7d675f11ded Pull complete                                                                                              28.1s 
   ✔ c49864c27f35 Pull complete                                                                                              28.1s 
   ✔ 770ef8b308ea Pull complete                                                                                              28.2s 
   ✔ 50c25daa0302 Pull complete                                                                                              28.2s 
   ✔ 8309db3ae5b6 Pull complete                                                                                              28.2s 
   ✔ 9731e27f2541 Pull complete                                                                                              28.2s 
[+] Running 3/3
 ✔ Network proyecto1_default         Created                                                                                  0.1s 
 ✔ Volume "proyecto1_postgres_data"  Created                                                                                  0.0s 
 ✔ Container sgfood-postgres         Started                                                                                  0.9s 
gio@gio:~/Documentos/26S2/seminario2/proyecto/SS22S2026_grupo21/proyectos/proyecto1$ 


```


# conexion:
`docker exec -it sgfood-postgres psql -U sgfood -d sgfood_dw`

# verificacion de contenido:

```bash

gio@gio:~/Documentos/26S2/seminario2/proyecto/SS22S2026_grupo21/proyectos/proyecto1$ docker exec -it sgfood-postgres psql -U sgfood -d sgfood_dw
psql (16.15 (Debian 16.15-1.pgdg13+2))
Type "help" for help.

sgfood_dw=# \l
                                                   List of databases
   Name    | Owner  | Encoding | Locale Provider |  Collate   |   Ctype    | ICU Locale | ICU Rules | Access privileges 
-----------+--------+----------+-----------------+------------+------------+------------+-----------+-------------------
 postgres  | sgfood | UTF8     | libc            | en_US.utf8 | en_US.utf8 |            |           | 
 sgfood_dw | sgfood | UTF8     | libc            | en_US.utf8 | en_US.utf8 |            |           | 
 template0 | sgfood | UTF8     | libc            | en_US.utf8 | en_US.utf8 |            |           | =c/sgfood        +
           |        |          |                 |            |            |            |           | sgfood=CTc/sgfood
 template1 | sgfood | UTF8     | libc            | en_US.utf8 | en_US.utf8 |            |           | =c/sgfood        +
           |        |          |                 |            |            |            |           | sgfood=CTc/sgfood
(4 rows)

sgfood_dw=# \c sgfood_dw 
You are now connected to database "sgfood_dw" as user "sgfood".
sgfood_dw=# \dt
Did not find any relations.
sgfood_dw=# 

```



# Despues de ejecutar `Make extract-load`
o sea despues de cargar toda la data a raw 

# hacemos make `dbt-build`
que utiliza directamente `proyectos/proyecto1/scripts/run_dbt.sh`
para cargar los el resto de esquema:

salida:
```bash
(.venv) gio@gio:~/Documentos/26S2/seminario2/proyecto/SS22S2026_grupo21/proyectos/proyecto1$ make dbt-build
bash scripts/run_dbt.sh build
07:23:45  Running with dbt=1.12.5
07:23:45  Registered adapter: postgres=1.11.0
07:23:45  Unable to do partial parsing because saved manifest not found. Starting full parse.
07:23:48  Found 30 models, 104 data tests, 14 sources, 485 macros
07:23:48  
07:23:48  Concurrency: 4 threads (target='dev')
07:23:48  
07:23:48  1 of 134 START sql table model marts.dim_fecha ................................. [RUN]
07:23:48  2 of 134 START sql view model staging.stg_csv__devoluciones .................... [RUN]
07:23:48  3 of 134 START sql view model staging.stg_csv__inventario_bodega ............... [RUN]
07:23:48  4 of 134 START sql view model staging.stg_csv__metas_ventas .................... [RUN]
07:23:49  2 of 134 OK created sql view model staging.stg_csv__devoluciones ............... [CREATE VIEW in 0.41s]
07:23:49  3 of 134 OK created sql view model staging.stg_csv__inventario_bodega .......... [CREATE VIEW in 0.42s]
07:23:49  5 of 134 START sql view model staging.stg_csv__promociones ..................... [RUN]
07:23:49  1 of 134 OK created sql table model marts.dim_fecha ............................ [SELECT 1462 in 0.46s]
07:23:49  4 of 134 OK created sql view model staging.stg_csv__metas_ventas ............... [CREATE VIEW in 0.46s]
07:23:49  6 of 134 START sql view model staging.stg_csv__proveedores_precios ............. [RUN]
07:23:49  7 of 134 START test source_not_null_raw_oltp_categoria_id_categoria ............ [RUN]
07:23:49  8 of 134 START test source_not_null_raw_oltp_cliente_id_cliente ................ [RUN]
07:23:49  8 of 134 PASS source_not_null_raw_oltp_cliente_id_cliente ...................... [PASS in 0.23s]
07:23:49  7 of 134 PASS source_not_null_raw_oltp_categoria_id_categoria .................. [PASS in 0.23s]
07:23:49  9 of 134 START test source_not_null_raw_oltp_marca_id_marca .................... [RUN]
07:23:49  10 of 134 START test source_not_null_raw_oltp_producto_id_producto ............. [RUN]
07:23:49  6 of 134 OK created sql view model staging.stg_csv__proveedores_precios ........ [CREATE VIEW in 0.35s]
07:23:49  5 of 134 OK created sql view model staging.stg_csv__promociones ................ [CREATE VIEW in 0.38s]
07:23:49  11 of 134 START test source_not_null_raw_oltp_sucursal_id_sucursal ............. [RUN]
07:23:49  12 of 134 START test source_not_null_raw_oltp_venta_detalle_id_detalle ......... [RUN]
07:23:49  10 of 134 PASS source_not_null_raw_oltp_producto_id_producto ................... [PASS in 0.15s]
07:23:49  9 of 134 PASS source_not_null_raw_oltp_marca_id_marca .......................... [PASS in 0.16s]
07:23:49  13 of 134 START test source_not_null_raw_oltp_venta_id_venta ................... [RUN]
07:23:49  14 of 134 START test source_unique_raw_oltp_categoria_id_categoria ............. [RUN]
07:23:49  11 of 134 PASS source_not_null_raw_oltp_sucursal_id_sucursal ................... [PASS in 0.11s]
07:23:49  12 of 134 PASS source_not_null_raw_oltp_venta_detalle_id_detalle ............... [PASS in 0.09s]
07:23:49  15 of 134 START test source_unique_raw_oltp_cliente_id_cliente ................. [RUN]
07:23:49  16 of 134 START test source_unique_raw_oltp_marca_id_marca ..................... [RUN]
07:23:49  13 of 134 PASS source_not_null_raw_oltp_venta_id_venta ......................... [PASS in 0.10s]
07:23:49  14 of 134 PASS source_unique_raw_oltp_categoria_id_categoria ................... [PASS in 0.10s]
07:23:49  17 of 134 START test source_unique_raw_oltp_producto_id_producto ............... [RUN]
07:23:49  18 of 134 START test source_unique_raw_oltp_sucursal_id_sucursal ............... [RUN]
07:23:50  16 of 134 PASS source_unique_raw_oltp_marca_id_marca ........................... [PASS in 0.10s]
07:23:50  15 of 134 PASS source_unique_raw_oltp_cliente_id_cliente ....................... [PASS in 0.11s]
07:23:50  19 of 134 START test source_unique_raw_oltp_venta_detalle_id_detalle ........... [RUN]
07:23:50  20 of 134 START test source_unique_raw_oltp_venta_id_venta ..................... [RUN]
07:23:50  17 of 134 PASS source_unique_raw_oltp_producto_id_producto ..................... [PASS in 0.11s]
07:23:50  18 of 134 PASS source_unique_raw_oltp_sucursal_id_sucursal ..................... [PASS in 0.11s]
07:23:50  21 of 134 START test not_null_stg_csv__devoluciones_id_devolucion .............. [RUN]
07:23:50  22 of 134 START test unique_stg_csv__devoluciones_id_devolucion ................ [RUN]
07:23:50  20 of 134 PASS source_unique_raw_oltp_venta_id_venta ........................... [PASS in 0.11s]
07:23:50  19 of 134 PASS source_unique_raw_oltp_venta_detalle_id_detalle ................. [PASS in 0.11s]
07:23:50  23 of 134 START test unique_combination_of_columns_stg_csv__inventario_bodega_fecha_corte__id_sucursal__id_producto  [RUN]
07:23:50  24 of 134 START test not_null_dim_fecha_fecha .................................. [RUN]
07:23:50  21 of 134 PASS not_null_stg_csv__devoluciones_id_devolucion .................... [PASS in 0.11s]
07:23:50  22 of 134 PASS unique_stg_csv__devoluciones_id_devolucion ...................... [PASS in 0.12s]
07:23:50  25 of 134 START test not_null_dim_fecha_fecha_key .............................. [RUN]
07:23:50  26 of 134 START test unique_dim_fecha_fecha .................................... [RUN]
07:23:50  24 of 134 PASS not_null_dim_fecha_fecha ........................................ [PASS in 0.11s]
07:23:50  23 of 134 PASS unique_combination_of_columns_stg_csv__inventario_bodega_fecha_corte__id_sucursal__id_producto  [PASS in 0.12s]
07:23:50  27 of 134 START test unique_dim_fecha_fecha_key ................................ [RUN]
07:23:50  28 of 134 START test accepted_values_stg_csv__proveedores_precios_costo_proveedor_estado__NULO__VACIO__OK  [RUN]
07:23:50  25 of 134 PASS not_null_dim_fecha_fecha_key .................................... [PASS in 0.11s]
07:23:50  26 of 134 PASS unique_dim_fecha_fecha .......................................... [PASS in 0.10s]
07:23:50  29 of 134 START test not_null_stg_csv__promociones_id_promocion ................ [RUN]
07:23:50  30 of 134 START test unique_stg_csv__promociones_id_promocion .................. [RUN]
07:23:50  27 of 134 PASS unique_dim_fecha_fecha_key ...................................... [PASS in 0.10s]
07:23:50  28 of 134 PASS accepted_values_stg_csv__proveedores_precios_costo_proveedor_estado__NULO__VACIO__OK  [PASS in 0.09s]
07:23:50  31 of 134 START sql view model staging.stg_oltp__categoria ..................... [RUN]
07:23:50  32 of 134 START sql view model staging.stg_oltp__marca ......................... [RUN]
07:23:50  29 of 134 PASS not_null_stg_csv__promociones_id_promocion ...................... [PASS in 0.09s]
07:23:50  30 of 134 PASS unique_stg_csv__promociones_id_promocion ........................ [PASS in 0.10s]
07:23:50  33 of 134 START sql view model staging.stg_oltp__cliente ....................... [RUN]
07:23:50  34 of 134 START sql view model staging.stg_oltp__producto ...................... [RUN]
07:23:50  32 of 134 OK created sql view model staging.stg_oltp__marca .................... [CREATE VIEW in 0.12s]
07:23:50  31 of 134 OK created sql view model staging.stg_oltp__categoria ................ [CREATE VIEW in 0.13s]
07:23:50  35 of 134 START sql view model staging.stg_oltp__sucursal ...................... [RUN]
07:23:50  36 of 134 START sql view model staging.stg_oltp__venta ......................... [RUN]
07:23:50  34 of 134 OK created sql view model staging.stg_oltp__producto ................. [CREATE VIEW in 0.15s]
07:23:50  33 of 134 OK created sql view model staging.stg_oltp__cliente .................. [CREATE VIEW in 0.16s]
07:23:50  37 of 134 START sql view model staging.stg_oltp__venta_detalle ................. [RUN]
07:23:50  38 of 134 START sql table model marts.dim_proveedor ............................ [RUN]
07:23:50  35 of 134 OK created sql view model staging.stg_oltp__sucursal ................. [CREATE VIEW in 0.13s]
07:23:50  36 of 134 OK created sql view model staging.stg_oltp__venta .................... [CREATE VIEW in 0.13s]
07:23:50  39 of 134 START test not_null_stg_oltp__marca_id_marca ......................... [RUN]
07:23:50  40 of 134 START test unique_stg_oltp__marca_id_marca ........................... [RUN]
07:23:50  37 of 134 OK created sql view model staging.stg_oltp__venta_detalle ............ [CREATE VIEW in 0.15s]
07:23:50  38 of 134 OK created sql table model marts.dim_proveedor ....................... [SELECT 13 in 0.16s]
07:23:50  41 of 134 START test not_null_stg_oltp__categoria_id_categoria ................. [RUN]
07:23:50  42 of 134 START test unique_stg_oltp__categoria_id_categoria ................... [RUN]
07:23:50  39 of 134 PASS not_null_stg_oltp__marca_id_marca ............................... [PASS in 0.10s]
07:23:50  40 of 134 PASS unique_stg_oltp__marca_id_marca ................................. [PASS in 0.10s]
07:23:50  43 of 134 START test accepted_values_stg_oltp__producto_precio_lista_estado__NULO__VACIO__OK  [RUN]
07:23:50  44 of 134 START test not_null_stg_oltp__producto_id_producto ................... [RUN]
07:23:50  41 of 134 PASS not_null_stg_oltp__categoria_id_categoria ....................... [PASS in 0.10s]
07:23:50  45 of 134 START test unique_stg_oltp__producto_id_producto ..................... [RUN]
07:23:50  42 of 134 PASS unique_stg_oltp__categoria_id_categoria ......................... [PASS in 0.11s]
07:23:50  46 of 134 START test not_null_stg_oltp__cliente_id_cliente ..................... [RUN]
07:23:50  43 of 134 PASS accepted_values_stg_oltp__producto_precio_lista_estado__NULO__VACIO__OK  [PASS in 0.11s]
07:23:50  44 of 134 PASS not_null_stg_oltp__producto_id_producto ......................... [PASS in 0.09s]
07:23:50  48 of 134 START test not_null_stg_oltp__sucursal_id_sucursal ................... [RUN]
07:23:50  47 of 134 START test unique_stg_oltp__cliente_id_cliente ....................... [RUN]
07:23:51  45 of 134 PASS unique_stg_oltp__producto_id_producto ........................... [PASS in 0.14s]
07:23:51  49 of 134 START test unique_stg_oltp__sucursal_id_sucursal ..................... [RUN]
07:23:51  46 of 134 PASS not_null_stg_oltp__cliente_id_cliente ........................... [PASS in 0.13s]
07:23:51  50 of 134 START test accepted_values_stg_oltp__venta_estado__COMPLETADA__ANULADA__PENDIENTE  [RUN]
07:23:51  48 of 134 PASS not_null_stg_oltp__sucursal_id_sucursal ......................... [PASS in 0.14s]
07:23:51  47 of 134 PASS unique_stg_oltp__cliente_id_cliente ............................. [PASS in 0.14s]
07:23:51  51 of 134 START test not_null_stg_oltp__venta_id_venta ......................... [RUN]
07:23:51  52 of 134 START test unique_stg_oltp__venta_id_venta ........................... [RUN]
07:23:51  49 of 134 PASS unique_stg_oltp__sucursal_id_sucursal ........................... [PASS in 0.11s]
07:23:51  50 of 134 PASS accepted_values_stg_oltp__venta_estado__COMPLETADA__ANULADA__PENDIENTE  [PASS in 0.09s]
07:23:51  53 of 134 START test not_null_stg_oltp__venta_detalle_id_detalle ............... [RUN]
07:23:51  54 of 134 START test relationships_stg_oltp__venta_detalle_id_venta__id_venta__ref_stg_oltp__venta_  [RUN]
07:23:51  52 of 134 PASS unique_stg_oltp__venta_id_venta ................................. [PASS in 0.10s]
07:23:51  51 of 134 PASS not_null_stg_oltp__venta_id_venta ............................... [PASS in 0.10s]
07:23:51  55 of 134 START test unique_stg_oltp__venta_detalle_id_detalle ................. [RUN]
07:23:51  56 of 134 START test not_null_dim_proveedor_proveedor_key ...................... [RUN]
07:23:51  53 of 134 PASS not_null_stg_oltp__venta_detalle_id_detalle ..................... [PASS in 0.10s]
07:23:51  54 of 134 PASS relationships_stg_oltp__venta_detalle_id_venta__id_venta__ref_stg_oltp__venta_  [PASS in 0.10s]
07:23:51  57 of 134 START test unique_dim_proveedor_proveedor_key ........................ [RUN]
07:23:51  58 of 134 START sql table model marts.dim_promocion ............................ [RUN]
07:23:51  56 of 134 PASS not_null_dim_proveedor_proveedor_key ............................ [PASS in 0.09s]
07:23:51  55 of 134 PASS unique_stg_oltp__venta_detalle_id_detalle ....................... [PASS in 0.10s]
07:23:51  59 of 134 START sql table model marts.dim_producto ............................. [RUN]
07:23:51  60 of 134 START sql table model marts.dim_cliente .............................. [RUN]
07:23:51  57 of 134 PASS unique_dim_proveedor_proveedor_key .............................. [PASS in 0.09s]
07:23:51  61 of 134 START sql table model marts.dim_sucursal ............................. [RUN]
07:23:51  58 of 134 OK created sql table model marts.dim_promocion ....................... [SELECT 31 in 0.13s]
07:23:51  62 of 134 START sql table model marts.dim_canal_pago ........................... [RUN]
07:23:51  60 of 134 OK created sql table model marts.dim_cliente ......................... [SELECT 251 in 0.14s]
07:23:51  59 of 134 OK created sql table model marts.dim_producto ........................ [SELECT 81 in 0.14s]
07:23:51  63 of 134 START sql view model intermediate.int_ventas_detalle_enriquecido ..... [RUN]
07:23:51  64 of 134 START test not_null_dim_promocion_promocion_key ...................... [RUN]
07:23:51  61 of 134 OK created sql table model marts.dim_sucursal ........................ [SELECT 7 in 0.12s]
07:23:51  65 of 134 START test unique_dim_promocion_promocion_key ........................ [RUN]
07:23:51  64 of 134 PASS not_null_dim_promocion_promocion_key ............................ [PASS in 0.09s]
07:23:51  62 of 134 OK created sql table model marts.dim_canal_pago ...................... [SELECT 17 in 0.16s]
07:23:51  66 of 134 START test not_null_dim_cliente_cliente_key .......................... [RUN]
07:23:51  67 of 134 START test unique_dim_cliente_cliente_key ............................ [RUN]
07:23:51  65 of 134 PASS unique_dim_promocion_promocion_key .............................. [PASS in 0.10s]
07:23:51  63 of 134 OK created sql view model intermediate.int_ventas_detalle_enriquecido  [CREATE VIEW in 0.16s]
07:23:51  68 of 134 START test not_null_dim_producto_producto_key ........................ [RUN]
07:23:51  69 of 134 START test not_null_dim_producto_sku ................................. [RUN]
07:23:51  66 of 134 PASS not_null_dim_cliente_cliente_key ................................ [PASS in 0.10s]
07:23:51  67 of 134 PASS unique_dim_cliente_cliente_key .................................. [PASS in 0.10s]
07:23:51  70 of 134 START test unique_dim_producto_producto_key .......................... [RUN]
07:23:51  71 of 134 START test not_null_dim_sucursal_sucursal_key ........................ [RUN]
07:23:51  68 of 134 PASS not_null_dim_producto_producto_key .............................. [PASS in 0.10s]
07:23:51  69 of 134 PASS not_null_dim_producto_sku ....................................... [PASS in 0.10s]
07:23:51  72 of 134 START test unique_dim_sucursal_sucursal_key .......................... [RUN]
07:23:51  73 of 134 START test not_null_dim_canal_pago_canal_pago_key .................... [RUN]
07:23:51  70 of 134 PASS unique_dim_producto_producto_key ................................ [PASS in 0.09s]
07:23:51  71 of 134 PASS not_null_dim_sucursal_sucursal_key .............................. [PASS in 0.09s]
07:23:51  74 of 134 START test unique_combination_of_columns_dim_canal_pago_canal__metodo_pago  [RUN]
07:23:51  75 of 134 START test unique_dim_canal_pago_canal_pago_key ...................... [RUN]
07:23:51  73 of 134 PASS not_null_dim_canal_pago_canal_pago_key .......................... [PASS in 0.10s]
07:23:51  72 of 134 PASS unique_dim_sucursal_sucursal_key ................................ [PASS in 0.10s]
07:23:51  76 of 134 START test not_null_int_ventas_detalle_enriquecido_id_detalle ........ [RUN]
07:23:51  77 of 134 START test unique_int_ventas_detalle_enriquecido_id_detalle .......... [RUN]
07:23:51  75 of 134 PASS unique_dim_canal_pago_canal_pago_key ............................ [PASS in 0.09s]
07:23:51  74 of 134 PASS unique_combination_of_columns_dim_canal_pago_canal__metodo_pago . [PASS in 0.10s]
07:23:51  78 of 134 START sql table model marts.fact_precios_proveedor ................... [RUN]
07:23:51  79 of 134 START sql table model marts.fact_inventario .......................... [RUN]
07:23:51  76 of 134 PASS not_null_int_ventas_detalle_enriquecido_id_detalle .............. [PASS in 0.09s]
07:23:51  80 of 134 START sql table model marts.fact_metas_ventas ........................ [RUN]
07:23:51  77 of 134 PASS unique_int_ventas_detalle_enriquecido_id_detalle ................ [PASS in 0.09s]
07:23:52  81 of 134 START sql view model intermediate.int_devoluciones_validadas ......... [RUN]
07:23:52  78 of 134 OK created sql table model marts.fact_precios_proveedor .............. [SELECT 103 in 0.10s]
07:23:52  82 of 134 START sql view model intermediate.int_ventas_por_sucursal_mes ........ [RUN]
07:23:52  80 of 134 OK created sql table model marts.fact_metas_ventas ................... [SELECT 48 in 0.10s]
07:23:52  83 of 134 START sql view model intermediate.int_ventas_promocion ............... [RUN]
07:23:52  79 of 134 OK created sql table model marts.fact_inventario ..................... [SELECT 3840 in 0.22s]
07:23:52  82 of 134 OK created sql view model intermediate.int_ventas_por_sucursal_mes ... [CREATE VIEW in 0.10s]
07:23:52  83 of 134 OK created sql view model intermediate.int_ventas_promocion .......... [CREATE VIEW in 0.07s]
07:23:52  81 of 134 OK created sql view model intermediate.int_devoluciones_validadas .... [CREATE VIEW in 0.11s]
07:23:52  84 of 134 START test assert_costo_proveedor_completo ........................... [RUN]
07:23:52  85 of 134 START test not_null_fact_precios_proveedor_precio_key ................ [RUN]
07:23:52  86 of 134 START test relationships_fact_precios_proveedor_fecha_vigencia_key__fecha_key__ref_dim_fecha_  [RUN]
07:23:52  87 of 134 START test relationships_fact_precios_proveedor_producto_key__producto_key__ref_dim_producto_  [RUN]
07:23:52  87 of 134 PASS relationships_fact_precios_proveedor_producto_key__producto_key__ref_dim_producto_  [PASS in 0.22s]
07:23:52  86 of 134 PASS relationships_fact_precios_proveedor_fecha_vigencia_key__fecha_key__ref_dim_fecha_  [PASS in 0.23s]
07:23:52  84 of 134 PASS assert_costo_proveedor_completo ................................. [PASS in 0.23s]
07:23:52  85 of 134 PASS not_null_fact_precios_proveedor_precio_key ...................... [PASS in 0.23s]
07:23:52  88 of 134 START test relationships_fact_precios_proveedor_proveedor_key__proveedor_key__ref_dim_proveedor_  [RUN]
07:23:52  89 of 134 START test unique_fact_precios_proveedor_precio_key .................. [RUN]
07:23:52  90 of 134 START test assert_metas_mayores_a_cero ............................... [RUN]
07:23:52  91 of 134 START test not_null_fact_metas_ventas_meta_key ....................... [RUN]
07:23:53  90 of 134 PASS assert_metas_mayores_a_cero ..................................... [PASS in 0.18s]
07:23:53  91 of 134 PASS not_null_fact_metas_ventas_meta_key ............................. [PASS in 0.18s]
07:23:53  88 of 134 PASS relationships_fact_precios_proveedor_proveedor_key__proveedor_key__ref_dim_proveedor_  [PASS in 0.19s]
07:23:53  89 of 134 PASS unique_fact_precios_proveedor_precio_key ........................ [PASS in 0.19s]
07:23:53  92 of 134 START test relationships_fact_metas_ventas_fecha_key__fecha_key__ref_dim_fecha_  [RUN]
07:23:53  93 of 134 START test relationships_fact_metas_ventas_sucursal_key__sucursal_key__ref_dim_sucursal_  [RUN]
07:23:53  94 of 134 START test unique_combination_of_columns_fact_metas_ventas_fecha_key__sucursal_key  [RUN]
07:23:53  95 of 134 START test unique_fact_metas_ventas_meta_key ......................... [RUN]
07:23:53  93 of 134 PASS relationships_fact_metas_ventas_sucursal_key__sucursal_key__ref_dim_sucursal_  [PASS in 0.17s]
07:23:53  92 of 134 PASS relationships_fact_metas_ventas_fecha_key__fecha_key__ref_dim_fecha_  [PASS in 0.18s]
07:23:53  94 of 134 PASS unique_combination_of_columns_fact_metas_ventas_fecha_key__sucursal_key  [PASS in 0.18s]
07:23:53  96 of 134 START test assert_inventario_vencimiento_posterior_al_corte .......... [RUN]
07:23:53  95 of 134 PASS unique_fact_metas_ventas_meta_key ............................... [PASS in 0.16s]
07:23:53  97 of 134 START test assert_stock_no_negativo .................................. [RUN]
07:23:53  98 of 134 START test not_null_fact_inventario_inventario_key ................... [RUN]
07:23:53  99 of 134 START test relationships_fact_inventario_fecha_key__fecha_key__ref_dim_fecha_  [RUN]
07:23:53  96 of 134 PASS assert_inventario_vencimiento_posterior_al_corte ................ [PASS in 0.11s]
07:23:53  100 of 134 START test relationships_fact_inventario_producto_key__producto_key__ref_dim_producto_  [RUN]
07:23:53  97 of 134 PASS assert_stock_no_negativo ........................................ [PASS in 0.11s]
07:23:53  98 of 134 PASS not_null_fact_inventario_inventario_key ......................... [PASS in 0.14s]
07:23:53  101 of 134 START test relationships_fact_inventario_sucursal_key__sucursal_key__ref_dim_sucursal_  [RUN]
07:23:53  99 of 134 PASS relationships_fact_inventario_fecha_key__fecha_key__ref_dim_fecha_  [PASS in 0.14s]
07:23:53  102 of 134 START test unique_combination_of_columns_fact_inventario_fecha_key__sucursal_key__producto_key  [RUN]
07:23:53  103 of 134 START test unique_fact_inventario_inventario_key .................... [RUN]
07:23:53  100 of 134 PASS relationships_fact_inventario_producto_key__producto_key__ref_dim_producto_  [PASS in 0.14s]
07:23:53  104 of 134 START test unique_combination_of_columns_int_ventas_por_sucursal_mes_periodo_fecha__id_sucursal  [RUN]
07:23:53  102 of 134 PASS unique_combination_of_columns_fact_inventario_fecha_key__sucursal_key__producto_key  [PASS in 0.11s]
07:23:53  101 of 134 PASS relationships_fact_inventario_sucursal_key__sucursal_key__ref_dim_sucursal_  [PASS in 0.13s]
07:23:53  103 of 134 PASS unique_fact_inventario_inventario_key .......................... [PASS in 0.11s]
07:23:53  105 of 134 START test not_null_int_ventas_promocion_id_detalle ................. [RUN]
07:23:53  106 of 134 START test unique_int_ventas_promocion_id_detalle ................... [RUN]
07:23:53  107 of 134 START sql table model marts.audit_calidad_datos ..................... [RUN]
07:23:53  104 of 134 PASS unique_combination_of_columns_int_ventas_por_sucursal_mes_periodo_fecha__id_sucursal  [PASS in 0.11s]
07:23:53  108 of 134 START sql table model marts.fact_devoluciones ....................... [RUN]
07:23:53  105 of 134 PASS not_null_int_ventas_promocion_id_detalle ....................... [PASS in 0.10s]
07:23:53  109 of 134 START sql table model marts.mart_cumplimiento_metas ................. [RUN]
07:23:53  106 of 134 PASS unique_int_ventas_promocion_id_detalle ......................... [PASS in 0.14s]
07:23:53  110 of 134 START sql table model marts.fact_ventas ............................. [RUN]
07:23:53  108 of 134 OK created sql table model marts.fact_devoluciones .................. [SELECT 80 in 0.14s]
07:23:53  107 of 134 OK created sql table model marts.audit_calidad_datos ................ [SELECT 13 in 0.22s]
07:23:53  111 of 134 START test assert_devoluciones_no_exceden_venta ..................... [RUN]
07:23:53  112 of 134 START test not_null_fact_devoluciones_devolucion_key ................ [RUN]
07:23:53  109 of 134 OK created sql table model marts.mart_cumplimiento_metas ............ [SELECT 48 in 0.17s]
07:23:53  113 of 134 START test relationships_fact_devoluciones_cliente_key__cliente_key__ref_dim_cliente_  [RUN]
07:23:53  111 of 134 PASS assert_devoluciones_no_exceden_venta ........................... [PASS in 0.08s]
07:23:53  112 of 134 PASS not_null_fact_devoluciones_devolucion_key ...................... [PASS in 0.08s]
07:23:53  114 of 134 START test relationships_fact_devoluciones_fecha_key__fecha_key__ref_dim_fecha_  [RUN]
07:23:53  115 of 134 START test relationships_fact_devoluciones_producto_key__producto_key__ref_dim_producto_  [RUN]
07:23:54  113 of 134 PASS relationships_fact_devoluciones_cliente_key__cliente_key__ref_dim_cliente_  [PASS in 0.09s]
07:23:54  116 of 134 START test relationships_fact_devoluciones_sucursal_key__sucursal_key__ref_dim_sucursal_  [RUN]
07:23:54  114 of 134 PASS relationships_fact_devoluciones_fecha_key__fecha_key__ref_dim_fecha_  [PASS in 0.40s]
07:23:54  115 of 134 PASS relationships_fact_devoluciones_producto_key__producto_key__ref_dim_producto_  [PASS in 0.40s]
07:23:54  117 of 134 START test unique_fact_devoluciones_devolucion_key .................. [RUN]
07:23:54  116 of 134 PASS relationships_fact_devoluciones_sucursal_key__sucursal_key__ref_dim_sucursal_  [PASS in 0.25s]
07:23:54  118 of 134 START test not_null_audit_calidad_datos_regla ....................... [RUN]
07:23:54  119 of 134 START test unique_audit_calidad_datos_regla ......................... [RUN]
07:23:54  119 of 134 PASS unique_audit_calidad_datos_regla ............................... [PASS in 0.09s]
07:23:54  117 of 134 PASS unique_fact_devoluciones_devolucion_key ........................ [PASS in 0.12s]
07:23:54  118 of 134 PASS not_null_audit_calidad_datos_regla ............................. [PASS in 0.11s]
07:23:54  120 of 134 START test unique_combination_of_columns_mart_cumplimiento_metas_periodo__nombre_sucursal  [RUN]
07:23:54  120 of 134 PASS unique_combination_of_columns_mart_cumplimiento_metas_periodo__nombre_sucursal  [PASS in 0.06s]
07:23:54  110 of 134 OK created sql table model marts.fact_ventas ........................ [SELECT 3209 in 1.04s]
07:23:54  121 of 134 START test assert_descuento_en_rango ................................ [RUN]
07:23:54  122 of 134 START test assert_fact_ventas_conserva_filas_raw .................... [RUN]
07:23:54  123 of 134 START test assert_fact_ventas_monto_neto_suma_raw ................... [RUN]
07:23:54  124 of 134 START test assert_subtotal_consistente .............................. [RUN]
07:23:54  121 of 134 PASS assert_descuento_en_rango ...................................... [PASS in 0.12s]
07:23:54  122 of 134 PASS assert_fact_ventas_conserva_filas_raw .......................... [PASS in 0.12s]
07:23:54  125 of 134 START test assert_ventas_con_fecha_en_dim_fecha ..................... [RUN]
07:23:54  124 of 134 PASS assert_subtotal_consistente .................................... [PASS in 0.13s]
07:23:54  126 of 134 START test assert_ventas_sin_cliente_huerfano ....................... [RUN]
07:23:54  123 of 134 PASS assert_fact_ventas_monto_neto_suma_raw ......................... [PASS in 0.14s]
07:23:55  127 of 134 START test not_null_fact_ventas_detalle_key ......................... [RUN]
07:23:55  128 of 134 START test relationships_fact_ventas_canal_pago_key__canal_pago_key__ref_dim_canal_pago_  [RUN]
07:23:55  125 of 134 PASS assert_ventas_con_fecha_en_dim_fecha ........................... [PASS in 0.12s]
07:23:55  126 of 134 PASS assert_ventas_sin_cliente_huerfano ............................. [PASS in 0.12s]
07:23:55  127 of 134 PASS not_null_fact_ventas_detalle_key ............................... [PASS in 0.11s]
07:23:55  129 of 134 START test relationships_fact_ventas_cliente_key__cliente_key__ref_dim_cliente_  [RUN]
07:23:55  128 of 134 PASS relationships_fact_ventas_canal_pago_key__canal_pago_key__ref_dim_canal_pago_  [PASS in 0.11s]
07:23:55  130 of 134 START test relationships_fact_ventas_fecha_key__fecha_key__ref_dim_fecha_  [RUN]
07:23:55  131 of 134 START test relationships_fact_ventas_producto_key__producto_key__ref_dim_producto_  [RUN]
07:23:55  132 of 134 START test relationships_fact_ventas_promocion_key__promocion_key__ref_dim_promocion_  [RUN]
07:23:55  129 of 134 PASS relationships_fact_ventas_cliente_key__cliente_key__ref_dim_cliente_  [PASS in 0.18s]
07:23:55  131 of 134 PASS relationships_fact_ventas_producto_key__producto_key__ref_dim_producto_  [PASS in 0.18s]
07:23:55  130 of 134 PASS relationships_fact_ventas_fecha_key__fecha_key__ref_dim_fecha_ . [PASS in 0.19s]
07:23:55  133 of 134 START test relationships_fact_ventas_sucursal_key__sucursal_key__ref_dim_sucursal_  [RUN]
07:23:55  132 of 134 PASS relationships_fact_ventas_promocion_key__promocion_key__ref_dim_promocion_  [PASS in 0.14s]
07:23:55  134 of 134 START test unique_fact_ventas_detalle_key ........................... [RUN]
07:23:55  134 of 134 PASS unique_fact_ventas_detalle_key ................................. [PASS in 0.11s]
07:23:55  133 of 134 PASS relationships_fact_ventas_sucursal_key__sucursal_key__ref_dim_sucursal_  [PASS in 0.12s]
07:23:55  
07:23:55  Finished running 14 table models, 104 data tests, 16 view models in 0 hours 0 minutes and 6.83 seconds (6.83s).
07:23:55  
07:23:55  Completed successfully
07:23:55  
07:23:55  Done. PASS=134 WARN=0 ERROR=0 SKIP=0 NO-OP=0 REUSED=0 TOTAL=134
(.venv) gio@gio:~/Documentos/26S2/seminario2/proyecto/SS22S2026_grupo21/proyectos/proyecto1$ 

```


y se ejecutan las preubas 