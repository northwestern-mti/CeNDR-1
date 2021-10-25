resource "google_pubsub_topic" "nemascan" {
  message_storage_policy {
    allowed_persistence_regions = ["us-central1", "us-central2", "us-east1", "us-east4", "us-west1", "us-west2", "us-west3", "us-west4"]
  }

  name    = "nemascan"
  project = var.GOOGLE_CLOUD_PROJECT_NAME
}


resource "google_pubsub_subscription" "nscalc" {
  ack_deadline_seconds    = "10"
  enable_message_ordering = "false"

  expiration_policy {
    ttl = "2678400s"
  }

  message_retention_duration = "259200s"
  name                       = "nscalc"
  project                    = var.GOOGLE_CLOUD_PROJECT_NAME

  push_config {
    push_endpoint = google_cloud_run_service.api_pipeline_task.status[0].url
  }

  retain_acked_messages = "false"
  topic                 = google_pubsub_topic.nemascan.name
}
