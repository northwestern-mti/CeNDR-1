resource "google_app_engine_application" "app" {
  project     = var.GOOGLE_CLOUD_PROJECT_ID
  location_id = var.GOOGLE_CLOUD_APP_LOCATION
}



resource "google_project_iam_member" "app_engine_secret_viewer" {
  project = var.GOOGLE_CLOUD_PROJECT_ID
  role    = "roles/secretmanager.viewer"
  member  = "serviceAccount:${var.GOOGLE_CLOUD_PROJECT_ID}@appspot.gserviceaccount.com"
}

resource "google_project_iam_member" "app_engine_secret_accessor" {
  project = var.GOOGLE_CLOUD_PROJECT_ID
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${var.GOOGLE_CLOUD_PROJECT_ID}@appspot.gserviceaccount.com"
}

resource "google_project_iam_member" "app_engine_storage_object_viewer" {
  project = var.GOOGLE_CLOUD_PROJECT_ID
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:${var.GOOGLE_CLOUD_PROJECT_ID}@appspot.gserviceaccount.com"
}

resource "google_project_iam_member" "app_engine_datastore_user" {
  project = var.GOOGLE_CLOUD_PROJECT_ID
  role    = "roles/datastore.user"
  member  = "serviceAccount:${var.GOOGLE_CLOUD_PROJECT_ID}@appspot.gserviceaccount.com"
}



resource "google_project_iam_member" "app_engine_flex_secret_viewer" {
  project = var.GOOGLE_CLOUD_PROJECT_ID
  role    = "roles/secretmanager.viewer"
  member  = "serviceAccount:service-${var.GOOGLE_CLOUD_PROJECT_NUMBER}@gae-api-prod.google.com.iam.gserviceaccount.com"
}

resource "google_project_iam_member" "app_engine_flex_secret_accessor" {
  project = var.GOOGLE_CLOUD_PROJECT_ID
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:service-${var.GOOGLE_CLOUD_PROJECT_NUMBER}@gae-api-prod.google.com.iam.gserviceaccount.com"
}

resource "google_project_iam_member" "app_engine_flex_storage_object_viewer" {
  project = var.GOOGLE_CLOUD_PROJECT_ID
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:service-${var.GOOGLE_CLOUD_PROJECT_NUMBER}@gae-api-prod.google.com.iam.gserviceaccount.com"
}

resource "google_project_iam_member" "app_engine_flex_datastore_user" {
  project = var.GOOGLE_CLOUD_PROJECT_ID
  role    = "roles/datastore.user"
  member  = "serviceAccount:service-${var.GOOGLE_CLOUD_PROJECT_NUMBER}@gae-api-prod.google.com.iam.gserviceaccount.com"
}



resource "google_app_engine_flexible_app_version" "site" {
  version_id      = replace("${var.MODULE_SITE_CONTAINER_NAME}-${var.MODULE_SITE_CONTAINER_VERSION}",".","-")
  project         = var.GOOGLE_CLOUD_PROJECT_ID
  service         = "default"
  runtime         = "custom"
  serving_status  = "SERVING"

  deployment {
    container {
      image = "gcr.io/${var.GOOGLE_CLOUD_PROJECT_ID}/${var.MODULE_SITE_CONTAINER_NAME}:${var.MODULE_SITE_CONTAINER_VERSION}"
    }
  }

  entrypoint {
    shell = "gunicorn -b :$PORT main:app --ssl-version TLSv1_2"
  }

  beta_settings = {
    cloud_sql_instances = "${var.DB_INSTANCE_CONNECTION_NAME}"
  }

  liveness_check {
    path = "/liveness_check"
    check_interval = "60s"
    timeout = "10s"
    failure_threshold = 2
    success_threshold = 2
    initial_delay = "300s"
  }

  readiness_check {
    path = "/readiness_check"
    check_interval = "120s"
    timeout = "10s"
    failure_threshold = 2
    success_threshold = 2
    app_start_timeout = "300s"
  }

  resources {
    cpu = 2
    memory_gb = 2
    disk_gb = 20
  }

  automatic_scaling {
    min_total_instances = 1
    max_total_instances = 5
    cool_down_period = "180s"
    cpu_utilization {
      target_utilization = 0.6
    }
  }

  depends_on = [
    google_secret_manager_secret.ANDERSEN_LAB_STRAIN_SHEET,
    google_secret_manager_secret.CENDR_PUBLICATIONS_SHEET,
    google_secret_manager_secret.RECAPTCHA_PUBLIC_KEY,
    google_secret_manager_secret.RECAPTCHA_PRIVATE_KEY,
    google_secret_manager_secret.ELEVATION_API_KEY,
    time_sleep.wait_container_publish
  ]

  lifecycle {
    create_before_destroy = true
  }
  noop_on_destroy = true

}


resource "google_app_engine_service_split_traffic" "site_traffic" {
  service = google_app_engine_flexible_app_version.site.service

  migrate_traffic = false
  split {
    allocations = {
      (google_app_engine_flexible_app_version.site.version_id) = 1
    }
  }
  depends_on = [
    time_sleep.wait_app_engine_start
  ]
}

resource "time_sleep" "wait_app_engine_start" {
    create_duration = "300s"

    depends_on = [
        google_app_engine_flexible_app_version.site
    ]
}