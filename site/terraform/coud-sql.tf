resource "google_sql_database" "postgres_db" {
  charset   = "UTF8"
  collation = "en_US.UTF8"
  instance  = google_sql_database_instance.postgres_db_instance.name
  name      = var.MODULE_SITE_DB_NAME
  project   = var.GOOGLE_CLOUD_PROJECT_NAME
}

resource "google_sql_database_instance" "postgres_db_instance" {
  database_version = "POSTGRES_13"
  name             = var.MODULE_SITE_DB_INSTANCE_NAME
  project          = var.GOOGLE_CLOUD_PROJECT_NAME
  region           = var.GOOGLE_CLOUD_REGION

  settings {
    activation_policy = "ALWAYS"
    availability_type = "ZONAL"

    backup_configuration {
      backup_retention_settings {
        retained_backups = "5"
        retention_unit   = "COUNT"
      }

      binary_log_enabled             = "false"
      enabled                        = "false"
      location                       = "us"
      point_in_time_recovery_enabled = "false"
      start_time                     = "05:00"
      transaction_log_retention_days = "7"
    }

    disk_autoresize        = "false"
    disk_autoresize_limit  = "0"
    disk_size              = "10"
    disk_type              = "PD_HDD"

    insights_config {
      query_insights_enabled  = "true"
      query_string_length     = "1024"
      record_application_tags = "false"
      record_client_address   = "false"
    }

    ip_configuration {
      authorized_networks {
        name  = "Sam (NU)"
        value = "165.124.85.24"
      }

      authorized_networks {
        name  = "Sam"
        value = "67.167.59.137"
      }

      ipv4_enabled = "true"
      require_ssl  = "false"
    }

    location_preference {
      zone = "us-central1-a"
    }

    maintenance_window {
      day  = "6"
      hour = "5"
    }

    pricing_plan     = "PER_USE"
    tier             = "db-g1-small"
  }
}
