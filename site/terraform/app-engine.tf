resource "google_app_engine_application" "app" {
  project     = var.GOOGLE_CLOUD_PROJECT_NAME
  location_id = var.GOOGLE_CLOUD_APP_LOCATION
}

resource "google_app_engine_flexible_app_version" "site" {
  version_id = replace("${var.MODULE_SITE_CONTAINER_NAME}-${var.MODULE_SITE_CONTAINER_VERSION}",".","-")
  project    = var.GOOGLE_CLOUD_PROJECT_NAME
  service    = "default"
  runtime    = "custom"

  deployment {
    container {
      image = "gcr.io/${var.GOOGLE_CLOUD_PROJECT_NAME}/${var.MODULE_SITE_CONTAINER_NAME}:${var.MODULE_SITE_CONTAINER_VERSION}"
    }
  }

  liveness_check {
    path = "/"
  }

  readiness_check {
    path = "/"
  }

  automatic_scaling {
    cool_down_period = "180s"
    cpu_utilization {
      target_utilization = 0.6
    }
  }

}
