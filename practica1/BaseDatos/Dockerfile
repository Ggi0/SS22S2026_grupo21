FROM mcr.microsoft.com/mssql/server:2022-latest

# Variables de entorno (se inyectan desde docker-compose.yml / .env)
ENV ACCEPT_EULA=${ACCEPT_EULA}
ENV MSSQL_SA_PASSWORD=${MSSQL_SA_PASSWORD}
ENV MSSQL_PID=${MSSQL_PID}

USER root

COPY database.sql /init.sql
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
