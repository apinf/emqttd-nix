FROM postgres
ADD ./mqtt.sql /docker-entrypoint-initdb.d/mqtt.sql
ADD ./config.sh /docker-entrypoint-initdb.d/config.sh
