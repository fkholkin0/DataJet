#!/bin/bash

set -a

source .env

find ./postgres/scripts/ -type f -iname "*.sh" -exec chmod +x {} \;

# airbyte_env_file="./airbyte/.env"

# sed -i '' "s~^CONFIG_DATABASE_USER=.*~CONFIG_DATABASE_USER=$PGS_AIRBYTE_USER_NAME~" "$airbyte_env_file"
# sed -i '' "s~^CONFIG_DATABASE_PASSWORD=.*~CONFIG_DATABASE_PASSWORD=root_sys~" "$airbyte_env_file"
# sed -i '' "s~^CONFIG_DATABASE_URL=.*~CONFIG_DATABASE_URL=jdbc:postgresql://postgres-sys:6000/$PGS_AIRBYTE_DB_NAME~" "$airbyte_env_file"
# source $airbyte_env_file

docker-compose -f docker-compose.yaml -f docker-compose.clickhouse.yaml up -d
