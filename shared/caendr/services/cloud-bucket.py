import os
from google.cloud import storage

storage_client = storage.Client()

bucket_name = os.environ.get('MODULE_SITE_BUCKET_PRIVATE_NAME')

storage_client.get