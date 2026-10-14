

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
