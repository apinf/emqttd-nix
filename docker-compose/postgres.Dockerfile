FROM postgres
ADD ./mqtt.sql /docker-entrypoint-initdb.d/mqtt.sql
