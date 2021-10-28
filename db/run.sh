#!/bin/bash

# Load .env file to environment variables
set -o allexport
source .env
set +o allexport

# Generate DB connection string
export DB_CONNECTION_URI="${GOOGLE_CLOUD_PROJECT_NAME}:${GOOGLE_CLOUD_REGION}:${MODULE_DB_POSTGRES_INSTANCE_NAME}"

./cloud_sql_proxy -dir=/cloudsql -instances=${DB_CONNECTION_URI} && \
  python main.py

