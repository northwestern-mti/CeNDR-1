resource "google_project_service" "run" {
  service = "run.googleapis.com"
}

data "google_iam_policy" "cloudrun-noauth" {
  binding {
    role = "roles/run.invoker"
    members = ["allUsers"]
  }
}

resource "google_cloud_run_service" "pipeline-api" {
  name     = "pipeline-api"
  location = var.gcp_region

  template {
    spec {
      containers {
        image = format("gcr.io/%s/pipeline-api", var.app_project)
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
  
  depends_on = [google_project_service.run]
}

resource "google_cloud_run_service_iam_policy" "noauth" {
  location    = var.gcp_region
  project     = var.app_project
  service     = google_cloud_run_service.pipeline-api.name

  policy_data = data.google_iam_policy.cloudrun-noauth.policy_data
}
