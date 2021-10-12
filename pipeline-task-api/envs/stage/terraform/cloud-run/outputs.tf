output "pipeline-api-url" {
  value = google_cloud_run_service.pipeline-api.status[0].url
}