#!/bin/bash

log_file="/var/log/healthcheck.log"
touch $log_file

check_extension() {
    extension_name=$1

    psql -U $POSTGRES_USER -c "CREATE EXTENSION IF NOT EXISTS $extension_name;" >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "Extension $extension_name is ready"
    else
        echo "Extension $extension_name is not ready"
        exit 1
    fi
}

# Функция для проверки состояния базы данных
check_database() {
    database_name=$1
    user_name=$2

    psql -U $POSTGRES_USER -d $database_name -c "SELECT 1;" >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "Database $database_name is ready" >> $log_file
    else
        echo "Database $database_name is not ready" >> $log_file
        exit 1
    fi

    psql -U $POSTGRES_USER -d $database_name -c "SELECT 1 FROM pg_roles WHERE rolname='$user_name';" >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "User $user_name is ready" >> $log_file
    else
        echo "User $user_name is not ready" >> $log_file
        exit 1
    fi
}

check_extension "clickhouse_fdw"
check_extension "pg_net"
echo "All extensions are ready"

# Цикл для проверки каждой базы данных и пользователя
variable_pattern="PG_.*_DB_NAME"
for db_variable_name in $(env | grep -E "${variable_pattern}=" | cut -d "=" -f 1); do
    prefix=$(echo "$db_variable_name" | sed -E 's/^PG_(.*)_DB_NAME$/\1/')
    user_variable_name="PG_${prefix}_USER_NAME"
    user_name="${!user_variable_name}"
    db_name="${!db_variable_name}"

    check_database "$db_name" "$user_name"
done

# Вывод сообщения в журналы Docker
echo "All databases and users are ready" >> $log_file
