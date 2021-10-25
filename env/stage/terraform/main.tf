resource "google_project_service" "cloud_resource_manager" {
  service = "cloudresourcemanager.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "iam" {
  service = "iam.googleapis.com"
  disable_on_destroy = false
  depends_on = [google_project_service.cloud_resource_manager]
}

resource "google_project_service" "run" {
  service = "run.googleapis.com"
  disable_on_destroy = false
  depends_on = [google_project_service.cloud_resource_manager]
}

resource "google_project_service" "lifesciences" {
  service = "lifesciences.googleapis.com"
  disable_on_destroy = false
  depends_on = [google_project_service.cloud_resource_manager]
}

resource "google_project_service" "container_registry" {
  service = "containerregistry.googleapis.com"
  disable_on_destroy = false
  depends_on = [google_project_service.cloud_resource_manager]
}

resource "google_project_service" "cloudbuild" {
  service = "cloudbuild.googleapis.com"
  disable_on_destroy = false
  depends_on = [google_project_service.cloud_resource_manager]
}

resource "google_project_service" "app_engine" {
  service = "appengine.googleapis.com"
  disable_on_destroy = false
  depends_on = [google_project_service.cloud_resource_manager]
}

resource "google_project_service" "secret_manager" {
  service = "secretmanager.googleapis.com"
  disable_on_destroy = false
  depends_on = [google_project_service.cloud_resource_manager]
}

resource "google_project_service" "sql_admin" {
  service = "sqladmin.googleapis.com"
  disable_on_destroy = false
  depends_on = [google_project_service.cloud_resource_manager]
}

resource "google_project_service" "app_engine_flex" {
  service = "appengineflex.googleapis.com"
  disable_on_destroy = false
  depends_on = [google_project_service.cloud_resource_manager,
                google_project_service.app_engine]
}

module "api_pipeline_task" {
  source = "../../../api/pipeline-task/terraform"
  GOOGLE_CLOUD_PROJECT_NAME = var.GOOGLE_CLOUD_PROJECT_NAME
  GOOGLE_CLOUD_REGION = var.GOOGLE_CLOUD_REGION
  MODULE_API_PIPELINE_TASK_REPORT_BUCKET_NAME = var.MODULE_API_PIPELINE_TASK_REPORT_BUCKET_NAME
  MODULE_API_PIPELINE_TASK_WORK_BUCKET_NAME = var.MODULE_API_PIPELINE_TASK_WORK_BUCKET_NAME
  MODULE_API_PIPELINE_TASK_SERVICE_ACCOUNT_NAME = var.MODULE_API_PIPELINE_TASK_SERVICE_ACCOUNT_NAME

  ENVIRONMENT = var.ENVIRONMENT

  depends_on = [google_project_service.iam,
                google_project_service.run,
                google_project_service.cloudbuild,
                google_project_service.lifesciences, 
                google_project_service.container_registry]
}

module "site" {
  source = "../../../site/terraform"
  GOOGLE_CLOUD_PROJECT_NAME = var.GOOGLE_CLOUD_PROJECT_NAME
  GOOGLE_CLOUD_REGION = var.GOOGLE_CLOUD_REGION
  GOOGLE_CLOUD_APP_LOCATION = var.GOOGLE_CLOUD_APP_LOCATION
  GOOGLE_CLOUD_BUCKET_REGION = upper(var.GOOGLE_CLOUD_REGION)
  MODULE_SITE_BUCKET_PUBLIC_NAME = var.MODULE_SITE_BUCKET_PUBLIC_NAME
  MODULE_SITE_BUCKET_SECURE_NAME = var.MODULE_SITE_BUCKET_SECURE_NAME

  MODULE_SITE_CONTAINER_NAME = var.MODULE_SITE_CONTAINER_NAME
  MODULE_SITE_CONTAINER_VERSION = var.MODULE_SITE_CONTAINER_VERSION
  MODULE_SITE_DB_NAME = var.MODULE_SITE_DB_NAME
  MODULE_SITE_DB_INSTANCE_NAME = var.MODULE_SITE_DB_INSTANCE_NAME
  
  # secret.tfvars
  ANDERSEN_LAB_STRAIN_SHEET = var.ANDERSEN_LAB_STRAIN_SHEET
  CENDR_PUBLICATIONS_SHEET = var.CENDR_PUBLICATIONS_SHEET
  RECAPTCHA_PUBLIC_KEY = var.RECAPTCHA_PUBLIC_KEY
  RECAPTCHA_PRIVATE_KEY = var.RECAPTCHA_PRIVATE_KEY
  ELEVATION_API_KEY = var.ELEVATION_API_KEY  

  ENVIRONMENT = var.ENVIRONMENT

  depends_on = [google_project_service.iam,
                google_project_service.app_engine_flex,
                google_project_service.sql_admin,
                google_project_service.secret_manager]
}

