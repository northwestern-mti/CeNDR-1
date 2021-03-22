import json
import datetime
import googleapiclient.discovery

from flask import g
from gcloud import datastore, storage
from logzero import logger
from google.oauth2 import service_account

from base.constants import GOOGLE_CLOUD_BUCKET, GOOGLE_CLOUD_PROJECT_ID
from base.utils.data_utils import dump_json


def google_datastore(open=False):
    """
        Fetch google datastore credentials

        Args:
            open - Return the client without storing it in the g object.
    """
    client = datastore.Client(project=GOOGLE_CLOUD_PROJECT_ID)
    if open:
        return client
    if not hasattr(g, 'ds'):
        g.ds = client
    return g.ds


def delete_item(item):
    ds = google_datastore()
    batch = ds.batch()
    batch.delete(item.key)
    batch.commit()


def delete_by_ref(kind, id):
    ds = google_datastore()
    key = ds.key(kind, id)
    batch = ds.batch()
    batch.delete(key)
    batch.commit()


def delete_items_by_query(kind, filters=None, projection=()):
    """
        Deletes all items that are returned by a query. 
        Items are deleted in page-sized batches as the results are being returned
        Returns the number of items deleted
    """
    # filters:
    # [("var_name", "=", 1)]
    ds = google_datastore()
    query = ds.query(kind=kind, projection=projection)
    deleted_items = 0
    if filters:
        for var, op, val in filters:
            query.add_filter(var, op, val)

    query = query.fetch()
    while True:
        data, more, cursor = query.next_page()
        keys = []
        for entity in data:
            keys.append(entity.key)
        ds.delete_multi(keys)
        deleted_items += len(keys)
        if more is False:
            break
    return deleted_items


def store_item(kind, name, **kwargs):
    ds = google_datastore()
    try:
        exclude = kwargs.pop('exclude_from_indexes')
    except KeyError:
        exclude = False
    if exclude:
        m = datastore.Entity(key=ds.key(kind, name), exclude_from_indexes=exclude)
    else:
        m = datastore.Entity(key=ds.key(kind, name))
    for key, value in kwargs.items():
        if isinstance(value, dict):
            m[key] = 'JSON:' + dump_json(value)
        else:
            m[key] = value
    logger.debug(f"store: {kind} - {name}")
    ds.put(m)


def query_item(kind, filters=None, projection=(), order=None, limit=None, keys_only=False):
    """
        Filter items from google datastore using a query
    """
    # filters:
    # [("var_name", "=", 1)]
    ds = google_datastore()
    query = ds.query(kind=kind, projection=projection)
    if keys_only:
        query.keys_only()
    if order:
        query.order = order
    if filters:
        for var, op, val in filters:
            query.add_filter(var, op, val)
    if limit:
        return query.fetch(limit=limit)
    else:
        records = []
        query = query.fetch()
        while True:
            data, more, key = query.next_page()
            records.extend(data)
            if more is False:
                break
        return records


def get_item(kind, name):
    """
        returns item by kind and name from google datastore
    """
    ds = google_datastore()
    result = ds.get(ds.key(kind, name))
    logger.debug(f"get: {kind} - {name}")
    try:
        result_out = {'_exists': True}
        for k, v in result.items():
            if isinstance(v, str) and v.startswith("JSON:"):
                result_out[k] = json.loads(v[5:])
            elif v:
                result_out[k] = v

        return result_out
    except AttributeError:
        return None


def google_storage(open=False):
    """
        Fetch google datastore credentials

        Args:
            open - Return the client without storing it in the g object.
    """
    client = storage.Client(project=GOOGLE_CLOUD_PROJECT_ID)
    if open:
      return client
    if g and not hasattr(g, 'gs'):
      g.gs = client
      return g.gs
    return client


def get_cendr_bucket():
    """
        Returns the CeNDR bucket
    """
    gs = google_storage()
    return gs.get_bucket(GOOGLE_CLOUD_BUCKET)


def upload_file(blob, obj, as_string = False):
    """
        Upload a file to the CeNDR bucket

        Args:
            blob - The name of the blob (server-side)
            fname - The filename to upload (client-side)
    """
    logger.info(f"Uploading: {blob} --> {obj}")
    cendr_bucket = get_cendr_bucket()
    blob = cendr_bucket.blob(blob)
    if as_string:
        blob.upload_from_string(obj)
    else:
        blob.upload_from_filename(obj)
    return blob


def download_file(name, fname):
    """
        Download a file from the CeNDR bucket

        Args:
            name - The name of the blob (server-side)
            fname - The filename to download (client-side)
    """
    cendr_bucket = get_cendr_bucket()
    blob = cendr_bucket.blob(name)
    blob.download_to_file(open(fname, 'wb'))
    return fname


def check_blob(fname):
    """
        Checks that a file exists and if so returns
        the URL, otherwise returns nothing
    """
    cendr_bucket = get_cendr_bucket()
    return cendr_bucket.get_blob(fname)


def list_release_files(prefix):
    """
        Lists files with a given prefix
        from the current dataset release
    """

    cendr_bucket = get_cendr_bucket()
    items = cendr_bucket.list_blobs(prefix=prefix)
    return list([f"https://storage.googleapis.com/{GOOGLE_CLOUD_BUCKET}/{x.name}" for x in items])


def google_analytics():
    """
        Fetch google api client for google analytics
    """
    credentials = service_account.Credentials.from_service_account_file('env_config/client-secret.json',
                                                      scopes=['https://www.googleapis.com/auth/analytics.readonly'])
    return googleapiclient.discovery.build('analyticsreporting', 'v4', credentials=credentials)


def generate_download_signed_url_v4(blob_path, expiration=datetime.timedelta(minutes=15)):
    """Generates a v4 signed URL for downloading a blob. """
    # blob_name = 'your-object-name'
    storage_client = storage.Client.from_service_account_json('env_config/client-secret.json')
    bucket = storage_client.bucket(GOOGLE_CLOUD_BUCKET)
    blob = bucket.blob(blob_path)

    url = blob.generate_signed_url(
        expiration=expiration,
        method="GET"
    )
    return url


def generate_upload_signed_url_v4(blob_name, content_type="application/octet-stream"):
    """Generates a v4 signed URL for uploading a blob using HTTP PUT. """
    storage_client = storage.Client.from_service_account_json('env_config/client-secret.json')
    bucket = storage_client.bucket(GOOGLE_CLOUD_BUCKET)
    blob = bucket.blob(blob_name)

    url = blob.generate_signed_url(
      expiration=datetime.timedelta(minutes=15),
      method="PUT",
      content_type=content_type
    )
    return url
