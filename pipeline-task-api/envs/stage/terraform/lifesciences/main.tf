resource "google_project_service" "lifesciences" {
  service = "lifesciences.googleapis.com"
}

resource "google_project_service" "iam" {
  service = "iam.googleapis.com"
}

resource "google_service_account" "nscalc_pipeline" {
  account_id   = var.nscalc_service_account_name
  display_name = "Nemascan Pipeline Service Account"
}

data "google_iam_policy" "nscalc_pipeline" {
  binding {
    role = "roles/compute.serviceAgent"
    members = ["serviceAccount:${google_service_account.nscalc_pipeline.email}"]
  }
  binding {
    role = "roles/datastore.user"
    members = ["serviceAccount:${google_service_account.nscalc_pipeline.email}"]
  }
  binding {
    role = "roles/lifesciences.workflowsRunner"
    members = ["serviceAccount:${google_service_account.nscalc_pipeline.email}"]
  }
  binding {
    role = "roles/storage.objectCreator"
    members = ["serviceAccount:${google_service_account.nscalc_pipeline.email}"]
  }
  binding {
    role = "roles/storage.objectViewer"
    members = ["serviceAccount:${google_service_account.nscalc_pipeline.email}"]
  }
}
