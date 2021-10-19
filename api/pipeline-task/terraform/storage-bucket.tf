resource "google_storage_bucket" "pipeline-work" {
    name = var.gcp_work_bucket_name
    location = "US-CENTRAL1"
}


resource "google_storage_bucket" "pipeline-reports" {
    name = var.gcp_report_bucket_name
    location = "US-CENTRAL1"
}