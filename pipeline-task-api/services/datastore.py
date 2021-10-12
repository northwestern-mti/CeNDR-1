import os
from google.cloud import datastore

datastoreClient = datastore.Client()

def get_ds_entity(kind, id):
  if (os.environ.get("FLASK_ENV", 'development') == 'development'):
    kind = f'DEV_{kind}'

  key = datastoreClient.key(kind, id)
  entity = datastore.Entity(key=key)
  return entity

def query_ds_entity(kind, field, val):
  if (os.environ.get("FLASK_ENV", 'development') == 'development'):
    kind = f'DEV_{kind}'

  query = datastoreClient.query(kind=kind)
  results = list(query.add_filter(field, '=', val).fetch())
  try:
    result = results[0]
  except: 
    result = None
  return result


def update_ds_entity(entity, data):
  entity.update(data)
  datastoreClient.put(entity)
  result = datastoreClient.get(entity.key)
  return result
  #print(result)

