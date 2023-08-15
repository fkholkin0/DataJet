#!/bin/bash

POSTGRES="psql --username ${POSTGRES_USER}"

echo "shared_preload_libraries = 'pg_net'" >> $PGDATA/postgresql.conf
# pg_ctl reload -D $PGDATA
$POSTGRES <<-EOSQL
    CREATE EXTENSION pg_net;
    CREATE EXTENSION clickhouse_fdw;
    CREATE SERVER clickhouse_svr FOREIGN DATA WRAPPER clickhouse_fdw OPTIONS(dbname 'default', host 'clickhouse-01', port '8123');
EOSQL
# Получить список всех переменных окружения, соответствующих формату "PGS_<prefix>_DB_NAME"
variable_pattern="PG_.*_DB_NAME"

# Цикл по всем переменным окружения, соответствующим шаблону
for db_variable_name in $(env | grep -E "${variable_pattern}=" | cut -d "=" -f 1); do
    # Извлечь префикс из имени переменной окружения
    prefix=$(echo "$db_variable_name" | sed -E 's/^PG_(.*)_DB_NAME$/\1/')

    # Получить имя пользователя и базы данных из переменных окружения
    user_variable_name="PG_${prefix}_USER_NAME"
    user_name="${!user_variable_name}"
    db_name="${!db_variable_name}"

    # Выполнить необходимые команды с использованием переменных окружения
    $POSTGRES <<-EOSQL
    CREATE USER $user_name WITH PASSWORD '$POSTGRES_PASSWORD';
    CREATE DATABASE $db_name;

    GRANT ALL ON DATABASE $db_name TO $user_name;
    \c $db_name;
    GRANT ALL ON SCHEMA public TO $user_name;
    
EOSQL
done
