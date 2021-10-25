resource "google_storage_bucket" "pipeline-work" {
    name = var.MODULE_API_PIPELINE_TASK_WORK_BUCKET_NAME
    location = upper(var.GOOGLE_CLOUD_REGION)
}


resource "google_storage_bucket" "pipeline-reports" {
    name = var.MODULE_API_PIPELINE_TASK_REPORT_BUCKET_NAME
    location = upper(var.GOOGLE_CLOUD_REGION)
}