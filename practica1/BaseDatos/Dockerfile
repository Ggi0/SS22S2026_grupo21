FROM mcr.microsoft.com/mssql/server:2022-latest

ENV ACCEPT_EULA=Y

USER root

COPY database.sql /init.sql
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
