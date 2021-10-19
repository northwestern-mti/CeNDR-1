data "google_iam_policy" "cloudrun_noauth" {
  binding {
    role = "roles/run.invoker"
    members = ["allUsers"]
  }
}

resource "google_cloud_run_service" "api_pipeline_task" {
  name     = "api-pipeline-task"
  location = var.gcp_region

  template {
    spec {
      containers {
        image = format("gcr.io/%s/api-pipeline-task", var.gcp_project)
        env {
          name = "FLASK_ENV"
          value = var.environment
        }
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}

resource "google_cloud_run_service_iam_policy" "noauth" {
  location    = var.gcp_region
  project     = var.gcp_project
  service     = google_cloud_run_service.api_pipeline_task.name

  policy_data = data.google_iam_policy.cloudrun_noauth.policy_data
}
