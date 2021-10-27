variable "GOOGLE_CLOUD_PROJECT_NAME" { }
variable "GOOGLE_CLOUD_PROJECT_ID" { }
variable "GOOGLE_CLOUD_APP_LOCATION" { }
variable "GOOGLE_CLOUD_REGION" { }
variable "GOOGLE_CLOUD_BUCKET_REGION" { }
variable "MODULE_SITE_CONTAINER_NAME" { }
variable "MODULE_SITE_CONTAINER_VERSION" { }
variable "MODULE_SITE_BUCKET_PUBLIC_NAME" { }
variable "MODULE_SITE_BUCKET_PRIVATE_NAME" { }
variable "ENVIRONMENT" { }

variable "DB_INSTANCE_CONNECTION_NAME" { }

variable "ANDERSEN_LAB_STRAIN_SHEET" {
  description = "Andersen Lab strain sheet ID from google docs"
  type = string
  sensitive = true
}

variable "CENDR_PUBLICATIONS_SHEET" {
  description = "Andersen Lab publications sheet ID from google docs"
  type = string
  sensitive = true
}

variable "RECAPTCHA_PUBLIC_KEY" {
  description = "Public key for RECAPTCHA"
  type = string
  sensitive = true
}

variable "RECAPTCHA_PRIVATE_KEY" {
  description = "Private key for RECAPTCHA"
  type = string
  sensitive = true
}

variable "ELEVATION_API_KEY" {
  description = "Google Maps Elevation API key"
  type = string
  sensitive = true
}
