resource "google_cloudfunctions_function" "generate_thumbnails" {
  available_memory_mb = "256"
  entry_point         = "generate_thumbnails"

  event_trigger {
    event_type = "google.storage.object.finalize"

    failure_policy {
      retry = "false"
    }

    resource = "projects/${var.GOOGLE_CLOUD_PROJECT_ID}/buckets/${var.MODULE_IMG_THUMB_GEN_SOURCE_BUCKET_NAME}"
  }

  environment_variables = {
    MODULE_IMG_THUMB_GEN_SOURCE_PATH = "${var.MODULE_IMG_THUMB_GEN_SOURCE_PATH}"
  }

  source_archive_bucket = google_storage_bucket.source_bucket.name
  source_archive_object = google_storage_bucket_object.source_zip.name

  ingress_settings = "ALLOW_ALL"

  max_instances         = "0"
  name                  = "generate_thumbnails"
  project               = "${var.GOOGLE_CLOUD_PROJECT_ID}"
  region                = "${var.GOOGLE_CLOUD_REGION}"
  runtime               = "python37"
  service_account_email = "${var.GOOGLE_CLOUD_PROJECT_ID}@appspot.gserviceaccount.com"
  timeout               = "60"
}