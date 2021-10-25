import os
from google.cloud import secretmanager

GOOGLE_CLOUD_PROJECT_ID = os.environ.get('GOOGLE_CLOUD_PROJECT_ID')

secretManagerClient = secretmanager.SecretManagerServiceClient()

def get_secret(id, version):
    secretName = f"projects/{GOOGLE_CLOUD_PROJECT_ID}/secrets/{id}/versions/{version}"
    response = secretManagerClient.access_secret_version(request={"name": secretName})
    secret = response.payload.data.decode("UTF-8")
    return secret

