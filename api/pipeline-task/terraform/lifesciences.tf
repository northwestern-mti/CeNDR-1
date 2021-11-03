resource "google_service_account" "nscalc_pipeline" {
  account_id   = var.MODULE_API_PIPELINE_TASK_SERVICE_ACCOUNT_NAME
  display_name = "Nemascan Pipeline Service Account"
}

resource "google_project_iam_member" "nscalc_pipeline_sa_user" {
  project = var.GOOGLE_CLOUD_PROJECT_ID
  role    = "roles/compute.serviceAgent"
  member  = "serviceAccount:${google_service_account.nscalc_pipeline.email}"
}

resource "google_project_iam_member" "nscalc_pipeline_ds_owner" {
  project = var.GOOGLE_CLOUD_PROJECT_ID
  role    = "roles/datastore.owner"
  member  = "serviceAccount:${google_service_account.nscalc_pipeline.email}"
}

resource "google_project_iam_member" "nscalc_pipeline_workflow_runner" {
  project = var.GOOGLE_CLOUD_PROJECT_ID
  role    = "roles/lifesciences.workflowsRunner"
  member  = "serviceAccount:${google_service_account.nscalc_pipeline.email}"
}

resource "google_project_iam_member" "nscalc_pipeline_object_creator" {
  project = var.GOOGLE_CLOUD_PROJECT_ID
  role    = "roles/storage.objectCreator"
  member  = "serviceAccount:${google_service_account.nscalc_pipeline.email}"
}


resource "google_project_iam_member" "nscalc_pipeline_object_viewer" {
  project = var.GOOGLE_CLOUD_PROJECT_ID
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:${google_service_account.nscalc_pipeline.email}"
}
