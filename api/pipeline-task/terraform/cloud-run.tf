data "google_iam_policy" "cloudrun_noauth" {
  binding {
    role = "roles/run.invoker"
    members = ["allUsers"]
  }
}

resource "google_cloud_run_service" "api_pipeline_task" {
  name     = "api-pipeline-task"
  location = var.GOOGLE_CLOUD_REGION

  template {
    spec {
      containers {
        image = "gcr.io/${var.GOOGLE_CLOUD_PROJECT_NAME}/${var.MODULE_API_PIPELINE_TASK_CONTAINER_NAME}:${var.MODULE_API_PIPELINE_TASK_CONTAINER_VERSION}"
        env {
          name = "FLASK_ENV"
          value = var.ENVIRONMENT
        }
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  depends_on = [
    time_sleep.wait_container_publish
  ]
}

resource "google_cloud_run_service_iam_policy" "noauth" {
  location    = var.GOOGLE_CLOUD_REGION
  project     = var.GOOGLE_CLOUD_PROJECT_NAME
  service     = google_cloud_run_service.api_pipeline_task.name

  policy_data = data.google_iam_policy.cloudrun_noauth.policy_data
}
