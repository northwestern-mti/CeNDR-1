import os
from functools import wraps
from flask import request
from google.cloud import secretmanager

from services.error import APIAuthError

GOOGLE_CLOUD_PROJECT_ID = os.environ.get('GOOGLE_CLOUD_PROJECT_ID')
API_SECRET_ID = os.environ.get('API_SECRET_ID')
API_SECRET_VERSION = os.environ.get('API_SECRET_VERSION')

secretManagerClient = secretmanager.SecretManagerServiceClient()
secretName = f"projects/{GOOGLE_CLOUD_PROJECT_ID}/secrets/{API_SECRET_ID}/versions/{API_SECRET_VERSION}"

def _verify_api_token(apiToken):
  response = secretManagerClient.access_secret_version(request={"name": secretName})
  secret = response.payload.data.decode("UTF-8")
  if apiToken == secret:
    return True
  return False
  

def authenticate(f):
  @wraps(f)
  def __authenticate(*args, **kwargs):
    # Retrieve the authorization header from the request
    authHeader = request.headers.get("authorization")
    if authHeader == None:
      raise APIAuthError("Authorization header missing from request")

    # Compare the bearer token to the API secret in cloud secret store
    accessToken = authHeader[len("Bearer ") :]
    try:
      is_authenticated = _verify_api_token(accessToken)
    except Exception as err:
      print(err)
      raise APIAuthError("Failed to retrieve secret from store")

    # Confirm that the token is correct
    if is_authenticated == False:
      raise APIAuthError("Incorrect authorization header")
      
    return f(*args, **kwargs)
  return __authenticate
