import os
import logging

from dotenv import load_dotenv

dotenv_file = '.env'
load_dotenv(dotenv_file)

download_path = ".download"

GOOGLE_CLOUD_PROJECT_ID = os.environ.get('GOOGLE_CLOUD_PROJECT_ID')
GOOGLE_CLOUD_REGION = os.environ.get('GOOGLE_CLOUD_REGION')
MODULE_DB_POSTGRES_INSTANCE_NAME = os.environ.get('MODULE_DB_POSTGRES_INSTANCE_NAME')
MODULE_DB_POSTGRES_DB_NAME = os.environ.get('MODULE_DB_POSTGRES_DB_NAME')
MODULE_DB_POSTGRES_DB_STAGE_NAME = os.environ.get('MODULE_DB_POSTGRES_DB_STAGE_NAME')
MODULE_DB_POSTGRES_DB_USER = os.environ.get('MODULE_DB_POSTGRES_DB_USER')
MODULE_DB_POSTGRES_DB_PASSWORD = os.environ.get('MODULE_DB_POSTGRES_DB_PASSWORD')


db_instance_uri = f'${GOOGLE_CLOUD_PROJECT_ID}:${GOOGLE_CLOUD_REGION}:${MODULE_DB_POSTGRES_INSTANCE_NAME}'
db_conn_uri = f'postgres+psycopg2://{MODULE_DB_POSTGRES_DB_USER}:{MODULE_DB_POSTGRES_DB_PASSWORD}@/{MODULE_DB_POSTGRES_DB_STAGE_NAME}?host=/cloudsql/{db_instance_uri}'

