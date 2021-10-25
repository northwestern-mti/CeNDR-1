variable "GOOGLE_CLOUD_PROJECT_NAME" { }
variable "GOOGLE_CLOUD_PROJECT_ID" { }
variable "GOOGLE_CLOUD_APP_LOCATION" { }
variable "GOOGLE_CLOUD_REGION" { }
variable "GOOGLE_CLOUD_SERVICE_ACCOUNT_FILE" { }
variable "ENVIRONMENT" { }


variable "MODULE_SITE_CONTAINER_NAME" { }
variable "MODULE_SITE_CONTAINER_VERSION" { }
variable "MODULE_SITE_BUCKET_PUBLIC_NAME" { }
variable "MODULE_SITE_BUCKET_SECURE_NAME" { }
variable "MODULE_SITE_DB_NAME" { }
variable "MODULE_SITE_DB_INSTANCE_NAME" { }


variable "MODULE_API_PIPELINE_TASK_REPORT_BUCKET_NAME" { }
variable "MODULE_API_PIPELINE_TASK_WORK_BUCKET_NAME" { }
variable "MODULE_API_PIPELINE_TASK_SERVICE_ACCOUNT_NAME" { }


variable "ANDERSEN_LAB_STRAIN_SHEET" { sensitive = true }
variable "CENDR_PUBLICATIONS_SHEET" { sensitive = true }
variable "RECAPTCHA_PUBLIC_KEY" { sensitive = true }
variable "RECAPTCHA_PRIVATE_KEY" { sensitive = true }
variable "ELEVATION_API_KEY" { sensitive = true }
