resource "google_secret_manager_secret" "ANDERSEN_LAB_STRAIN_SHEET" {
  provider = google-beta
  secret_id = "ANDERSEN_LAB_STRAIN_SHEET"  

  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "ANDERSEN_LAB_STRAIN_SHEET" {
  secret = google_secret_manager_secret.ANDERSEN_LAB_STRAIN_SHEET.id
  secret_data = var.ANDERSEN_LAB_STRAIN_SHEET
}

resource "google_secret_manager_secret" "CENDR_PUBLICATIONS_SHEET" {
  provider = google-beta
  secret_id = "CENDR_PUBLICATIONS_SHEET"  

  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "CENDR_PUBLICATIONS_SHEET" {
  secret = google_secret_manager_secret.CENDR_PUBLICATIONS_SHEET.id
  secret_data = var.CENDR_PUBLICATIONS_SHEET
}

resource "google_secret_manager_secret" "RECAPTCHA_PUBLIC_KEY" {
  provider = google-beta
  secret_id = "RECAPTCHA_PUBLIC_KEY"  

  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "RECAPTCHA_PUBLIC_KEY" {
  secret = google_secret_manager_secret.RECAPTCHA_PUBLIC_KEY.id
  secret_data = var.RECAPTCHA_PUBLIC_KEY
}

resource "google_secret_manager_secret" "RECAPTCHA_PRIVATE_KEY" {
  provider = google-beta
  secret_id = "RECAPTCHA_PRIVATE_KEY"  

  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "RECAPTCHA_PRIVATE_KEY" {
  secret = google_secret_manager_secret.RECAPTCHA_PRIVATE_KEY.id
  secret_data = var.RECAPTCHA_PRIVATE_KEY
}

resource "google_secret_manager_secret" "ELEVATION_API_KEY" {
  provider = google-beta
  secret_id = "ELEVATION_API_KEY"  

  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "ELEVATION_API_KEY" {
  secret = google_secret_manager_secret.ELEVATION_API_KEY.id
  secret_data = var.ELEVATION_API_KEY
}

