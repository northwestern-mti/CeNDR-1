variable "GOOGLE_CLOUD_PROJECT_ID" { }
variable "GOOGLE_CLOUD_PROJECT_NUMBER" { }
variable "GOOGLE_CLOUD_APP_LOCATION" { }
variable "GOOGLE_CLOUD_BUCKET_REGION" { }

variable "MODULE_SITE_CONTAINER_NAME" { }
variable "MODULE_SITE_CONTAINER_VERSION" { }
variable "MODULE_SITE_BUCKET_PUBLIC_NAME" { }
variable "MODULE_SITE_BUCKET_PRIVATE_NAME" { }

variable "ENVIRONMENT" { }

variable "DB_INSTANCE_CONNECTION_NAME" { }

variable "ANDERSEN_LAB_STRAIN_SHEET" { sensitive = true }
variable "CENDR_PUBLICATIONS_SHEET" { sensitive = true }
variable "RECAPTCHA_PUBLIC_KEY" { sensitive = true }
variable "RECAPTCHA_PRIVATE_KEY" { sensitive = true }
variable "ELEVATION_API_KEY" { sensitive = true }
