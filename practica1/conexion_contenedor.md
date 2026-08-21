# ejecutar el contenedor:

```sh
docker run -d \
--name vuelosbi-sql \
-p 1433:1433 \
--env-file .env \
vuelosbi

```

# entrar al contenedor:
```sh
docker exec -it vnombre_imagen bash
```


# dentro ejecutar:
```
/opt/mssql-tools18/bin/sqlcmd \
-S localhost \
-U sa \
-P "contrasenia" \
-C

```

# dentro de de sql:
```sql
SELECT name FROM sys.databases;
GO
```

* salida:
```sql
master
model
msdb
tempdb
VuelosBI

```

# seleccionar base de datos y tablas:
```sql
USE VuelosBI;
GO

SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES;
GO
```